/// Unit tests for [PreferencesRepository] implementation.
///
/// Tests cover loading defaults, debounce behavior, reset preserving
/// operational data, and corrupted data handling.
library;

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:golf_cart_computer/data/repositories/preferences_repository.dart';

void main() {
  late SharedPreferencesRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = SharedPreferencesRepository(prefs);
  });

  group('loadPreferences', () {
    test('returns all defaults when no data exists', () async {
      final prefs = await repository.loadPreferences();

      expect(prefs.dayBrightness, 7);
      expect(prefs.nightBrightness, 3);
      expect(prefs.speakerVolume, 10);
      expect(prefs.flipScreen, false);
      expect(prefs.backlightTimeoutMinutes, 5);
      expect(prefs.temperatureOffset, 0);
      expect(prefs.serviceIntervalHours, 100);
      expect(prefs.gciDeviceAddress, isNull);
      expect(prefs.homeLatitude, isNull);
      expect(prefs.homeLongitude, isNull);
      expect(prefs.homeFenceRadiusMeters, 500);
      expect(prefs.meshtasticEnabled, false);
      expect(prefs.meshtasticDeviceId, isNull);
    });

    test('loads persisted values correctly', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.dayBrightness: 9,
        PreferenceKeys.nightBrightness: 1,
        PreferenceKeys.speakerVolume: 15,
        PreferenceKeys.flipScreen: true,
        PreferenceKeys.backlightTimeoutMinutes: 30,
        PreferenceKeys.temperatureOffset: -5,
        PreferenceKeys.serviceIntervalHours: 200,
        PreferenceKeys.gciDeviceAddress: 'AA:BB:CC:DD:EE:FF',
        PreferenceKeys.homeLatitude: 28.9,
        PreferenceKeys.homeLongitude: -81.9,
        PreferenceKeys.homeFenceRadiusMeters: 1000,
        PreferenceKeys.meshtasticEnabled: true,
        PreferenceKeys.meshtasticDeviceId: 'device_1234',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesRepository(prefs);

      final loaded = await repo.loadPreferences();

      expect(loaded.dayBrightness, 9);
      expect(loaded.nightBrightness, 1);
      expect(loaded.speakerVolume, 15);
      expect(loaded.flipScreen, true);
      expect(loaded.backlightTimeoutMinutes, 30);
      expect(loaded.temperatureOffset, -5);
      expect(loaded.serviceIntervalHours, 200);
      expect(loaded.gciDeviceAddress, 'AA:BB:CC:DD:EE:FF');
      expect(loaded.homeLatitude, 28.9);
      expect(loaded.homeLongitude, -81.9);
      expect(loaded.homeFenceRadiusMeters, 1000);
      expect(loaded.meshtasticEnabled, true);
      expect(loaded.meshtasticDeviceId, 'device_1234');
    });

    test('returns defaults for out-of-range integer values', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.dayBrightness: 15, // max is 10
        PreferenceKeys.nightBrightness: -1, // min is 0
        PreferenceKeys.speakerVolume: 25, // max is 20
        PreferenceKeys.backlightTimeoutMinutes: 100, // max is 60
        PreferenceKeys.temperatureOffset: -30, // min is -20
        PreferenceKeys.serviceIntervalHours: 0, // min is 1
        PreferenceKeys.homeFenceRadiusMeters: 50, // min is 100
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesRepository(prefs);

      final loaded = await repo.loadPreferences();

      expect(loaded.dayBrightness, 7);
      expect(loaded.nightBrightness, 3);
      expect(loaded.speakerVolume, 10);
      expect(loaded.backlightTimeoutMinutes, 5);
      expect(loaded.temperatureOffset, 0);
      expect(loaded.serviceIntervalHours, 100);
      expect(loaded.homeFenceRadiusMeters, 500);
    });

    test('accepts boundary values', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.dayBrightness: 0,
        PreferenceKeys.nightBrightness: 10,
        PreferenceKeys.speakerVolume: 0,
        PreferenceKeys.backlightTimeoutMinutes: 60,
        PreferenceKeys.temperatureOffset: -20,
        PreferenceKeys.serviceIntervalHours: 500,
        PreferenceKeys.homeFenceRadiusMeters: 5000,
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesRepository(prefs);

      final loaded = await repo.loadPreferences();

      expect(loaded.dayBrightness, 0);
      expect(loaded.nightBrightness, 10);
      expect(loaded.speakerVolume, 0);
      expect(loaded.backlightTimeoutMinutes, 60);
      expect(loaded.temperatureOffset, -20);
      expect(loaded.serviceIntervalHours, 500);
      expect(loaded.homeFenceRadiusMeters, 5000);
    });
  });

  group('savePreference', () {
    test('saves non-debounced values immediately', () async {
      await repository.savePreference(PreferenceKeys.flipScreen, true);
      await repository.savePreference(
        PreferenceKeys.gciDeviceAddress,
        'AA:BB:CC:DD:EE:FF',
      );
      await repository.savePreference(PreferenceKeys.meshtasticEnabled, true);

      final loaded = await repository.loadPreferences();
      expect(loaded.flipScreen, true);
      expect(loaded.gciDeviceAddress, 'AA:BB:CC:DD:EE:FF');
      expect(loaded.meshtasticEnabled, true);
    });

    test('debounces slider/spinner values for 2 seconds', () async {
      // Use fake async to control time
      await runAsync(() async {
        await repository.savePreference(PreferenceKeys.dayBrightness, 9);

        // Value should not be persisted yet (debounced)
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt(PreferenceKeys.dayBrightness), isNull);
      });
    });

    test('debounced value is written after 2 seconds', () {
      FakeAsync().run((async) {
        repository.savePreference(PreferenceKeys.dayBrightness, 9);

        // Advance past debounce duration
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        // Now the value should be persisted
        SharedPreferences.getInstance().then((prefs) {
          expect(prefs.getInt(PreferenceKeys.dayBrightness), 9);
        });

        async.flushMicrotasks();
      });
    });

    test('rapid debounced writes only persist the last value', () {
      FakeAsync().run((async) {
        repository.savePreference(PreferenceKeys.speakerVolume, 5);
        async.elapse(const Duration(milliseconds: 500));
        repository.savePreference(PreferenceKeys.speakerVolume, 8);
        async.elapse(const Duration(milliseconds: 500));
        repository.savePreference(PreferenceKeys.speakerVolume, 12);

        // Advance past debounce from last write
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();

        SharedPreferences.getInstance().then((prefs) {
          expect(prefs.getInt(PreferenceKeys.speakerVolume), 12);
        });

        async.flushMicrotasks();
      });
    });

    test('saves null value by removing the key', () async {
      // First set a value
      await repository.savePreference(
        PreferenceKeys.gciDeviceAddress,
        'AA:BB:CC:DD:EE:FF',
      );
      // Then clear it
      await repository.savePreference(PreferenceKeys.gciDeviceAddress, null);

      final loaded = await repository.loadPreferences();
      expect(loaded.gciDeviceAddress, isNull);
    });

    test('throws for unsupported value types', () async {
      expect(
        () async =>
            repository.savePreference(PreferenceKeys.flipScreen, [1, 2]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('resetAllPreferences', () {
    test('clears all user-configurable preferences', () async {
      // Set some preferences
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.dayBrightness: 9,
        PreferenceKeys.nightBrightness: 1,
        PreferenceKeys.speakerVolume: 15,
        PreferenceKeys.flipScreen: true,
        PreferenceKeys.gciDeviceAddress: 'AA:BB:CC:DD:EE:FF',
        PreferenceKeys.meshtasticEnabled: true,
        PreferenceKeys.meshtasticDeviceId: 'device_1234',
        PreferenceKeys.odometerTotal: 1234.5,
        PreferenceKeys.odometerTrip: 56.7,
        PreferenceKeys.drivingHours: 89.0,
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesRepository(prefs);

      await repo.resetAllPreferences();

      // User preferences should be reset to defaults
      final loaded = await repo.loadPreferences();
      expect(loaded.dayBrightness, 7);
      expect(loaded.nightBrightness, 3);
      expect(loaded.speakerVolume, 10);
      expect(loaded.flipScreen, false);
      expect(loaded.gciDeviceAddress, isNull);
      expect(loaded.meshtasticEnabled, false);
      expect(loaded.meshtasticDeviceId, isNull);
    });

    test('preserves operational data (odometer, hours)', () async {
      SharedPreferences.setMockInitialValues({
        PreferenceKeys.dayBrightness: 9,
        PreferenceKeys.odometerTotal: 1234.5,
        PreferenceKeys.odometerTrip: 56.7,
        PreferenceKeys.drivingHours: 89.0,
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPreferencesRepository(prefs);

      await repo.resetAllPreferences();

      // Operational data should be preserved
      final odometer = await repo.loadOdometer();
      expect(odometer.totalMiles, 1234.5);
      expect(odometer.tripMiles, 56.7);

      final hours = await repo.loadDrivingHours();
      expect(hours, 89.0);
    });

    test('cancels pending debounced writes', () {
      FakeAsync().run((async) {
        // Start a debounced write
        repository.savePreference(PreferenceKeys.dayBrightness, 9);

        // Reset before debounce fires
        repository.resetAllPreferences();

        // Advance past debounce duration
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();

        // The debounced write should not have fired
        SharedPreferences.getInstance().then((prefs) {
          expect(prefs.getInt(PreferenceKeys.dayBrightness), isNull);
        });

        async.flushMicrotasks();
      });
    });
  });

  group('persistOdometer / loadOdometer', () {
    test('persists and loads odometer values', () async {
      await repository.persistOdometer(1234.5, 56.7);

      final state = await repository.loadOdometer();
      expect(state.totalMiles, 1234.5);
      expect(state.tripMiles, 56.7);
    });

    test('returns zeros when no data exists', () async {
      final state = await repository.loadOdometer();
      expect(state.totalMiles, 0.0);
      expect(state.tripMiles, 0.0);
      expect(state.hoursSinceService, 0.0);
    });

    test('loads driving hours as part of odometer state', () async {
      await repository.persistDrivingHours(45.3);
      await repository.persistOdometer(100.0, 10.0);

      final state = await repository.loadOdometer();
      expect(state.totalMiles, 100.0);
      expect(state.tripMiles, 10.0);
      expect(state.hoursSinceService, 45.3);
    });
  });

  group('persistDrivingHours / loadDrivingHours', () {
    test('persists and loads driving hours', () async {
      await repository.persistDrivingHours(45.3);

      final hours = await repository.loadDrivingHours();
      expect(hours, 45.3);
    });

    test('returns 0.0 when no data exists', () async {
      final hours = await repository.loadDrivingHours();
      expect(hours, 0.0);
    });
  });

  group('PreferenceKeys', () {
    test('debouncedKeys contains all slider/spinner keys', () {
      expect(
        PreferenceKeys.debouncedKeys,
        containsAll([
          PreferenceKeys.dayBrightness,
          PreferenceKeys.nightBrightness,
          PreferenceKeys.speakerVolume,
          PreferenceKeys.backlightTimeoutMinutes,
          PreferenceKeys.temperatureOffset,
          PreferenceKeys.serviceIntervalHours,
          PreferenceKeys.homeFenceRadiusMeters,
        ]),
      );
    });

    test('userConfigurableKeys does not include operational keys', () {
      expect(
        PreferenceKeys.userConfigurableKeys,
        isNot(contains(PreferenceKeys.odometerTotal)),
      );
      expect(
        PreferenceKeys.userConfigurableKeys,
        isNot(contains(PreferenceKeys.odometerTrip)),
      );
      expect(
        PreferenceKeys.userConfigurableKeys,
        isNot(contains(PreferenceKeys.drivingHours)),
      );
    });
  });
}

/// Helper to run async code in tests that need to verify immediate behavior.
Future<void> runAsync(Future<void> Function() fn) async {
  await fn();
}
