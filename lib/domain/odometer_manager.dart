import 'dart:async';
import 'dart:math' as math;

import 'package:golf_cart_computer/data/repositories/preferences_repository.dart';
import 'package:golf_cart_computer/domain/models/gps_data.dart';
import 'package:golf_cart_computer/domain/models/odometer_state.dart';

/// Accumulates distance using GPS position calculations.
///
/// Implements:
/// - Doppler speed gating: only accumulate when filtered speed > 0
/// - Minimum distance thresholds: 2.6 feet (0.0005 miles) with Doppler,
///   10 feet (0.002 miles) without
/// - Position-based speed rejection: discard if implied speed > 30 mph
/// - Rollover: total at 100,000.0 miles, trip at 10,000.0 miles
/// - Trip reset without affecting total
/// - Persistence triggers: every 0.5 miles and before sleep/shutdown
abstract class OdometerManager {
  /// Stream of current odometer state.
  Stream<OdometerState> get odometerState;

  /// Process a GPS position update to accumulate distance.
  void processPosition(ProcessedGpsData gpsData);

  /// Reset the trip odometer to 0.0 without affecting total.
  void resetTripOdometer();

  /// Persist current odometer values to storage.
  /// Called before sleep/shutdown and every 0.5 miles.
  Future<void> persist();
}

/// Default implementation of [OdometerManager].
///
/// Uses the Haversine formula for distance calculation between GPS positions.
/// Applies multiple gating criteria before accumulating distance.
class DefaultOdometerManager implements OdometerManager {
  DefaultOdometerManager({
    required PreferencesRepository preferencesRepository,
  }) : _preferencesRepository = preferencesRepository;

  final PreferencesRepository _preferencesRepository;

  final _odometerStateController = StreamController<OdometerState>.broadcast();

  /// Minimum distance threshold with Doppler speed confirmation: 2.6 feet.
  static const double minDistanceWithDopplerMiles = 0.0005;

  /// Minimum distance threshold without Doppler speed: 10 feet.
  static const double minDistanceWithoutDopplerMiles = 0.002;

  /// Maximum position-based speed before rejecting as GPS error.
  static const double maxPositionSpeedMph = 30.0;

  /// Total odometer rollover point.
  static const double totalRolloverMiles = 100000.0;

  /// Trip odometer rollover point.
  static const double tripRolloverMiles = 10000.0;

  /// Persistence trigger interval in miles.
  static const double persistIntervalMiles = 0.5;

  // Current state
  double _totalMiles = 0.0;
  double _tripMiles = 0.0;
  double _hoursSinceService = 0.0;

  // Tracking for persistence triggers
  double _milesSinceLastPersist = 0.0;

  // Previous position for distance calculation
  double? _lastLatitude;
  double? _lastLongitude;
  DateTime? _lastTimestamp;

  // Whether state has been loaded from storage
  bool _isLoaded = false;

  @override
  Stream<OdometerState> get odometerState => _odometerStateController.stream;

  /// Exposes total miles for testing purposes.
  double get totalMilesForTest => _totalMiles;

  /// Exposes trip miles for testing purposes.
  double get tripMilesForTest => _tripMiles;

  /// Loads persisted odometer values from storage.
  /// Must be called before processing positions.
  Future<void> load() async {
    final state = await _preferencesRepository.loadOdometer();
    _totalMiles = state.totalMiles;
    _tripMiles = state.tripMiles;
    _hoursSinceService = state.hoursSinceService;
    _isLoaded = true;
    _emitState();
  }

  /// Synchronously initializes the manager with given values.
  /// Used for testing to avoid async issues with property-based test frameworks.
  void loadSync(double totalMiles, double tripMiles, double hoursSinceService) {
    _totalMiles = totalMiles;
    _tripMiles = tripMiles;
    _hoursSinceService = hoursSinceService;
    _isLoaded = true;
  }

  @override
  void processPosition(ProcessedGpsData gpsData) {
    if (!_isLoaded) return;
    if (!gpsData.isValid) return;

    // Doppler speed gating: only accumulate when filtered speed > 0
    if (gpsData.speedMph <= 0) {
      // Update last position even when not accumulating, so we don't
      // get a huge jump when movement resumes
      _lastLatitude = gpsData.latitude;
      _lastLongitude = gpsData.longitude;
      _lastTimestamp = gpsData.timestamp;
      return;
    }

    // Need a previous position to calculate distance
    if (_lastLatitude == null ||
        _lastLongitude == null ||
        _lastTimestamp == null) {
      _lastLatitude = gpsData.latitude;
      _lastLongitude = gpsData.longitude;
      _lastTimestamp = gpsData.timestamp;
      return;
    }

    // Calculate distance using Haversine formula
    final distanceMiles = _haversineDistanceMiles(
      _lastLatitude!,
      _lastLongitude!,
      gpsData.latitude,
      gpsData.longitude,
    );

    // Determine if Doppler speed is available (rawSpeedMph > 0 indicates
    // the GPS sensor provided a Doppler-based speed reading)
    final hasDopplerSpeed = gpsData.rawSpeedMph > 0;

    // Apply minimum distance threshold
    final minDistance = hasDopplerSpeed
        ? minDistanceWithDopplerMiles
        : minDistanceWithoutDopplerMiles;

    if (distanceMiles < minDistance) {
      // Distance too small, don't accumulate but update position
      _lastLatitude = gpsData.latitude;
      _lastLongitude = gpsData.longitude;
      _lastTimestamp = gpsData.timestamp;
      return;
    }

    // Position-based speed rejection: calculate implied speed
    final elapsedSeconds =
        gpsData.timestamp.difference(_lastTimestamp!).inMilliseconds / 1000.0;

    if (elapsedSeconds > 0) {
      final impliedSpeedMph = (distanceMiles / elapsedSeconds) * 3600.0;
      if (impliedSpeedMph > maxPositionSpeedMph) {
        // Implied speed too high — GPS error, discard entirely
        // Don't update last position so we can try again with next reading
        return;
      }
    }

    // All gates passed — accumulate distance
    _totalMiles += distanceMiles;
    _tripMiles += distanceMiles;
    _milesSinceLastPersist += distanceMiles;

    // Apply rollover
    if (_totalMiles >= totalRolloverMiles) {
      _totalMiles = _totalMiles % totalRolloverMiles;
    }
    if (_tripMiles >= tripRolloverMiles) {
      _tripMiles = _tripMiles % tripRolloverMiles;
    }

    // Update last position
    _lastLatitude = gpsData.latitude;
    _lastLongitude = gpsData.longitude;
    _lastTimestamp = gpsData.timestamp;

    // Emit updated state
    _emitState();

    // Check persistence trigger
    if (_milesSinceLastPersist >= persistIntervalMiles) {
      _milesSinceLastPersist = 0.0;
      persist();
    }
  }

  @override
  void resetTripOdometer() {
    _tripMiles = 0.0;
    _emitState();
    persist();
  }

  @override
  Future<void> persist() async {
    await _preferencesRepository.persistOdometer(_totalMiles, _tripMiles);
    _milesSinceLastPersist = 0.0;
  }

  /// Emits the current odometer state to listeners.
  void _emitState() {
    // Apply rollover to the display values (rounded to 1 decimal)
    var displayTotal = _roundToOneDecimal(_totalMiles);
    var displayTrip = _roundToOneDecimal(_tripMiles);

    // Handle edge case where rounding pushes value to rollover point
    if (displayTotal >= totalRolloverMiles) {
      displayTotal = 0.0;
    }
    if (displayTrip >= tripRolloverMiles) {
      displayTrip = 0.0;
    }

    _odometerStateController.add(OdometerState(
      totalMiles: displayTotal,
      tripMiles: displayTrip,
      hoursSinceService: _hoursSinceService,
    ));
  }

  /// Rounds a value to 1 decimal place.
  static double _roundToOneDecimal(double value) {
    return (value * 10).roundToDouble() / 10;
  }

  /// Calculates the distance between two GPS coordinates using the
  /// Haversine formula. Returns distance in miles.
  static double _haversineDistanceMiles(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMiles = 3958.8;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMiles * c;
  }

  /// Converts degrees to radians.
  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Disposes of stream controllers.
  void dispose() {
    _odometerStateController.close();
  }
}
