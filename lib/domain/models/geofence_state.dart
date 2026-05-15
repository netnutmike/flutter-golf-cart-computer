/// Geofence domain models for the Golf Cart Computer.
///
/// Contains state for home location geofencing with hysteresis-based
/// at-home detection.
library;

/// Current state of the geofence system.
class GeofenceState {
  /// Home location latitude, or null if not set.
  final double? homeLatitude;

  /// Home location longitude, or null if not set.
  final double? homeLongitude;

  /// Whether a home location has been configured.
  final bool isHomeSet;

  /// Current distance from home in meters.
  final double distanceFromHome;

  /// Whether the device is currently within the home geofence.
  /// Defaults to false when no home location is set.
  final bool isAtHome;

  /// Configured geofence radius in meters (100-5000, default 500).
  final int fenceRadius;

  const GeofenceState({
    this.homeLatitude,
    this.homeLongitude,
    required this.isHomeSet,
    required this.distanceFromHome,
    required this.isAtHome,
    required this.fenceRadius,
  });
}
