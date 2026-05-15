import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

/// Abstract interface for location/GPS services.
///
/// Provides a stream of position updates, current position access,
/// permission management, and service availability checks.
abstract class LocationService {
  /// Stream of GPS position updates at a 1-second interval.
  Stream<Position> get positionStream;

  /// Returns the current device position, or null if unavailable.
  Future<Position?> get currentPosition;

  /// Requests location permission from the user.
  ///
  /// Returns the resulting [LocationPermission] status.
  Future<LocationPermission> requestPermission();

  /// Whether the device's location service is currently enabled.
  Future<bool> get isServiceEnabled;
}

/// Geolocator-based implementation of [LocationService].
///
/// Uses the geolocator plugin for cross-platform GPS access with a
/// 1-second update interval. Permission requests are handled via
/// the permission_handler package for unified cross-platform behavior.
///
/// On iOS, background location updates are supported via the `location`
/// background mode declared in Info.plist.
class GeolocatorLocationService implements LocationService {
  Stream<Position>? _positionStream;

  @override
  Stream<Position> get positionStream {
    _positionStream ??= Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    );
    return _positionStream!;
  }

  @override
  Future<Position?> get currentPosition async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<LocationPermission> requestPermission() async {
    // Use permission_handler for unified cross-platform permission requests.
    final status =
        await permission_handler.Permission.locationWhenInUse.request();

    // Map permission_handler status back to geolocator's LocationPermission.
    return _mapPermissionStatus(status);
  }

  @override
  Future<bool> get isServiceEnabled => Geolocator.isLocationServiceEnabled();

  /// Platform-appropriate location settings with 1-second update interval.
  LocationSettings get _locationSettings {
    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      intervalDuration: const Duration(seconds: 1),
      distanceFilter: 0,
      // Keep GPS active in background for odometer and geofence.
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: 'Golf Cart Computer',
        notificationText: 'GPS tracking active',
        enableWakeLock: true,
      ),
    );
  }

  /// Maps a [permission_handler.PermissionStatus] to a [LocationPermission].
  LocationPermission _mapPermissionStatus(
    permission_handler.PermissionStatus status,
  ) {
    switch (status) {
      case permission_handler.PermissionStatus.granted:
        return LocationPermission.whileInUse;
      case permission_handler.PermissionStatus.denied:
        return LocationPermission.denied;
      case permission_handler.PermissionStatus.permanentlyDenied:
        return LocationPermission.deniedForever;
      case permission_handler.PermissionStatus.restricted:
        return LocationPermission.denied;
      case permission_handler.PermissionStatus.limited:
        return LocationPermission.whileInUse;
      case permission_handler.PermissionStatus.provisional:
        return LocationPermission.whileInUse;
    }
  }
}
