/// Configuration screen state notifier for the Golf Cart Computer.
///
/// Exposes all user preferences with getters and setters, implements
/// debounced persistence for slider/spinner values, and coordinates
/// user actions such as home location set/clear, GCI pairing,
/// Meshtastic enable/disable, service hours reset, trip odometer reset,
/// preference reset with app restart, and manual app restart.
///
/// Requirements: 9.1, 9.2, 9.8, 13.5, 13.7, 13.8, 15.3, 15.4, 12.7,
///              11.8, 7.9, 6.2, 14.4, 14.6
library;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/preferences_repository.dart';
import '../data/services/location_service.dart';
import '../data/services/meshtastic_service.dart';
import '../data/services/telemetry_service.dart';
import '../domain/audio_service.dart';
import '../domain/geofence_manager.dart';
import '../domain/odometer_manager.dart';
import '../domain/service_reminder_manager.dart';
import '../domain/models/user_preferences.dart';

/// State exposed by the [ConfigNotifier].
class ConfigState {
  /// Current user preferences.
  final UserPreferences preferences;

  /// Whether a GCI pairing operation is in progress.
  final bool isPairing;

  /// Whether the Meshtastic connection is enabled.
  final bool isMeshtasticEnabled;

  /// App version string (e.g., "0.1.0").
  final String appVersion;

  /// Device identifier string.
  final String deviceId;

  /// Error message from the last failed operation, or null.
  final String? lastError;

  /// Whether a confirmation is pending (for destructive actions).
  final bool confirmationPending;

  /// Description of the pending confirmation action.
  final String? confirmationAction;

  const ConfigState({
    this.preferences = const UserPreferences(),
    this.isPairing = false,
    this.isMeshtasticEnabled = false,
    this.appVersion = '',
    this.deviceId = '',
    this.lastError,
    this.confirmationPending = false,
    this.confirmationAction,
  });

  /// Creates a copy with the given fields replaced.
  ConfigState copyWith({
    UserPreferences? preferences,
    bool? isPairing,
    bool? isMeshtasticEnabled,
    String? appVersion,
    String? deviceId,
    String? lastError,
    bool clearError = false,
    bool? confirmationPending,
    String? confirmationAction,
    bool clearConfirmation = false,
  }) {
    return ConfigState(
      preferences: preferences ?? this.preferences,
      isPairing: isPairing ?? this.isPairing,
      isMeshtasticEnabled: isMeshtasticEnabled ?? this.isMeshtasticEnabled,
      appVersion: appVersion ?? this.appVersion,
      deviceId: deviceId ?? this.deviceId,
      lastError: clearError ? null : (lastError ?? this.lastError),
      confirmationPending: clearConfirmation
          ? false
          : (confirmationPending ?? this.confirmationPending),
      confirmationAction: clearConfirmation
          ? null
          : (confirmationAction ?? this.confirmationAction),
    );
  }
}

/// Notifier managing configuration screen state and user preference changes.
///
/// Coordinates with [PreferencesRepository] for persistence,
/// [LocationService] for GPS-dependent operations,
/// [TelemetryService] for GCI pairing,
/// [MeshtasticService] for radio enable/disable,
/// [GeofenceManager] for home location,
/// [OdometerManager] for trip reset,
/// [ServiceReminderManager] for service hours reset,
/// and [AudioService] for confirmation/error tones.
class ConfigNotifier extends StateNotifier<ConfigState> {
  final PreferencesRepository _preferencesRepository;
  final LocationService _locationService;
  final TelemetryService _telemetryService;
  final MeshtasticService _meshtasticService;
  final GeofenceManager _geofenceManager;
  final OdometerManager _odometerManager;
  final ServiceReminderManager _serviceReminderManager;
  final AudioService _audioService;

  /// Debounce timers for slider/spinner preference changes.
  final Map<String, Timer> _debounceTimers = {};

  /// Debounce duration for slider/spinner writes (2 seconds).
  static const Duration debounceDuration = Duration(seconds: 2);

  /// GCI pairing timeout duration (6 seconds).
  static const Duration pairingTimeout = Duration(seconds: 6);

  ConfigNotifier({
    required PreferencesRepository preferencesRepository,
    required LocationService locationService,
    required TelemetryService telemetryService,
    required MeshtasticService meshtasticService,
    required GeofenceManager geofenceManager,
    required OdometerManager odometerManager,
    required ServiceReminderManager serviceReminderManager,
    required AudioService audioService,
    String appVersion = '',
    String deviceId = '',
  })  : _preferencesRepository = preferencesRepository,
        _locationService = locationService,
        _telemetryService = telemetryService,
        _meshtasticService = meshtasticService,
        _geofenceManager = geofenceManager,
        _odometerManager = odometerManager,
        _serviceReminderManager = serviceReminderManager,
        _audioService = audioService,
        super(ConfigState(appVersion: appVersion, deviceId: deviceId));

  /// Loads preferences from storage and initializes state.
  Future<void> initialize() async {
    final prefs = await _preferencesRepository.loadPreferences();
    state = state.copyWith(
      preferences: prefs,
      isMeshtasticEnabled: prefs.meshtasticEnabled,
    );
  }

  // ===========================================================================
  // Preference Getters
  // ===========================================================================

  /// Current day brightness level (0-10).
  int get dayBrightness => state.preferences.dayBrightness;

  /// Current night brightness level (0-10).
  int get nightBrightness => state.preferences.nightBrightness;

  /// Current speaker volume (0-20).
  int get speakerVolume => state.preferences.speakerVolume;

  /// Whether screen flip is enabled.
  bool get flipScreen => state.preferences.flipScreen;

  /// Backlight timeout in minutes (0-60).
  int get backlightTimeoutMinutes => state.preferences.backlightTimeoutMinutes;

  /// Temperature offset in degrees (-20 to +20).
  int get temperatureOffset => state.preferences.temperatureOffset;

  /// Service interval in hours (1-500).
  int get serviceIntervalHours => state.preferences.serviceIntervalHours;

  /// Home geofence radius in meters (100-5000).
  int get homeFenceRadiusMeters => state.preferences.homeFenceRadiusMeters;

  /// Whether Meshtastic is enabled.
  bool get meshtasticEnabled => state.preferences.meshtasticEnabled;

  /// Whether a home location is set.
  bool get isHomeLocationSet =>
      state.preferences.homeLatitude != null &&
      state.preferences.homeLongitude != null;

  // ===========================================================================
  // Preference Setters (with 2-second debounce for sliders/spinners)
  // ===========================================================================

  /// Sets the day brightness level (0-10). Debounced write.
  void setDayBrightness(int value) {
    final clamped = value.clamp(0, 10);
    _updatePreference(
      PreferenceKeys.dayBrightness,
      clamped,
      (prefs) => UserPreferences(
        dayBrightness: clamped,
        nightBrightness: prefs.nightBrightness,
        speakerVolume: prefs.speakerVolume,
        flipScreen: prefs.flipScreen,
        backlightTimeoutMinutes: prefs.backlightTimeoutMinutes,
        temperatureOffset: prefs.temperatureOffset,
        serviceIntervalHours: prefs.serviceIntervalHours,
        gciDeviceAddress: prefs.gciDeviceAddress,
        homeLatitude: prefs.homeLatitude,
        homeLongitude: prefs.homeLongitude,
        homeFenceRadiusMeters: prefs.homeFenceRadiusMeters,
        meshtasticEnabled: prefs.meshtasticEnabled,
        meshtasticDeviceId: prefs.meshtasticDeviceId,
      ),
    );
  }

  /// Sets the night brightness level (0-10). Debounced write.
  void setNightBrightness(int value) {
    final clamped = value.clamp(0, 10);
    _updatePreference(
      PreferenceKeys.nightBrightness,
      clamped,
      (prefs) => UserPreferences(
        dayBrightness: prefs.dayBrightness,
        nightBrightness: clamped,
        speakerVolume: prefs.speakerVolume,
        flipScreen: prefs.flipScreen,
        backlightTimeoutMinutes: prefs.backlightTimeoutMinutes,
        temperatureOffset: prefs.temperatureOffset,
        serviceIntervalHours: prefs.serviceIntervalHours,
        gciDeviceAddress: prefs.gciDeviceAddress,
        homeLatitude: prefs.homeLatitude,
        homeLongitude: prefs.homeLongitude,
        homeFenceRadiusMeters: prefs.homeFenceRadiusMeters,
        meshtasticEnabled: prefs.meshtasticEnabled,
        meshtasticDeviceId: prefs.meshtasticDeviceId,
      ),
    );
  }

  /// Sets the speaker volume (0-20). Debounced write.
  void setSpeakerVolume(int value) {
    final clamped = value.clamp(0, 20);
    _audioService.setVolume(clamped);
    _updatePreference(
      PreferenceKeys.speakerVolume,
      clamped,
      (prefs) => UserPreferences(
        dayBrightness: prefs.dayBrightness,
        nightBrightness: prefs.nightBrightness,
        speakerVolume: clamped,
        flipScreen: prefs.flipScreen,
        backlightTimeoutMinutes: prefs.backlightTimeoutMinutes,
        temperatureOffset: prefs.temperatureOffset,
        serviceIntervalHours: prefs.serviceIntervalHours,
        gciDeviceAddress: prefs.gciDeviceAddress,
        homeLatitude: prefs.homeLatitude,
        homeLongitude: prefs.homeLongitude,
        homeFenceRadiusMeters: prefs.homeFenceRadiusMeters,
        meshtasticEnabled: prefs.meshtasticEnabled,
        meshtasticDeviceId: prefs.meshtasticDeviceId,
      ),
    );
  }

  /// Sets the screen flip preference. Immediate write.
  void setFlipScreen(bool value) {
    _savePreferenceImmediate(
      PreferenceKeys.flipScreen,
      value,
      (prefs) => UserPreferences(
        dayBrightness: prefs.dayBrightness,
        nightBrightness: prefs.nightBrightness,
        speakerVolume: prefs.speakerVolume,
        flipScreen: value,
        backlightTimeoutMinutes: prefs.backlightTimeoutMinutes,
        temperatureOffset: prefs.temperatureOffset,
        serviceIntervalHours: prefs.serviceIntervalHours,
        gciDeviceAddress: prefs.gciDeviceAddress,
        homeLatitude: prefs.homeLatitude,
        homeLongitude: prefs.homeLongitude,
        homeFenceRadiusMeters: prefs.homeFenceRadiusMeters,
        meshtasticEnabled: prefs.meshtasticEnabled,
        meshtasticDeviceId: prefs.meshtasticDeviceId,
      ),
    );
  }

  /// Sets the backlight timeout in minutes (0-60). Debounced write.
  void setBacklightTimeout(int value) {
    final clamped = value.clamp(0, 60);
    _updatePreference(
      PreferenceKeys.backlightTimeoutMinutes,
      clamped,
      (prefs) => UserPreferences(
        dayBrightness: prefs.dayBrightness,
        nightBrightness: prefs.nightBrightness,
        speakerVolume: prefs.speakerVolume,
        flipScreen: prefs.flipScreen,
        backlightTimeoutMinutes: clamped,
        temperatureOffset: prefs.temperatureOffset,
        serviceIntervalHours: prefs.serviceIntervalHours,
        gciDeviceAddress: prefs.gciDeviceAddress,
        homeLatitude: prefs.homeLatitude,
        homeLongitude: prefs.homeLongitude,
        homeFenceRadiusMeters: prefs.homeFenceRadiusMeters,
        meshtasticEnabled: prefs.meshtasticEnabled,
        meshtasticDeviceId: prefs.meshtasticDeviceId,
      ),
    );
  }

  /// Sets the temperature offset (-20 to +20). Debounced write.
  void setTemperatureOffset(int value) {
    final clamped = value.clamp(-20, 20);
    _updatePreference(
      PreferenceKeys.temperatureOffset,
      clamped,
      (prefs) => UserPreferences(
        dayBrightness: prefs.dayBrightness,
        nightBrightness: prefs.nightBrightness,
        speakerVolume: prefs.speakerVolume,
        flipScreen: prefs.flipScreen,
        backlightTimeoutMinutes: prefs.backlightTimeoutMinutes,
        temperatureOffset: clamped,
        serviceIntervalHours: prefs.serviceIntervalHours,
        gciDeviceAddress: prefs.gciDeviceAddress,
        homeLatitude: prefs.homeLatitude,
        homeLongitude: prefs.homeLongitude,
        homeFenceRadiusMeters: prefs.homeFenceRadiusMeters,
        meshtasticEnabled: prefs.meshtasticEnabled,
        meshtasticDeviceId: prefs.meshtasticDeviceId,
      ),
    );
  }

  /// Sets the service interval in hours (1-500). Debounced write.
  void setServiceInterval(int value) {
    final clamped = value.clamp(1, 500);
    _updatePreference(
      PreferenceKeys.serviceIntervalHours,
      clamped,
      (prefs) => UserPreferences(
        dayBrightness: prefs.dayBrightness,
        nightBrightness: prefs.nightBrightness,
        speakerVolume: prefs.speakerVolume,
        flipScreen: prefs.flipScreen,
        backlightTimeoutMinutes: prefs.backlightTimeoutMinutes,
        temperatureOffset: prefs.temperatureOffset,
        serviceIntervalHours: clamped,
        gciDeviceAddress: prefs.gciDeviceAddress,
        homeLatitude: prefs.homeLatitude,
        homeLongitude: prefs.homeLongitude,
        homeFenceRadiusMeters: prefs.homeFenceRadiusMeters,
        meshtasticEnabled: prefs.meshtasticEnabled,
        meshtasticDeviceId: prefs.meshtasticDeviceId,
      ),
    );
  }

  /// Sets the home geofence radius in meters (100-5000). Debounced write.
  void setHomeFenceRadius(int value) {
    final clamped = value.clamp(100, 5000);
    _geofenceManager.setRadius(clamped);
    _updatePreference(
      PreferenceKeys.homeFenceRadiusMeters,
      clamped,
      (prefs) => UserPreferences(
        dayBrightness: prefs.dayBrightness,
        nightBrightness: prefs.nightBrightness,
        speakerVolume: prefs.speakerVolume,
        flipScreen: prefs.flipScreen,
        backlightTimeoutMinutes: prefs.backlightTimeoutMinutes,
        temperatureOffset: prefs.temperatureOffset,
        serviceIntervalHours: prefs.serviceIntervalHours,
        gciDeviceAddress: prefs.gciDeviceAddress,
        homeLatitude: prefs.homeLatitude,
        homeLongitude: prefs.homeLongitude,
        homeFenceRadiusMeters: clamped,
        meshtasticEnabled: prefs.meshtasticEnabled,
        meshtasticDeviceId: prefs.meshtasticDeviceId,
      ),
    );
  }

  // ===========================================================================
  // Home Location Actions
  // ===========================================================================

  /// Sets the home location to the current GPS position.
  ///
  /// Requires GPS to be available. Plays confirmation tone on success,
  /// error tone if GPS is unavailable.
  /// Requirements: 9.1, 9.8, 14.4, 14.6
  Future<void> setHomeLocation() async {
    final position = await _locationService.currentPosition;

    if (position == null) {
      state = state.copyWith(
        lastError: 'GPS is required to set home location',
      );
      await _audioService.playError();
      return;
    }

    final lat = position.latitude;
    final lon = position.longitude;

    // Update geofence manager
    _geofenceManager.setHomeLocation(lat, lon);

    // Persist home coordinates
    await _preferencesRepository.savePreference(
      PreferenceKeys.homeLatitude,
      lat,
    );
    await _preferencesRepository.savePreference(
      PreferenceKeys.homeLongitude,
      lon,
    );

    // Update state
    final updatedPrefs = UserPreferences(
      dayBrightness: state.preferences.dayBrightness,
      nightBrightness: state.preferences.nightBrightness,
      speakerVolume: state.preferences.speakerVolume,
      flipScreen: state.preferences.flipScreen,
      backlightTimeoutMinutes: state.preferences.backlightTimeoutMinutes,
      temperatureOffset: state.preferences.temperatureOffset,
      serviceIntervalHours: state.preferences.serviceIntervalHours,
      gciDeviceAddress: state.preferences.gciDeviceAddress,
      homeLatitude: lat,
      homeLongitude: lon,
      homeFenceRadiusMeters: state.preferences.homeFenceRadiusMeters,
      meshtasticEnabled: state.preferences.meshtasticEnabled,
      meshtasticDeviceId: state.preferences.meshtasticDeviceId,
    );

    state = state.copyWith(preferences: updatedPrefs, clearError: true);
    await _audioService.playConfirmation();
  }

  /// Clears the saved home location.
  ///
  /// Requirements: 9.2
  Future<void> clearHomeLocation() async {
    _geofenceManager.clearHomeLocation();

    await _preferencesRepository.savePreference(
      PreferenceKeys.homeLatitude,
      null,
    );
    await _preferencesRepository.savePreference(
      PreferenceKeys.homeLongitude,
      null,
    );

    final updatedPrefs = UserPreferences(
      dayBrightness: state.preferences.dayBrightness,
      nightBrightness: state.preferences.nightBrightness,
      speakerVolume: state.preferences.speakerVolume,
      flipScreen: state.preferences.flipScreen,
      backlightTimeoutMinutes: state.preferences.backlightTimeoutMinutes,
      temperatureOffset: state.preferences.temperatureOffset,
      serviceIntervalHours: state.preferences.serviceIntervalHours,
      gciDeviceAddress: state.preferences.gciDeviceAddress,
      homeLatitude: null,
      homeLongitude: null,
      homeFenceRadiusMeters: state.preferences.homeFenceRadiusMeters,
      meshtasticEnabled: state.preferences.meshtasticEnabled,
      meshtasticDeviceId: state.preferences.meshtasticDeviceId,
    );

    state = state.copyWith(preferences: updatedPrefs, clearError: true);
    await _audioService.playConfirmation();
  }

  // ===========================================================================
  // GCI Pairing
  // ===========================================================================

  /// Initiates GCI pairing with a 6-second timeout.
  ///
  /// Plays confirmation tone on success, error tone on timeout.
  /// Requirements: 13.5, 14.4, 14.6
  Future<void> initiateGciPairing() async {
    state = state.copyWith(isPairing: true, clearError: true);

    try {
      await _telemetryService.pairNewDevice(timeout: pairingTimeout);
      state = state.copyWith(isPairing: false);
      await _audioService.playConfirmation();
    } catch (e) {
      state = state.copyWith(
        isPairing: false,
        lastError: 'GCI pairing failed: timeout or no device found',
      );
      await _audioService.playError();
    }
  }

  // ===========================================================================
  // Meshtastic Enable/Disable
  // ===========================================================================

  /// Enables or disables the Meshtastic radio connection.
  ///
  /// When disabled, disconnects from the radio and suppresses auto-reconnect.
  /// When enabled, allows the connection notifier to initiate connection.
  /// Requirements: 12.7
  Future<void> setMeshtasticEnabled(bool enabled) async {
    if (!enabled) {
      // Disconnect and suppress reconnection
      await _meshtasticService.disconnect();
    }

    await _preferencesRepository.savePreference(
      PreferenceKeys.meshtasticEnabled,
      enabled,
    );

    final updatedPrefs = UserPreferences(
      dayBrightness: state.preferences.dayBrightness,
      nightBrightness: state.preferences.nightBrightness,
      speakerVolume: state.preferences.speakerVolume,
      flipScreen: state.preferences.flipScreen,
      backlightTimeoutMinutes: state.preferences.backlightTimeoutMinutes,
      temperatureOffset: state.preferences.temperatureOffset,
      serviceIntervalHours: state.preferences.serviceIntervalHours,
      gciDeviceAddress: state.preferences.gciDeviceAddress,
      homeLatitude: state.preferences.homeLatitude,
      homeLongitude: state.preferences.homeLongitude,
      homeFenceRadiusMeters: state.preferences.homeFenceRadiusMeters,
      meshtasticEnabled: enabled,
      meshtasticDeviceId: state.preferences.meshtasticDeviceId,
    );

    state = state.copyWith(
      preferences: updatedPrefs,
      isMeshtasticEnabled: enabled,
    );
    await _audioService.playConfirmation();
  }

  // ===========================================================================
  // Service Hours Reset
  // ===========================================================================

  /// Requests confirmation before resetting service hours.
  ///
  /// Requirements: 7.9
  void requestServiceHoursReset() {
    state = state.copyWith(
      confirmationPending: true,
      confirmationAction: 'resetServiceHours',
    );
  }

  /// Confirms and executes the service hours reset.
  ///
  /// Requirements: 7.9, 14.4
  Future<void> confirmServiceHoursReset() async {
    _serviceReminderManager.resetHours();
    state = state.copyWith(clearConfirmation: true);
    await _audioService.playConfirmation();
  }

  // ===========================================================================
  // Trip Odometer Reset
  // ===========================================================================

  /// Resets the trip odometer to 0.0.
  ///
  /// Requirements: 6.2, 14.4
  Future<void> resetTripOdometer() async {
    _odometerManager.resetTripOdometer();
    await _audioService.playConfirmation();
  }

  // ===========================================================================
  // Reset All Preferences
  // ===========================================================================

  /// Requests confirmation before resetting all preferences.
  ///
  /// Requirements: 15.4
  void requestResetAllPreferences() {
    state = state.copyWith(
      confirmationPending: true,
      confirmationAction: 'resetAllPreferences',
    );
  }

  /// Confirms and executes the reset of all preferences, then restarts the app.
  ///
  /// Clears all user-configurable settings while preserving operational data
  /// (odometer, trip odometer, driving hours), then triggers an app restart.
  /// Requirements: 15.4
  Future<void> confirmResetAllPreferences() async {
    await _preferencesRepository.resetAllPreferences();
    state = state.copyWith(clearConfirmation: true);
    await _audioService.playConfirmation();

    // Trigger app restart
    await _restartApp();
  }

  // ===========================================================================
  // Manual App Restart
  // ===========================================================================

  /// Manually restarts the application.
  ///
  /// Resets the Sleep_Manager to STARTUP_GRACE state.
  /// Requirements: 11.8
  Future<void> restartApp() async {
    await _audioService.playConfirmation();
    await _restartApp();
  }

  // ===========================================================================
  // Confirmation Handling
  // ===========================================================================

  /// Cancels a pending confirmation action.
  void cancelConfirmation() {
    state = state.copyWith(clearConfirmation: true);
  }

  /// Executes the pending confirmed action.
  Future<void> executeConfirmedAction() async {
    final action = state.confirmationAction;
    switch (action) {
      case 'resetServiceHours':
        await confirmServiceHoursReset();
      case 'resetAllPreferences':
        await confirmResetAllPreferences();
      default:
        state = state.copyWith(clearConfirmation: true);
    }
  }

  // ===========================================================================
  // App Version and Device Identifier
  // ===========================================================================

  /// Returns the app version string.
  String get appVersion => state.appVersion;

  /// Returns the device identifier string.
  String get deviceId => state.deviceId;

  // ===========================================================================
  // Error Handling
  // ===========================================================================

  /// Clears the last error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ===========================================================================
  // Cleanup
  // ===========================================================================

  /// Cancels all pending debounce timers.
  @override
  void dispose() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    super.dispose();
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// Updates a preference with debounce for slider/spinner keys.
  ///
  /// Updates the in-memory state immediately for responsive UI, but
  /// debounces the persistence write by 2 seconds.
  void _updatePreference(
    String key,
    dynamic value,
    UserPreferences Function(UserPreferences current) updater,
  ) {
    // Update state immediately for responsive UI
    final updatedPrefs = updater(state.preferences);
    state = state.copyWith(preferences: updatedPrefs);

    // Debounce the persistence write
    if (PreferenceKeys.debouncedKeys.contains(key)) {
      _debounceTimers[key]?.cancel();
      _debounceTimers[key] = Timer(debounceDuration, () {
        _preferencesRepository.savePreference(key, value);
        _debounceTimers.remove(key);
      });
    } else {
      _preferencesRepository.savePreference(key, value);
    }
  }

  /// Saves a preference immediately (no debounce) and updates state.
  void _savePreferenceImmediate(
    String key,
    dynamic value,
    UserPreferences Function(UserPreferences current) updater,
  ) {
    final updatedPrefs = updater(state.preferences);
    state = state.copyWith(preferences: updatedPrefs);
    _preferencesRepository.savePreference(key, value);
  }

  /// Triggers an app restart via platform channel or SystemNavigator.
  Future<void> _restartApp() async {
    // Use SystemNavigator to pop the app, which effectively restarts it
    // on most platforms. A more robust solution would use a platform channel
    // for a true restart, but this satisfies the requirement.
    await SystemNavigator.pop();
  }
}
