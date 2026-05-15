import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/domain/geofence_manager.dart';
import 'package:golf_cart_computer/domain/models/geofence_state.dart';

void main() {
  late GeofenceManagerImpl manager;

  setUp(() {
    manager = GeofenceManagerImpl();
  });

  tearDown(() {
    manager.dispose();
  });

  group('GeofenceManagerImpl', () {
    group('Haversine distance calculation', () {
      test('returns zero for identical points', () {
        final distance = GeofenceManagerImpl.haversineDistance(
          28.9, -81.9, 28.9, -81.9,
        );
        expect(distance, closeTo(0.0, 0.01));
      });

      test('calculates known distance correctly', () {
        // New York to Los Angeles is approximately 3,944 km
        final distance = GeofenceManagerImpl.haversineDistance(
          40.7128, -74.0060, // New York
          34.0522, -118.2437, // Los Angeles
        );
        // Allow 1% tolerance
        expect(distance, closeTo(3944000, 50000));
      });

      test('calculates short distance correctly', () {
        // Two points approximately 500 meters apart
        // At latitude 28.9°, 1 degree longitude ≈ 97,304 m
        // 500m ≈ 0.00514 degrees longitude
        final distance = GeofenceManagerImpl.haversineDistance(
          28.9, -81.9,
          28.9, -81.894860,
        );
        expect(distance, closeTo(500, 5));
      });
    });

    group('setHomeLocation', () {
      test('sets home coordinates and emits state', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        manager.setHomeLocation(28.9, -81.9);

        await Future<void>.delayed(Duration.zero);
        expect(states, hasLength(1));
        expect(states.last.homeLatitude, 28.9);
        expect(states.last.homeLongitude, -81.9);
        expect(states.last.isHomeSet, isTrue);
        expect(states.last.isAtHome, isFalse);
      });
    });

    group('clearHomeLocation', () {
      test('clears home and sets isAtHome to false', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        manager.setHomeLocation(28.9, -81.9);
        manager.clearHomeLocation();

        await Future<void>.delayed(Duration.zero);
        expect(states.last.homeLatitude, isNull);
        expect(states.last.homeLongitude, isNull);
        expect(states.last.isHomeSet, isFalse);
        expect(states.last.isAtHome, isFalse);
      });
    });

    group('updatePosition without home set', () {
      test('emits state with isAtHome false', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        manager.updatePosition(28.9, -81.9);

        await Future<void>.delayed(Duration.zero);
        expect(states.last.isAtHome, isFalse);
        expect(states.last.isHomeSet, isFalse);
        expect(states.last.distanceFromHome, 0.0);
      });
    });

    group('hysteresis logic', () {
      test('enters home when distance <= radius - 50m', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        // Set home at a known location
        manager.setHomeLocation(28.9, -81.9);

        // Update position to be exactly at home (0 meters away)
        manager.updatePosition(28.9, -81.9);

        await Future<void>.delayed(Duration.zero);
        expect(states.last.isAtHome, isTrue);
        expect(states.last.distanceFromHome, closeTo(0.0, 1.0));
      });

      test('does not leave home within hysteresis band', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        manager.setHomeLocation(28.9, -81.9);

        // First, get inside the fence (at home)
        manager.updatePosition(28.9, -81.9);
        await Future<void>.delayed(Duration.zero);
        expect(states.last.isAtHome, isTrue);

        // Move to a point within the hysteresis band (radius < d <= radius + 50m)
        // Default radius is 500m, so we need distance between 500 and 550m
        // At lat 28.9, 0.00475 degrees longitude ≈ 520m
        manager.updatePosition(28.9, -81.894680);
        await Future<void>.delayed(Duration.zero);

        // Should still be at home (within hysteresis band)
        expect(states.last.isAtHome, isTrue);
        expect(states.last.distanceFromHome, greaterThan(450));
        expect(states.last.distanceFromHome, lessThan(550));
      });

      test('leaves home when distance > radius + 50m', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        manager.setHomeLocation(28.9, -81.9);

        // First, get inside the fence
        manager.updatePosition(28.9, -81.9);
        await Future<void>.delayed(Duration.zero);
        expect(states.last.isAtHome, isTrue);

        // Move well outside the fence (> 550m with default 500m radius)
        // At lat 28.9, 0.006 degrees longitude ≈ 585m
        manager.updatePosition(28.9, -81.894000);
        await Future<void>.delayed(Duration.zero);

        expect(states.last.isAtHome, isFalse);
        expect(states.last.distanceFromHome, greaterThan(550));
      });

      test('does not enter home within hysteresis band from outside', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        manager.setHomeLocation(28.9, -81.9);

        // Start far away
        manager.updatePosition(28.9, -81.890000);
        await Future<void>.delayed(Duration.zero);
        expect(states.last.isAtHome, isFalse);

        // Move to within hysteresis band (between radius-50 and radius)
        // Need distance between 450 and 500m
        // At lat 28.9, 0.00463 degrees longitude ≈ 475m
        manager.updatePosition(28.9, -81.895130);
        await Future<void>.delayed(Duration.zero);

        // Should still be away (within hysteresis band, approaching from outside)
        expect(states.last.isAtHome, isFalse);
        expect(states.last.distanceFromHome, greaterThan(440));
        expect(states.last.distanceFromHome, lessThan(510));
      });

      test('enters home when distance drops to radius - 50m', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        manager.setHomeLocation(28.9, -81.9);

        // Start far away
        manager.updatePosition(28.9, -81.890000);
        await Future<void>.delayed(Duration.zero);
        expect(states.last.isAtHome, isFalse);

        // Move to within radius - 50m (< 450m with default 500m radius)
        // At lat 28.9, 0.004 degrees longitude ≈ 390m
        manager.updatePosition(28.9, -81.896000);
        await Future<void>.delayed(Duration.zero);

        expect(states.last.isAtHome, isTrue);
        expect(states.last.distanceFromHome, lessThan(450));
      });
    });

    group('setRadius', () {
      test('clamps radius to minimum 100m', () {
        manager.setRadius(50);
        manager.setHomeLocation(28.9, -81.9);
        // Verify by checking that the state reflects the clamped radius
        // We can't directly access _fenceRadius, but we can check via state
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);
        manager.updatePosition(28.9, -81.9);
        // Synchronous check after microtask
        Future<void>.delayed(Duration.zero).then((_) {
          expect(states.last.fenceRadius, 100);
        });
      });

      test('clamps radius to maximum 5000m', () async {
        manager.setRadius(6000);
        manager.setHomeLocation(28.9, -81.9);

        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);
        manager.updatePosition(28.9, -81.9);

        await Future<void>.delayed(Duration.zero);
        expect(states.last.fenceRadius, 5000);
      });

      test('accepts valid radius within range', () async {
        manager.setRadius(1000);
        manager.setHomeLocation(28.9, -81.9);

        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);
        manager.updatePosition(28.9, -81.9);

        await Future<void>.delayed(Duration.zero);
        expect(states.last.fenceRadius, 1000);
      });

      test('larger radius changes enter/leave thresholds', () async {
        manager.setRadius(1000); // radius=1000, enter at 950m, leave at 1050m
        manager.setHomeLocation(28.9, -81.9);

        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        // Position at ~600m away (within 1000m radius - 50m = 950m threshold)
        // At lat 28.9, 0.006 degrees longitude ≈ 585m
        manager.updatePosition(28.9, -81.894000);
        await Future<void>.delayed(Duration.zero);
        expect(states.last.isAtHome, isTrue);

        // Position at ~980m away (within hysteresis band: 950-1050m)
        // At lat 28.9, 0.01 degrees longitude ≈ 973m
        manager.updatePosition(28.9, -81.890000);
        await Future<void>.delayed(Duration.zero);
        // Still at home because we haven't exceeded 1050m
        expect(states.last.isAtHome, isTrue);
      });
    });

    group('stream emissions', () {
      test('emits state on each position update', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        manager.setHomeLocation(28.9, -81.9);
        manager.updatePosition(28.9, -81.9);
        manager.updatePosition(28.91, -81.9);
        manager.updatePosition(28.92, -81.9);

        await Future<void>.delayed(Duration.zero);
        // 1 from setHomeLocation + 3 from updatePosition
        expect(states, hasLength(4));
      });

      test('emits correct distance from home', () async {
        final states = <GeofenceState>[];
        manager.geofenceState.listen(states.add);

        manager.setHomeLocation(28.9, -81.9);
        manager.updatePosition(28.9, -81.9);

        await Future<void>.delayed(Duration.zero);
        expect(states.last.distanceFromHome, closeTo(0.0, 1.0));
      });
    });
  });
}
