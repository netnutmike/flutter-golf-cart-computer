/// Main screen state notifier for the Golf Cart Computer.
///
/// Coordinates data from multiple domain managers and services to provide
/// a unified state for the main display screen. Subscribes to:
/// - GpsProcessor for speed, heading, coordinates, satellite/HDOP, date/time, sunrise/sunset
/// - OdometerManager for distance values
/// - ServiceReminderManager for driving hours
/// - GeofenceManager for at-home status
/// - SleepManager for operating mode
/// - BrightnessManager for display brightness
/// - TelemetryService for battery voltage, fuel, temperature, headlight mode
///
/// Also coordinates:
/// - GPS interval changes based on at-home status (8s away, 120s home)
/// - GCI notifications of at-home and is-daytime status changes
/// - Odometer/hours persistence before sleep/shutdown
///
/// Requirements: 5.3, 5.8, 5.9, 5.10, 5.13, 5.14, 5.17, 5.18, 6.3, 7.6,
///   8.3, 8.4, 8.5, 8.6, 8.13, 8.14, 9.5, 9.6, 11.6, 11.7, 12.4, 12.8
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:protobuf/protobuf.dart';

import '../data/services/meshtastic_service.dart';
import '../data/services/telemetry_service.dart';
import '../domain/brightness_manager.dart';
import '../domain/geofence_manager.dart';
import '../domain/gps_processor.dart';
import '../domain/models/brightness_state.dart';
import '../domain/models/geofence_state.dart';
import '../domain/models/gps_data.dart';
import '../domain/models/odometer_state.dart';
import '../domain/models/sleep_state.dart';
import '../domain/models/telemetry_data.dart';
import '../domain/odometer_manager.dart';
import '../domain/service_reminder_manager.dart';
import '../domain/sleep_manager.dart';

/// GPS update interval when away from home (seconds).
const int _kGpsIntervalAway = 8;

/// GPS update interval when at home (seconds).
const int _kGpsIntervalHome = 120;

/// State exposed by [MainNotifier] to the main screen UI.
class MainScreenState {
  /// Current speed in mph (integer, filtered).
  final int speedMph;

  /// 16-point cardinal direction (e.g., "NNE").
  final String cardinalDirection;

  /// Current latitude.
  final double latitude;

  /// Current longitude.
  final double longitude;

  /// Satellite count.
  final int satelliteCount;

  /// HDOP value.
  final double hdop;

  /// Formatted date string (e.g., "Mon, Jan 15") or "NO GPS".
  final String dateString;

  /// Formatted time string (e.g., "2:30 PM").
  final String timeString;

  /// Formatted sunrise time (e.g., "6:45 AM").
  final String sunriseTime;

  /// Formatted sunset time (e.g., "7:30 PM").
  final String sunsetTime;

  /// Whether it is currently daytime.
  final bool isDaytime;

  /// Total odometer miles (1 decimal place).
  final double totalMiles;

  /// Trip odometer miles (1 decimal place).
  final double tripMiles;

  /// Driving hours since last service (tenths of hours).
  final double hoursSinceService;

  /// Whether service is due.
  final bool isServiceDue;

  /// Battery voltage from GCI (e.g., 48.2).
  final double batteryVoltage;

  /// Fuel level percentage from GCI (e.g., 75.0).
  final double fuelLevel;

  /// Air temperature in °F with offset applied (integer).
  final int temperature;

  /// Headlight mode from GCI.
  final int headlightMode;

  /// Whether the device is at home.
  final bool isAtHome;

  /// Current operating mode.
  final OperatingMode operatingMode;

  /// Current display brightness level (0-10).
  final int brightnessLevel;

  /// Whether the display is dimmed.
  final bool isDimmed;

  const MainScreenState({
    this.speedMph = 0,
    this.cardinalDirection = 'N',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.satelliteCount = 0,
    this.hdop = 99.0,
    this.dateString = 'NO GPS',
    this.timeString = '--:-- --',
    this.sunriseTime = '--:-- --',
    this.sunsetTime = '--:-- --',
    this.isDaytime = true,
    this.totalMiles = 0.0,
    this.tripMiles = 0.0,
    this.hoursSinceService = 0.0,
    this.isServiceDue = false,
    this.batteryVoltage = 0.0,
    this.fuelLevel = 0.0,
    this.temperature = 0,
    this.headlightMode = 0,
    this.isAtHome = false,
    this.operatingMode = OperatingMode.startupGrace,
    this.brightnessLevel = 7,
    this.isDimmed = false,
  });

  /// Creates a copy with the specified fields replaced.
  MainScreenState copyWith({
    int? speedMph,
    String? cardinalDirection,
    double? latitude,
    double? longitude,
    int? satelliteCount,
    double? hdop,
    String? dateString,
    String? timeString,
    String? sunriseTime,
    String? sunsetTime,
    bool? isDaytime,
    double? totalMiles,
    double? tripMiles,
    double? hoursSinceService,
    bool? isServiceDue,
    double? batteryVoltage,
    double? fuelLevel,
    int? temperature,
    int? headlightMode,
    bool? isAtHome,
    OperatingMode? operatingMode,
    int? brightnessLevel,
    bool? isDimmed,
  }) {
    return MainScreenState(
      speedMph: speedMph ?? this.speedMph,
      cardinalDirection: cardinalDirection ?? this.cardinalDirection,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      satelliteCount: satelliteCount ?? this.satelliteCount,
      hdop: hdop ?? this.hdop,
      dateString: dateString ?? this.dateString,
      timeString: timeString ?? this.timeString,
      sunriseTime: sunriseTime ?? this.sunriseTime,
      sunsetTime: sunsetTime ?? this.sunsetTime,
      isDaytime: isDaytime ?? this.isDaytime,
      totalMiles: totalMiles ?? this.totalMiles,
      tripMiles: tripMiles ?? this.tripMiles,
      hoursSinceService: hoursSinceService ?? this.hoursSinceService,
      isServiceDue: isServiceDue ?? this.isServiceDue,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      temperature: temperature ?? this.temperature,
      headlightMode: headlightMode ?? this.headlightMode,
      isAtHome: isAtHome ?? this.isAtHome,
      operatingMode: operatingMode ?? this.operatingMode,
      brightnessLevel: brightnessLevel ?? this.brightnessLevel,
      isDimmed: isDimmed ?? this.isDimmed,
    );
  }
}

/// Main screen state notifier that coordinates all domain managers.
///
/// Uses Riverpod's [StateNotifier] pattern to expose a reactive
/// [MainScreenState] to the presentation layer.
class MainNotifier extends StateNotifier<MainScreenState> {
  MainNotifier({
    required GpsProcessor gpsProcessor,
    required OdometerManager odometerManager,
    required ServiceReminderManager serviceReminderManager,
    required GeofenceManager geofenceManager,
    required SleepManager sleepManager,
    required BrightnessManager brightnessManager,
    required TelemetryService telemetryService,
    required MeshtasticService meshtasticService,
    required int temperatureOffset,
  })  : _gpsProcessor = gpsProcessor,
        _odometerManager = odometerManager,
        _serviceReminderManager = serviceReminderManager,
        _geofenceManager = geofenceManager,
        _sleepManager = sleepManager,
        _brightnessManager = brightnessManager,
        _telemetryService = telemetryService,
        _meshtasticService = meshtasticService,
        _temperatureOffset = temperatureOffset,
        super(const MainScreenState()) {
    _subscribe();
  }

  final GpsProcessor _gpsProcessor;
  final OdometerManager _odometerManager;
  final ServiceReminderManager _serviceReminderManager;
  final GeofenceManager _geofenceManager;
  final SleepManager _sleepManager;
  final BrightnessManager _brightnessManager;
  final TelemetryService _telemetryService;
  final MeshtasticService _meshtasticService;

  /// Temperature offset from user preferences (-20 to +20).
  int _temperatureOffset;

  /// Tracks the last known at-home status for change detection.
  bool _lastIsAtHome = false;

  /// Tracks the last known is-daytime status for change detection.
  bool _lastIsDaytime = true;

  /// All active stream subscriptions.
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Sets up subscriptions to all domain manager streams.
  void _subscribe() {
    // GPS processed data: speed, heading, coordinates, satellite/HDOP
    _subscriptions.add(
      _gpsProcessor.gpsState.listen(_onGpsData),
    );

    // Navigation data: date, time, sunrise, sunset, isDaytime
    _subscriptions.add(
      _gpsProcessor.navigationData.listen(_onNavigationData),
    );

    // Odometer: total miles, trip miles
    _subscriptions.add(
      _odometerManager.odometerState.listen(_onOdometerState),
    );

    // Service reminder: driving hours, service-due status
    _subscriptions.add(
      _serviceReminderManager.serviceState.listen(_onServiceState),
    );

    // Geofence: at-home status
    _subscriptions.add(
      _geofenceManager.geofenceState.listen(_onGeofenceState),
    );

    // Sleep manager: operating mode
    _subscriptions.add(
      _sleepManager.operatingMode.listen(_onOperatingModeChange),
    );

    // Brightness manager: display brightness
    _subscriptions.add(
      _brightnessManager.brightnessState.listen(_onBrightnessState),
    );

    // Telemetry service: battery voltage, fuel, temperature, headlight mode
    _subscriptions.add(
      _telemetryService.telemetryData.listen(_onTelemetryData),
    );
  }

  /// Updates the temperature offset (called when preferences change).
  void updateTemperatureOffset(int offset) {
    _temperatureOffset = offset;
    // Re-apply offset to current temperature if we have telemetry data
    // The next telemetry update will use the new offset automatically.
  }

  /// Triggers persistence of odometer and driving hours.
  ///
  /// Should be called before sleep/shutdown transitions.
  /// Requirement 11.7: Persist odometer and driving hour values before
  /// entering background or shutdown.
  Future<void> persistBeforeSleep() async {
    await _odometerManager.persist();
    await _serviceReminderManager.persist();
  }

  // --- Stream Handlers ---

  /// Handles processed GPS data updates.
  ///
  /// Requirements: 5.3 (speed), 5.8 (heading), 5.9 (coordinates),
  /// 5.10 (satellite/HDOP)
  void _onGpsData(ProcessedGpsData data) {
    state = state.copyWith(
      speedMph: data.speedMph,
      cardinalDirection: data.cardinalDirection,
      latitude: data.latitude,
      longitude: data.longitude,
      satelliteCount: data.satelliteCount,
      hdop: data.hdop,
    );

    // Report activity to brightness manager when moving (speed > 0)
    if (data.speedMph > 0) {
      _brightnessManager.reportActivity();
    }
  }

  /// Handles navigation data updates (date, time, sunrise/sunset).
  ///
  /// Requirements: 5.13 (date), 5.14 (time), 5.17 (sunrise/sunset),
  /// 5.18 (sunrise/sunset display)
  void _onNavigationData(NavigationData data) {
    final previousIsDaytime = _lastIsDaytime;

    state = state.copyWith(
      dateString: data.dateString,
      timeString: data.timeString,
      sunriseTime: data.sunriseTime,
      sunsetTime: data.sunsetTime,
      isDaytime: data.isDaytime,
    );

    _lastIsDaytime = data.isDaytime;

    // Requirement 8.14: Notify GCI when is-daytime status changes
    if (data.isDaytime != previousIsDaytime) {
      _telemetryService.sendIsDaytime(data.isDaytime);
    }
  }

  /// Handles odometer state updates.
  ///
  /// Requirement 6.3: Display odometer and trip with 1 decimal place.
  void _onOdometerState(OdometerState data) {
    state = state.copyWith(
      totalMiles: data.totalMiles,
      tripMiles: data.tripMiles,
    );
  }

  /// Handles service reminder state updates.
  ///
  /// Requirement 7.6: Display hours since last service.
  void _onServiceState(ServiceState data) {
    state = state.copyWith(
      hoursSinceService: data.hoursSinceService,
      isServiceDue: data.isServiceDue,
    );
  }

  /// Handles geofence state updates.
  ///
  /// Requirements: 9.5, 9.6 (at-home status with hysteresis)
  /// Requirement 8.13: Notify GCI of at-home status on connection
  /// Requirement 8.14: Notify GCI when at-home status changes
  /// Requirement 12.8: Update GPS interval when at-home changes
  void _onGeofenceState(GeofenceState data) {
    final previousIsAtHome = _lastIsAtHome;

    state = state.copyWith(isAtHome: data.isAtHome);
    _lastIsAtHome = data.isAtHome;

    // Detect at-home status change
    if (data.isAtHome != previousIsAtHome) {
      // Requirement 8.14: Notify GCI of at-home status change
      _telemetryService.sendIsHome(data.isAtHome);

      // Requirement 12.4/12.8: Update GPS interval on Meshtastic radio
      _updateGpsInterval(data.isAtHome);
    }
  }

  /// Handles operating mode changes from the sleep manager.
  ///
  /// Requirement 11.6: Set GPS interval based on at-home in standalone mode.
  /// Requirement 11.7: Persist odometer/hours before sleep/shutdown.
  void _onOperatingModeChange(OperatingMode mode) {
    state = state.copyWith(operatingMode: mode);

    // When transitioning to standalone mode, apply GPS interval
    if (mode == OperatingMode.standaloneMode) {
      _updateGpsInterval(_lastIsAtHome);
    }

    // Persist data when transitioning away from active modes
    // (entering standalone could mean GCI disconnected — persist data)
    if (mode == OperatingMode.standaloneMode) {
      persistBeforeSleep();
    }
  }

  /// Handles brightness state updates.
  ///
  /// Requirement 12.4: Coordinate display brightness.
  void _onBrightnessState(BrightnessState data) {
    state = state.copyWith(
      brightnessLevel: data.currentLevel,
      isDimmed: data.isDimmed,
    );
  }

  /// Handles telemetry data from the GCI.
  ///
  /// Requirements: 8.3 (battery voltage), 8.4 (fuel level),
  /// 8.5 (temperature with offset), 8.6 (headlight mode)
  void _onTelemetryData(TelemetryData data) {
    // Requirement 8.5: Apply temperature offset from preferences
    final adjustedTemp = data.airTemperature.round() + _temperatureOffset;

    state = state.copyWith(
      batteryVoltage: data.batteryVoltage,
      fuelLevel: data.fuelLevel,
      temperature: adjustedTemp,
      headlightMode: data.headlightMode,
    );
  }

  // --- Coordination Logic ---

  /// Updates the GPS interval on the Meshtastic radio based on at-home status.
  ///
  /// Requirement 11.6: 120 seconds at home, 8 seconds away.
  /// Requirement 12.4/12.8: Send updated GPS interval configuration.
  void _updateGpsInterval(bool isAtHome) {
    final intervalSeconds = isAtHome ? _kGpsIntervalHome : _kGpsIntervalAway;

    // Update the Meshtastic radio's position config with the new interval.
    // Uses the stored position config from the handshake (read-modify-write).
    if (_meshtasticService is BleMeshtasticService) {
      final storedConfig = _meshtasticService.storedPositionConfig;
      if (storedConfig != null) {
        // Clone the stored config and update only the GPS interval
        final updatedConfig = storedConfig.deepCopy()
          ..gpsUpdateInterval = intervalSeconds;
        _meshtasticService.setPositionConfig(updatedConfig);
      }
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
