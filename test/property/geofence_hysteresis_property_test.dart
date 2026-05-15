import 'dart:async';
import 'dart:math';

import 'package:glados/glados.dart';
import 'package:golf_cart_computer/domain/geofence_manager.dart';
import 'package:golf_cart_computer/domain/models/geofence_state.dart';

/// Custom generators for geofence hysteresis property tests.
extension GeofenceGenerators on Any {
  /// Generates a valid geofence radius in meters (100-5000).
  Generator<int> get fenceRadius => intInRange(100, 5001);

  /// Generates a latitude in a realistic range (-85 to 85 degrees).
  Generator<double> get latitude => doubleInRange(-85.0, 85.0);

  /// Generates a longitude in a realistic range (-180 to 180 degrees).
  Generator<double> get longitude => doubleInRange(-180.0, 180.0);

  /// Generates a distance factor well inside the enter threshold (0.0 to 0.8).
  /// When multiplied by (radius - 50), gives a distance clearly inside.
  Generator<double> get insideFactor => doubleInRange(0.0, 0.8);

  /// Generates a distance factor well outside the leave threshold (1.1 to 2.0).
  /// When multiplied by (radius + 50), gives a distance clearly outside.
  Generator<double> get outsideFactor => doubleInRange(1.1, 2.0);

  /// Generates a bearing angle in degrees (0 to 360).
  Generator<double> get bearing => doubleInRange(0.0, 360.0);
}

/// Calculates a GPS position at a given distance and bearing from a start point.
/// Uses the inverse Haversine formula.
/// [startLat], [startLon] in degrees, [distanceMeters] in meters,
/// [bearingDeg] in degrees.
/// Returns (latitude, longitude) in degrees.
(double, double) positionAtDistance(
  double startLat,
  double startLon,
  double distanceMeters,
  double bearingDeg,
) {
  const earthRadius = 6371000.0;
  final lat1 = startLat * pi / 180.0;
  final lon1 = startLon * pi / 180.0;
  final brng = bearingDeg * pi / 180.0;
  final d = distanceMeters / earthRadius;

  final lat2 = asin(
    sin(lat1) * cos(d) + cos(lat1) * sin(d) * cos(brng),
  );
  final lon2 = lon1 +
      atan2(
        sin(brng) * sin(d) * cos(lat1),
        cos(d) - sin(lat1) * sin(lat2),
      );

  return (lat2 * 180.0 / pi, lon2 * 180.0 / pi);
}

void main() {
  group('Property 18: Geofence status determination with hysteresis', () {
    // ---------------------------------------------------------------
    // at_home transitions to true only when distance ≤ radius - 50m
    // ---------------------------------------------------------------

    /// **Validates: Requirements 9.4, 9.5, 9.6**
    ///
    /// For any home location and configured radius, when the device is
    /// currently away and moves to a position at distance ≤ radius - 50m,
    /// the at_home status should transition to true.
    Glados3(any.fenceRadius, any.latitude, any.bearing).test(
      'at_home transitions to true when distance drops to radius - 50m or below',
      (radius, homeLat, bearing) async {
        // Use a fixed home longitude to keep things simple
        const homeLon = 10.0;

        final manager = GeofenceManagerImpl();
        manager.setHomeLocation(homeLat, homeLon);
        manager.setRadius(radius);

        final clampedRadius = radius.clamp(
          GeofenceManagerImpl.minRadius,
          GeofenceManagerImpl.maxRadius,
        );
        final enterThreshold = clampedRadius - GeofenceManagerImpl.hysteresisMeters;

        // Start far away to ensure we're in "away" state
        final farDistance = (clampedRadius + 200).toDouble();
        final (farLat, farLon) = positionAtDistance(homeLat, homeLon, farDistance, bearing);
        manager.updatePosition(farLat, farLon);

        // Collect the next state emission
        GeofenceState? lastState;
        final sub = manager.geofenceState.listen((state) {
          lastState = state;
        });

        // Move to a position within the enter threshold
        final enterDistance = enterThreshold * 0.9; // Clearly inside
        final (enterLat, enterLon) = positionAtDistance(
          homeLat, homeLon, enterDistance > 0 ? enterDistance : 0, bearing,
        );
        manager.updatePosition(enterLat, enterLon);

        // Allow stream to propagate
        await Future<void>.delayed(Duration.zero);

        expect(lastState, isNotNull);
        expect(lastState!.isAtHome, isTrue,
            reason: 'at_home should be true when distance (${enterDistance.toStringAsFixed(1)}m) '
                '≤ enter threshold (${enterThreshold.toStringAsFixed(1)}m)');

        await sub.cancel();
        manager.dispose();
      },
    );

    // ---------------------------------------------------------------
    // at_home transitions to false only when distance > radius + 50m
    // ---------------------------------------------------------------

    /// **Validates: Requirements 9.4, 9.5, 9.6**
    ///
    /// For any home location and configured radius, when the device is
    /// currently at home and moves to a position at distance > radius + 50m,
    /// the at_home status should transition to false.
    Glados3(any.fenceRadius, any.latitude, any.bearing).test(
      'at_home transitions to false only when distance exceeds radius + 50m',
      (radius, homeLat, bearing) async {
        const homeLon = 10.0;

        final manager = GeofenceManagerImpl();
        manager.setHomeLocation(homeLat, homeLon);
        manager.setRadius(radius);

        final clampedRadius = radius.clamp(
          GeofenceManagerImpl.minRadius,
          GeofenceManagerImpl.maxRadius,
        );
        final leaveThreshold = clampedRadius + GeofenceManagerImpl.hysteresisMeters;

        // First, move inside to establish at_home = true
        final enterThreshold = clampedRadius - GeofenceManagerImpl.hysteresisMeters;
        final enterDistance = enterThreshold * 0.5;
        final (enterLat, enterLon) = positionAtDistance(
          homeLat, homeLon, enterDistance > 0 ? enterDistance : 0, bearing,
        );
        manager.updatePosition(enterLat, enterLon);

        // Now move outside the leave threshold
        GeofenceState? lastState;
        final sub = manager.geofenceState.listen((state) {
          lastState = state;
        });

        final leaveDistance = leaveThreshold + 100.0; // Clearly outside
        final (leaveLat, leaveLon) = positionAtDistance(
          homeLat, homeLon, leaveDistance, bearing,
        );
        manager.updatePosition(leaveLat, leaveLon);

        await Future<void>.delayed(Duration.zero);

        expect(lastState, isNotNull);
        expect(lastState!.isAtHome, isFalse,
            reason: 'at_home should be false when distance (${leaveDistance.toStringAsFixed(1)}m) '
                '> leave threshold (${leaveThreshold.toStringAsFixed(1)}m)');

        await sub.cancel();
        manager.dispose();
      },
    );

    // ---------------------------------------------------------------
    // No oscillation within hysteresis band
    // ---------------------------------------------------------------

    /// **Validates: Requirements 9.4, 9.5, 9.6**
    ///
    /// For any home location and configured radius, when the device is
    /// within the hysteresis band (radius - 50m < distance ≤ radius + 50m),
    /// the at_home status should NOT change from its current value.
    /// This tests that once at_home is true, it stays true within the band.
    Glados3(any.fenceRadius, any.latitude, any.bearing).test(
      'no oscillation: at_home stays true within hysteresis band',
      (radius, homeLat, bearing) async {
        const homeLon = 10.0;

        final manager = GeofenceManagerImpl();
        manager.setHomeLocation(homeLat, homeLon);
        manager.setRadius(radius);

        final clampedRadius = radius.clamp(
          GeofenceManagerImpl.minRadius,
          GeofenceManagerImpl.maxRadius,
        );
        final enterThreshold = clampedRadius - GeofenceManagerImpl.hysteresisMeters;

        // First, move inside to establish at_home = true
        final enterDistance = enterThreshold * 0.5;
        final (enterLat, enterLon) = positionAtDistance(
          homeLat, homeLon, enterDistance > 0 ? enterDistance : 0, bearing,
        );
        manager.updatePosition(enterLat, enterLon);

        // Now move to a position within the hysteresis band
        // (between radius - 50m and radius + 50m)
        final bandDistance = clampedRadius.toDouble(); // Exactly at radius (in the band)

        GeofenceState? lastState;
        final sub = manager.geofenceState.listen((state) {
          lastState = state;
        });

        final (bandLat, bandLon) = positionAtDistance(
          homeLat, homeLon, bandDistance, bearing,
        );
        manager.updatePosition(bandLat, bandLon);

        await Future<void>.delayed(Duration.zero);

        expect(lastState, isNotNull);
        expect(lastState!.isAtHome, isTrue,
            reason: 'at_home should remain true within hysteresis band '
                '(distance=${bandDistance.toStringAsFixed(1)}m, '
                'radius=$clampedRadius, band=${enterThreshold.toStringAsFixed(1)}-'
                '${(clampedRadius + GeofenceManagerImpl.hysteresisMeters).toStringAsFixed(1)}m)');

        await sub.cancel();
        manager.dispose();
      },
    );

    /// **Validates: Requirements 9.4, 9.5, 9.6**
    ///
    /// For any home location and configured radius, when the device is
    /// within the hysteresis band and currently away (at_home = false),
    /// the at_home status should NOT change to true.
    Glados3(any.fenceRadius, any.latitude, any.bearing).test(
      'no oscillation: at_home stays false within hysteresis band',
      (radius, homeLat, bearing) async {
        const homeLon = 10.0;

        final manager = GeofenceManagerImpl();
        manager.setHomeLocation(homeLat, homeLon);
        manager.setRadius(radius);

        final clampedRadius = radius.clamp(
          GeofenceManagerImpl.minRadius,
          GeofenceManagerImpl.maxRadius,
        );
        final leaveThreshold = clampedRadius + GeofenceManagerImpl.hysteresisMeters;

        // Start far away to ensure at_home = false
        final farDistance = leaveThreshold + 200.0;
        final (farLat, farLon) = positionAtDistance(homeLat, homeLon, farDistance, bearing);
        manager.updatePosition(farLat, farLon);

        // Now move to a position within the hysteresis band
        // (between radius - 50m and radius + 50m) but above enter threshold
        final enterThreshold = clampedRadius - GeofenceManagerImpl.hysteresisMeters;
        // Pick a distance just above the enter threshold but below leave threshold
        final bandDistance = (enterThreshold + clampedRadius.toDouble()) / 2.0 + 1.0;

        GeofenceState? lastState;
        final sub = manager.geofenceState.listen((state) {
          lastState = state;
        });

        final (bandLat, bandLon) = positionAtDistance(
          homeLat, homeLon, bandDistance, bearing,
        );
        manager.updatePosition(bandLat, bandLon);

        await Future<void>.delayed(Duration.zero);

        expect(lastState, isNotNull);
        expect(lastState!.isAtHome, isFalse,
            reason: 'at_home should remain false within hysteresis band '
                '(distance=${bandDistance.toStringAsFixed(1)}m, '
                'enter threshold=${enterThreshold.toStringAsFixed(1)}m, '
                'leave threshold=${leaveThreshold.toStringAsFixed(1)}m)');

        await sub.cancel();
        manager.dispose();
      },
    );
  });
}
