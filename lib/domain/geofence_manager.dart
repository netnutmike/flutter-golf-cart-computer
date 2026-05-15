/// Geofence manager for the Golf Cart Computer.
///
/// Calculates distance from home using the Haversine formula and manages
/// at-home status with hysteresis to prevent oscillation near the boundary.
///
/// Hysteresis band: ±50 meters around the configured radius.
/// - Entering home: distance ≤ radius - 50m
/// - Leaving home: distance > radius + 50m
library;

import 'dart:async';
import 'dart:math';

import 'package:golf_cart_computer/domain/models/geofence_state.dart';

/// Abstract interface for the geofence manager.
abstract class GeofenceManager {
  /// Stream of geofence state updates emitted on each position update.
  Stream<GeofenceState> get geofenceState;

  /// Updates the current position and recalculates geofence state.
  void updatePosition(double lat, double lon);

  /// Sets the home location to the given coordinates.
  void setHomeLocation(double lat, double lon);

  /// Clears the saved home location.
  void clearHomeLocation();

  /// Sets the geofence radius in meters.
  ///
  /// Must be between 100 and 5000 meters. Values outside this range
  /// are clamped to the nearest valid value.
  void setRadius(int radiusMeters);
}

/// Default implementation of [GeofenceManager].
///
/// Uses the Haversine formula for accurate great-circle distance calculation
/// and implements hysteresis to prevent rapid toggling of at-home status
/// when the device is near the geofence boundary.
class GeofenceManagerImpl implements GeofenceManager {
  /// Hysteresis band in meters applied to the radius.
  static const double hysteresisMeters = 50.0;

  /// Minimum allowed geofence radius in meters.
  static const int minRadius = 100;

  /// Maximum allowed geofence radius in meters.
  static const int maxRadius = 5000;

  /// Default geofence radius in meters.
  static const int defaultRadius = 500;

  /// Earth's mean radius in meters for Haversine calculation.
  static const double earthRadiusMeters = 6371000.0;

  final StreamController<GeofenceState> _stateController =
      StreamController<GeofenceState>.broadcast();

  double? _homeLatitude;
  double? _homeLongitude;
  int _fenceRadius = defaultRadius;
  bool _isAtHome = false;
  double _distanceFromHome = 0.0;

  @override
  Stream<GeofenceState> get geofenceState => _stateController.stream;

  @override
  void updatePosition(double lat, double lon) {
    if (_homeLatitude == null || _homeLongitude == null) {
      // No home location set — emit state with isAtHome = false.
      _isAtHome = false;
      _distanceFromHome = 0.0;
      _emitState();
      return;
    }

    _distanceFromHome = haversineDistance(
      lat,
      lon,
      _homeLatitude!,
      _homeLongitude!,
    );

    // Apply hysteresis logic.
    final enterThreshold = _fenceRadius - hysteresisMeters;
    final leaveThreshold = _fenceRadius + hysteresisMeters;

    if (_isAtHome) {
      // Currently at home — only leave if distance exceeds radius + 50m.
      if (_distanceFromHome > leaveThreshold) {
        _isAtHome = false;
      }
    } else {
      // Currently away — only enter if distance drops to radius - 50m or below.
      if (_distanceFromHome <= enterThreshold) {
        _isAtHome = true;
      }
    }

    _emitState();
  }

  @override
  void setHomeLocation(double lat, double lon) {
    _homeLatitude = lat;
    _homeLongitude = lon;
    // Reset at-home status; will be recalculated on next position update.
    _isAtHome = false;
    _distanceFromHome = 0.0;
    _emitState();
  }

  @override
  void clearHomeLocation() {
    _homeLatitude = null;
    _homeLongitude = null;
    _isAtHome = false;
    _distanceFromHome = 0.0;
    _emitState();
  }

  @override
  void setRadius(int radiusMeters) {
    _fenceRadius = radiusMeters.clamp(minRadius, maxRadius);
  }

  /// Calculates the great-circle distance between two points on Earth
  /// using the Haversine formula.
  ///
  /// Returns distance in meters.
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180.0;

  void _emitState() {
    _stateController.add(
      GeofenceState(
        homeLatitude: _homeLatitude,
        homeLongitude: _homeLongitude,
        isHomeSet: _homeLatitude != null && _homeLongitude != null,
        distanceFromHome: _distanceFromHome,
        isAtHome: _isAtHome,
        fenceRadius: _fenceRadius,
      ),
    );
  }

  /// Disposes of the stream controller.
  void dispose() {
    _stateController.close();
  }
}
