/// Unit tests for [OdometerManager] implementation.
///
/// Tests cover distance accumulation gating, rollover behavior,
/// trip reset, persistence triggers, and position-based speed rejection.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/data/repositories/preferences_repository.dart';
import 'package:golf_cart_computer/domain/models/gps_data.dart';
import 'package:golf_cart_computer/domain/models/odometer_state.dart';
import 'package:golf_cart_computer/domain/odometer_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockPreferencesRepository extends Mock implements PreferencesRepository {}

void main() {
  late DefaultOdometerManager manager;
  late MockPreferencesRepository mockPrefs;

  setUp(() async {
    mockPrefs = MockPreferencesRepository();

    when(() => mockPrefs.loadOdometer()).thenAnswer(
      (_) async => const OdometerState(
        totalMiles: 0.0,
        tripMiles: 0.0,
        hoursSinceService: 0.0,
      ),
    );
    when(() => mockPrefs.persistOdometer(any(), any()))
        .thenAnswer((_) async {});

    manager = DefaultOdometerManager(preferencesRepository: mockPrefs);
    await manager.load();
  });

  tearDown(() {
    manager.dispose();
  });

  /// Creates a ProcessedGpsData with the given parameters.
  ProcessedGpsData makeGpsData({
    required double latitude,
    required double longitude,
    int speedMph = 5,
    double rawSpeedMph = 5.0,
    required DateTime timestamp,
    bool isValid = true,
  }) {
    return ProcessedGpsData(
      latitude: latitude,
      longitude: longitude,
      altitude: 0.0,
      speedMph: speedMph,
      rawSpeedMph: rawSpeedMph,
      headingDegrees: 0.0,
      cardinalDirection: 'N',
      satelliteCount: 8,
      hdop: 1.5,
      timestamp: timestamp,
      isValid: isValid,
    );
  }

  /// Helper: processes two positions that should accumulate distance.
  /// Returns the emitted OdometerState.
  Future<OdometerState> accumulateDistance(
    DefaultOdometerManager mgr, {
    DateTime? baseTime,
  }) async {
    final t = baseTime ?? DateTime(2024, 1, 1, 12, 0, 0);
    final completer = Completer<OdometerState>();
    final sub = mgr.odometerState.listen((state) {
      if (!completer.isCompleted) completer.complete(state);
    });

    mgr.processPosition(makeGpsData(
      latitude: 28.900000,
      longitude: -81.900000,
      speedMph: 10,
      timestamp: t,
    ));
    mgr.processPosition(makeGpsData(
      latitude: 28.901000,
      longitude: -81.900000,
      speedMph: 10,
      timestamp: t.add(const Duration(seconds: 10)),
    ));

    final state = await completer.future;
    await sub.cancel();
    return state;
  }

  group('OdometerManager - Loading', () {
    test('loads persisted values on startup', () async {
      final prefs = MockPreferencesRepository();
      when(() => prefs.loadOdometer()).thenAnswer(
        (_) async => const OdometerState(
          totalMiles: 1234.5,
          tripMiles: 56.7,
          hoursSinceService: 10.0,
        ),
      );
      when(() => prefs.persistOdometer(any(), any()))
          .thenAnswer((_) async {});

      final mgr = DefaultOdometerManager(preferencesRepository: prefs);

      final future = expectLater(
        mgr.odometerState,
        emits(predicate<OdometerState>(
          (s) => s.totalMiles == 1234.5 && s.tripMiles == 56.7,
        )),
      );

      await mgr.load();
      await future;
      mgr.dispose();
    });

    test('initializes to zero when no persisted data', () async {
      final prefs = MockPreferencesRepository();
      when(() => prefs.loadOdometer()).thenAnswer(
        (_) async => const OdometerState(
          totalMiles: 0.0,
          tripMiles: 0.0,
          hoursSinceService: 0.0,
        ),
      );

      final mgr = DefaultOdometerManager(preferencesRepository: prefs);

      final future = expectLater(
        mgr.odometerState,
        emits(predicate<OdometerState>(
          (s) => s.totalMiles == 0.0 && s.tripMiles == 0.0,
        )),
      );

      await mgr.load();
      await future;
      mgr.dispose();
    });
  });

  group('OdometerManager - Doppler Speed Gating', () {
    test('does not accumulate distance when filtered speed is 0', () async {
      final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

      // Set up a listener to capture any emissions after load
      final postLoadStates = <OdometerState>[];
      final sub = manager.odometerState.listen(postLoadStates.add);

      // First position (establishes baseline)
      manager.processPosition(makeGpsData(
        latitude: 28.9,
        longitude: -81.9,
        speedMph: 5,
        timestamp: baseTime,
      ));

      // Second position with speed = 0 (should not accumulate)
      manager.processPosition(makeGpsData(
        latitude: 28.901,
        longitude: -81.9,
        speedMph: 0,
        rawSpeedMph: 0.0,
        timestamp: baseTime.add(const Duration(seconds: 5)),
      ));

      // Give time for any async delivery
      await Future<void>.delayed(Duration.zero);

      // No state emission since no distance accumulated
      expect(postLoadStates, isEmpty);
      await sub.cancel();
    });

    test('accumulates distance when filtered speed > 0', () async {
      final state = await accumulateDistance(manager);
      expect(state.totalMiles, greaterThan(0.0));
      expect(state.tripMiles, greaterThan(0.0));
    });
  });

  group('OdometerManager - Minimum Distance Threshold', () {
    test('does not accumulate when distance < 2.6 feet with Doppler', () async {
      final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

      final postLoadStates = <OdometerState>[];
      final sub = manager.odometerState.listen(postLoadStates.add);

      // First position
      manager.processPosition(makeGpsData(
        latitude: 28.9000000,
        longitude: -81.9000000,
        speedMph: 5,
        rawSpeedMph: 5.0,
        timestamp: baseTime,
      ));

      // Second position very close (< 0.0005 miles = 2.6 feet)
      manager.processPosition(makeGpsData(
        latitude: 28.9000005,
        longitude: -81.9000000,
        speedMph: 5,
        rawSpeedMph: 5.0,
        timestamp: baseTime.add(const Duration(seconds: 1)),
      ));

      await Future<void>.delayed(Duration.zero);
      expect(postLoadStates, isEmpty);
      await sub.cancel();
    });

    test('uses larger threshold (10 feet) when no Doppler speed', () async {
      final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

      final postLoadStates = <OdometerState>[];
      final sub = manager.odometerState.listen(postLoadStates.add);

      // First position
      manager.processPosition(makeGpsData(
        latitude: 28.9000000,
        longitude: -81.9000000,
        speedMph: 5,
        rawSpeedMph: 0.0,
        timestamp: baseTime,
      ));

      // Second position: ~5 feet apart (< 10 feet threshold)
      manager.processPosition(makeGpsData(
        latitude: 28.9000150,
        longitude: -81.9000000,
        speedMph: 5,
        rawSpeedMph: 0.0,
        timestamp: baseTime.add(const Duration(seconds: 5)),
      ));

      await Future<void>.delayed(Duration.zero);
      expect(postLoadStates, isEmpty);
      await sub.cancel();
    });
  });

  group('OdometerManager - Position-Based Speed Rejection', () {
    test('rejects position update when implied speed > 30 mph', () async {
      final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

      final postLoadStates = <OdometerState>[];
      final sub = manager.odometerState.listen(postLoadStates.add);

      // First position
      manager.processPosition(makeGpsData(
        latitude: 28.900000,
        longitude: -81.900000,
        speedMph: 5,
        timestamp: baseTime,
      ));

      // Second position very far away in short time (implies > 30 mph)
      // ~0.069 miles in 1 second = ~248 mph
      manager.processPosition(makeGpsData(
        latitude: 28.901000,
        longitude: -81.900000,
        speedMph: 5,
        timestamp: baseTime.add(const Duration(seconds: 1)),
      ));

      await Future<void>.delayed(Duration.zero);
      expect(postLoadStates, isEmpty);
      await sub.cancel();
    });

    test('accepts position update when implied speed <= 30 mph', () async {
      final state = await accumulateDistance(manager);
      expect(state.totalMiles, greaterThan(0.0));
    });
  });

  group('OdometerManager - Rollover', () {
    test('total odometer rolls over at 100,000 miles', () async {
      final prefs = MockPreferencesRepository();
      when(() => prefs.loadOdometer()).thenAnswer(
        (_) async => const OdometerState(
          totalMiles: 99999.9,
          tripMiles: 0.0,
          hoursSinceService: 0.0,
        ),
      );
      when(() => prefs.persistOdometer(any(), any()))
          .thenAnswer((_) async {});

      final mgr = DefaultOdometerManager(preferencesRepository: prefs);
      await mgr.load();

      final state = await accumulateDistance(mgr);

      // Should have rolled over (total < 100,000)
      expect(state.totalMiles, lessThan(100000.0));
      expect(state.totalMiles, lessThan(1.0));
      mgr.dispose();
    });

    test('trip odometer rolls over at 10,000 miles', () async {
      final prefs = MockPreferencesRepository();
      when(() => prefs.loadOdometer()).thenAnswer(
        (_) async => const OdometerState(
          totalMiles: 50000.0,
          tripMiles: 9999.9,
          hoursSinceService: 0.0,
        ),
      );
      when(() => prefs.persistOdometer(any(), any()))
          .thenAnswer((_) async {});

      final mgr = DefaultOdometerManager(preferencesRepository: prefs);
      await mgr.load();

      final state = await accumulateDistance(mgr);

      // Trip should have rolled over
      expect(state.tripMiles, lessThan(10000.0));
      expect(state.tripMiles, lessThan(1.0));
      mgr.dispose();
    });
  });

  group('OdometerManager - Trip Reset', () {
    test('resetTripOdometer sets trip to 0.0', () async {
      // First accumulate some distance
      final stateAfterAccum = await accumulateDistance(manager);
      expect(stateAfterAccum.tripMiles, greaterThan(0.0));
      final totalBeforeReset = stateAfterAccum.totalMiles;

      // Set up listener for reset emission
      final completer = Completer<OdometerState>();
      final sub = manager.odometerState.listen((s) {
        if (!completer.isCompleted) completer.complete(s);
      });

      manager.resetTripOdometer();

      final stateAfterReset = await completer.future;
      expect(stateAfterReset.tripMiles, 0.0);
      expect(stateAfterReset.totalMiles, totalBeforeReset);
      await sub.cancel();
    });

    test('resetTripOdometer does not affect total', () async {
      final prefs = MockPreferencesRepository();
      when(() => prefs.loadOdometer()).thenAnswer(
        (_) async => const OdometerState(
          totalMiles: 500.0,
          tripMiles: 25.0,
          hoursSinceService: 10.0,
        ),
      );
      when(() => prefs.persistOdometer(any(), any()))
          .thenAnswer((_) async {});

      final mgr = DefaultOdometerManager(preferencesRepository: prefs);
      await mgr.load();

      final completer = Completer<OdometerState>();
      final sub = mgr.odometerState.listen((s) {
        if (!completer.isCompleted) completer.complete(s);
      });

      mgr.resetTripOdometer();

      final state = await completer.future;
      expect(state.totalMiles, 500.0);
      expect(state.tripMiles, 0.0);
      await sub.cancel();
      mgr.dispose();
    });

    test('resetTripOdometer triggers persistence', () async {
      manager.resetTripOdometer();
      // Allow async persist to complete
      await Future<void>.delayed(Duration.zero);
      verify(() => mockPrefs.persistOdometer(any(), any())).called(1);
    });
  });

  group('OdometerManager - Persistence Triggers', () {
    test('persists every 0.5 miles', () async {
      final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

      // We need to accumulate 0.5 miles. Each step is ~0.069 miles.
      // So we need about 8 steps (8 * 0.069 = 0.552 miles).
      double lat = 28.900000;
      for (int i = 0; i < 9; i++) {
        manager.processPosition(makeGpsData(
          latitude: lat,
          longitude: -81.900000,
          speedMph: 15,
          timestamp: baseTime.add(Duration(seconds: i * 15)),
        ));
        lat += 0.001; // ~0.069 miles per step
      }

      // Allow async persist to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Should have triggered persistence at least once
      verify(() => mockPrefs.persistOdometer(any(), any())).called(greaterThan(0));
    });
  });

  group('OdometerManager - Invalid Data Handling', () {
    test('does not accumulate when GPS data is invalid', () async {
      final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

      final postLoadStates = <OdometerState>[];
      final sub = manager.odometerState.listen(postLoadStates.add);

      manager.processPosition(makeGpsData(
        latitude: 28.900000,
        longitude: -81.900000,
        speedMph: 5,
        timestamp: baseTime,
        isValid: false,
      ));

      manager.processPosition(makeGpsData(
        latitude: 28.901000,
        longitude: -81.900000,
        speedMph: 5,
        timestamp: baseTime.add(const Duration(seconds: 10)),
        isValid: false,
      ));

      await Future<void>.delayed(Duration.zero);
      expect(postLoadStates, isEmpty);
      await sub.cancel();
    });
  });

  group('OdometerManager - Persist Method', () {
    test('persist calls repository with current values', () async {
      await manager.persist();
      verify(() => mockPrefs.persistOdometer(0.0, 0.0)).called(1);
    });
  });
}
