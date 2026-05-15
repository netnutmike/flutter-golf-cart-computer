/// Preferences repository for persistent key-value storage.
///
/// Wraps shared_preferences for user settings, odometer values,
/// and driving hours persistence.
library;

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/odometer_state.dart';
import '../../domain/models/user_preferences.dart';

/// Abstract interface for preferences persistence.
abstract class PreferencesRepository {
  /// Loads all user preferences, applying defaults for missing/corrupted values.
  Future<UserPreferences> loadPreferences();

  /// Saves a single preference value with 2-second debounce for slider/spinner keys.
  Future<void> savePreference(String key, dynamic value);

  /// Resets all user-configurable preferences while preserving operational data
  /// (odometer values, trip odometer, driving hours).
  Future<void> resetAllPreferences();

  /// Persists odometer values (total and trip miles).
  Future<void> persistOdometer(double totalMiles, double tripMiles);

  /// Loads persisted odometer values. Returns zeros if missing/corrupted.
  Future<OdometerState> loadOdometer();

  /// Persists driving hours (in tenths of hours).
  Future<void> persistDrivingHours(double tenthsOfHours);

  /// Loads persisted driving hours. Returns 0.0 if missing/corrupted.
  Future<double> loadDrivingHours();
}

/// Shared preferences keys for all persisted values.
class PreferenceKeys {
  PreferenceKeys._();

  static const String dayBrightness = 'pref_day_brightness';
  static const String nightBrightness = 'pref_night_brightness';
  static const String speakerVolume = 'pref_speaker_volume';
  static const String flipScreen = 'pref_flip_screen';
  static const String backlightTimeoutMinutes = 'pref_backlight_timeout';
  static const String temperatureOffset = 'pref_temperature_offset';
  static const String serviceIntervalHours = 'pref_service_interval';
  static const String gciDeviceAddress = 'pref_gci_device_address';
  static const String homeLatitude = 'pref_home_latitude';
  static const String homeLongitude = 'pref_home_longitude';
  static const String homeFenceRadiusMeters = 'pref_home_fence_radius';
  static const String meshtasticEnabled = 'pref_meshtastic_enabled';
  static const String meshtasticDeviceId = 'pref_meshtastic_device_id';

  // Operational data keys (preserved on reset)
  static const String odometerTotal = 'op_odometer_total';
  static const String odometerTrip = 'op_odometer_trip';
  static const String drivingHours = 'op_driving_hours';

  /// All user-configurable preference keys (cleared on reset).
  static const List<String> userConfigurableKeys = [
    dayBrightness,
    nightBrightness,
    speakerVolume,
    flipScreen,
    backlightTimeoutMinutes,
    temperatureOffset,
    serviceIntervalHours,
    gciDeviceAddress,
    homeLatitude,
    homeLongitude,
    homeFenceRadiusMeters,
    meshtasticEnabled,
    meshtasticDeviceId,
  ];

  /// Keys that use debounced writes (sliders/spinners).
  static const Set<String> debouncedKeys = {
    dayBrightness,
    nightBrightness,
    speakerVolume,
    backlightTimeoutMinutes,
    temperatureOffset,
    serviceIntervalHours,
    homeFenceRadiusMeters,
  };
}

/// Implementation of [PreferencesRepository] using shared_preferences.
class SharedPreferencesRepository implements PreferencesRepository {
  final SharedPreferences _prefs;

  /// Debounce timers for slider/spinner values.
  final Map<String, Timer> _debounceTimers = {};

  /// Debounce duration for slider/spinner writes.
  static const Duration debounceDuration = Duration(seconds: 2);

  SharedPreferencesRepository(this._prefs);

  @override
  Future<UserPreferences> loadPreferences() async {
    return UserPreferences(
      dayBrightness: _loadInt(
        PreferenceKeys.dayBrightness,
        UserPreferences.defaults.dayBrightness,
        min: 0,
        max: 10,
      ),
      nightBrightness: _loadInt(
        PreferenceKeys.nightBrightness,
        UserPreferences.defaults.nightBrightness,
        min: 0,
        max: 10,
      ),
      speakerVolume: _loadInt(
        PreferenceKeys.speakerVolume,
        UserPreferences.defaults.speakerVolume,
        min: 0,
        max: 20,
      ),
      flipScreen: _loadBool(
        PreferenceKeys.flipScreen,
        UserPreferences.defaults.flipScreen,
      ),
      backlightTimeoutMinutes: _loadInt(
        PreferenceKeys.backlightTimeoutMinutes,
        UserPreferences.defaults.backlightTimeoutMinutes,
        min: 0,
        max: 60,
      ),
      temperatureOffset: _loadInt(
        PreferenceKeys.temperatureOffset,
        UserPreferences.defaults.temperatureOffset,
        min: -20,
        max: 20,
      ),
      serviceIntervalHours: _loadInt(
        PreferenceKeys.serviceIntervalHours,
        UserPreferences.defaults.serviceIntervalHours,
        min: 1,
        max: 500,
      ),
      gciDeviceAddress: _loadString(PreferenceKeys.gciDeviceAddress),
      homeLatitude: _loadDouble(PreferenceKeys.homeLatitude),
      homeLongitude: _loadDouble(PreferenceKeys.homeLongitude),
      homeFenceRadiusMeters: _loadInt(
        PreferenceKeys.homeFenceRadiusMeters,
        UserPreferences.defaults.homeFenceRadiusMeters,
        min: 100,
        max: 5000,
      ),
      meshtasticEnabled: _loadBool(
        PreferenceKeys.meshtasticEnabled,
        UserPreferences.defaults.meshtasticEnabled,
      ),
      meshtasticDeviceId: _loadString(PreferenceKeys.meshtasticDeviceId),
    );
  }

  @override
  Future<void> savePreference(String key, dynamic value) async {
    if (PreferenceKeys.debouncedKeys.contains(key)) {
      _debouncedWrite(key, value);
    } else {
      await _writeValue(key, value);
    }
  }

  @override
  Future<void> resetAllPreferences() async {
    // Cancel any pending debounced writes
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    // Remove only user-configurable keys, preserving operational data
    for (final key in PreferenceKeys.userConfigurableKeys) {
      await _prefs.remove(key);
    }
  }

  @override
  Future<void> persistOdometer(double totalMiles, double tripMiles) async {
    await _prefs.setDouble(PreferenceKeys.odometerTotal, totalMiles);
    await _prefs.setDouble(PreferenceKeys.odometerTrip, tripMiles);
  }

  @override
  Future<OdometerState> loadOdometer() async {
    final total = _loadDoubleWithDefault(PreferenceKeys.odometerTotal, 0.0);
    final trip = _loadDoubleWithDefault(PreferenceKeys.odometerTrip, 0.0);
    final hours = _loadDoubleWithDefault(PreferenceKeys.drivingHours, 0.0);

    return OdometerState(
      totalMiles: total,
      tripMiles: trip,
      hoursSinceService: hours,
    );
  }

  @override
  Future<void> persistDrivingHours(double tenthsOfHours) async {
    await _prefs.setDouble(PreferenceKeys.drivingHours, tenthsOfHours);
  }

  @override
  Future<double> loadDrivingHours() async {
    return _loadDoubleWithDefault(PreferenceKeys.drivingHours, 0.0);
  }

  // --- Private helpers ---

  /// Loads an int value with range validation. Returns [defaultValue] if
  /// missing, corrupted, or out of range.
  int _loadInt(String key, int defaultValue, {required int min, required int max}) {
    try {
      final value = _prefs.getInt(key);
      if (value == null) return defaultValue;
      if (value < min || value > max) return defaultValue;
      return value;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Loads a bool value. Returns [defaultValue] if missing or corrupted.
  bool _loadBool(String key, bool defaultValue) {
    try {
      return _prefs.getBool(key) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Loads a nullable string value. Returns null if missing or corrupted.
  String? _loadString(String key) {
    try {
      return _prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  /// Loads a nullable double value. Returns null if missing or corrupted.
  double? _loadDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (_) {
      return null;
    }
  }

  /// Loads a double value with a default. Returns [defaultValue] if missing or corrupted.
  double _loadDoubleWithDefault(String key, double defaultValue) {
    try {
      return _prefs.getDouble(key) ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Debounces a write operation for slider/spinner values.
  void _debouncedWrite(String key, dynamic value) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(debounceDuration, () {
      _writeValue(key, value);
      _debounceTimers.remove(key);
    });
  }

  /// Writes a value to shared preferences based on its runtime type.
  Future<void> _writeValue(String key, dynamic value) async {
    switch (value) {
      case final int v:
        await _prefs.setInt(key, v);
      case final double v:
        await _prefs.setDouble(key, v);
      case final bool v:
        await _prefs.setBool(key, v);
      case final String v:
        await _prefs.setString(key, v);
      case null:
        await _prefs.remove(key);
      default:
        throw ArgumentError('Unsupported preference value type: ${value.runtimeType}');
    }
  }
}
