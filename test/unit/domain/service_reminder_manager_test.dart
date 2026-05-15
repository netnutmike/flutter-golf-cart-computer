import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/data/repositories/preferences_repository.dart';
import 'package:golf_cart_computer/domain/service_reminder_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockPreferencesRepository extends Mock implements PreferencesRepository {}

void main() {
  late MockPreferencesRepository mockPrefs;
  late DefaultServiceReminderManager manager;

  setUp(() {
    mockPrefs = MockPreferencesRepository();
    when(() => mockPrefs.loadDrivingHours()).thenAnswer((_) async => 0.0);
    when(() => mockPrefs.persistDrivingHours(any()))
        .thenAnswer((_) async {});
    manager = DefaultServiceReminderManager(
      preferencesRepository: mockPrefs,
    );
  });

  group('ServiceReminderManager - Time Accumulation', () {
    test('accumulates time only when isMoving is true', () {
      manager.accumulateTime(5.0, true);
      expect(manager.currentHoursTenths, greaterThan(0));
    });

    test('does not accumulate time when isMoving is false', () {
      manager.accumulateTime(5.0, false);
      expect(manager.currentHoursTenths, 0.0);
    });

    test('accumulates correct tenths of hours', () {
      // 360 seconds = 1 tenth of an hour
      manager.accumulateTime(10.0, true); // 10/360 tenths
      final expected = 10.0 / 360.0;
      expect(manager.currentHoursTenths, closeTo(expected, 0.0001));
    });

    test('accumulates multiple deltas correctly', () {
      manager.accumulateTime(10.0, true);
      manager.accumulateTime(10.0, true);
      manager.accumulateTime(10.0, true);
      final expected = 30.0 / 360.0;
      expect(manager.currentHoursTenths, closeTo(expected, 0.0001));
    });
  });

  group('ServiceReminderManager - Time Delta Validation', () {
    test('rejects delta of 0 seconds', () {
      manager.accumulateTime(0.0, true);
      expect(manager.currentHoursTenths, 0.0);
    });

    test('rejects negative delta', () {
      manager.accumulateTime(-1.0, true);
      expect(manager.currentHoursTenths, 0.0);
    });

    test('rejects delta greater than 10 seconds', () {
      manager.accumulateTime(10.1, true);
      expect(manager.currentHoursTenths, 0.0);
    });

    test('rejects delta of 11 seconds', () {
      manager.accumulateTime(11.0, true);
      expect(manager.currentHoursTenths, 0.0);
    });

    test('accepts delta of exactly 10 seconds', () {
      manager.accumulateTime(10.0, true);
      expect(manager.currentHoursTenths, greaterThan(0));
    });

    test('accepts delta just above 0', () {
      manager.accumulateTime(0.001, true);
      expect(manager.currentHoursTenths, greaterThan(0));
    });

    test('accepts delta of 1 second', () {
      manager.accumulateTime(1.0, true);
      final expected = 1.0 / 360.0;
      expect(manager.currentHoursTenths, closeTo(expected, 0.0001));
    });
  });

  group('ServiceReminderManager - Storage in Tenths of Hours', () {
    test('stores in tenths of hours (6-minute resolution)', () {
      // 360 seconds = 1 tenth of an hour
      // Accumulate 360 seconds in 10-second increments
      for (var i = 0; i < 36; i++) {
        manager.accumulateTime(10.0, true);
      }
      expect(manager.currentHoursTenths, closeTo(1.0, 0.0001));
    });

    test('one hour of driving equals 10 tenths', () {
      // 3600 seconds = 1 hour = 10 tenths
      // Accumulate in 10-second increments: 360 iterations
      for (var i = 0; i < 360; i++) {
        manager.accumulateTime(10.0, true);
      }
      expect(manager.currentHoursTenths, closeTo(10.0, 0.001));
    });
  });

  group('ServiceReminderManager - Persistence Trigger', () {
    test('persists every 1.0 hours of driving (10 tenths)', () {
      // 1 hour = 3600 seconds = 360 iterations of 10 seconds
      for (var i = 0; i < 360; i++) {
        manager.accumulateTime(10.0, true);
      }
      // Should have triggered persistence once
      verify(() => mockPrefs.persistDrivingHours(any())).called(1);
    });

    test('does not persist before 1.0 hours', () {
      // 359 iterations of 10 seconds = 3590 seconds < 1 hour
      for (var i = 0; i < 359; i++) {
        manager.accumulateTime(10.0, true);
      }
      verifyNever(() => mockPrefs.persistDrivingHours(any()));
    });

    test('persists twice after 2.0 hours of driving', () {
      // 2 hours = 7200 seconds = 720 iterations of 10 seconds
      for (var i = 0; i < 720; i++) {
        manager.accumulateTime(10.0, true);
      }
      verify(() => mockPrefs.persistDrivingHours(any())).called(2);
    });
  });

  group('ServiceReminderManager - Service Interval', () {
    test('default service interval is 100 hours', () {
      expect(manager.serviceIntervalHours, 100);
    });

    test('configurable service interval', () {
      final customManager = DefaultServiceReminderManager(
        preferencesRepository: mockPrefs,
        serviceIntervalHours: 50,
      );
      expect(customManager.serviceIntervalHours, 50);
    });

    test('service interval clamped to minimum 1', () {
      final customManager = DefaultServiceReminderManager(
        preferencesRepository: mockPrefs,
        serviceIntervalHours: 0,
      );
      expect(customManager.serviceIntervalHours, 1);
    });

    test('service interval clamped to maximum 500', () {
      final customManager = DefaultServiceReminderManager(
        preferencesRepository: mockPrefs,
        serviceIntervalHours: 600,
      );
      expect(customManager.serviceIntervalHours, 500);
    });

    test('setServiceInterval updates the interval', () {
      manager.setServiceInterval(200);
      expect(manager.serviceIntervalHours, 200);
    });

    test('setServiceInterval clamps to valid range', () {
      manager.setServiceInterval(0);
      expect(manager.serviceIntervalHours, 1);
      manager.setServiceInterval(1000);
      expect(manager.serviceIntervalHours, 500);
    });
  });

  group('ServiceReminderManager - Service Due Detection', () {
    test('emits isServiceDue when hours reach interval', () async {
      final customManager = DefaultServiceReminderManager(
        preferencesRepository: mockPrefs,
        serviceIntervalHours: 1, // 1 hour = 10 tenths
      );

      final states = <ServiceState>[];
      customManager.serviceState.listen(states.add);

      // Accumulate 1 hour (360 iterations of 10 seconds)
      for (var i = 0; i < 360; i++) {
        customManager.accumulateTime(10.0, true);
      }

      // Allow stream to propagate
      await Future<void>.delayed(Duration.zero);

      expect(states.last.isServiceDue, true);
    });

    test('isServiceDue is false when below interval', () async {
      final states = <ServiceState>[];
      manager.serviceState.listen(states.add);

      manager.accumulateTime(10.0, true);

      await Future<void>.delayed(Duration.zero);

      expect(states.last.isServiceDue, false);
    });
  });

  group('ServiceReminderManager - Reset', () {
    test('resetHours sets hours to zero', () {
      manager.accumulateTime(10.0, true);
      expect(manager.currentHoursTenths, greaterThan(0));

      manager.resetHours();
      expect(manager.currentHoursTenths, 0.0);
    });

    test('resetHours persists the zero value', () {
      manager.accumulateTime(10.0, true);
      manager.resetHours();
      verify(() => mockPrefs.persistDrivingHours(0.0)).called(1);
    });

    test('resetHours emits updated state', () async {
      final states = <ServiceState>[];
      manager.serviceState.listen(states.add);

      manager.accumulateTime(10.0, true);
      manager.resetHours();

      await Future<void>.delayed(Duration.zero);

      expect(states.last.hoursSinceService, 0.0);
    });
  });

  group('ServiceReminderManager - Initialization', () {
    test('initialize loads persisted hours', () async {
      when(() => mockPrefs.loadDrivingHours()).thenAnswer((_) async => 5.5);

      await manager.initialize();

      expect(manager.currentHoursTenths, 5.5);
      verify(() => mockPrefs.loadDrivingHours()).called(1);
    });

    test('initialize emits state after loading', () async {
      when(() => mockPrefs.loadDrivingHours()).thenAnswer((_) async => 3.0);

      final states = <ServiceState>[];
      manager.serviceState.listen(states.add);

      await manager.initialize();
      await Future<void>.delayed(Duration.zero);

      expect(states.isNotEmpty, true);
      expect(states.last.hoursSinceService, 3.0);
    });
  });

  group('ServiceReminderManager - Persist', () {
    test('persist saves current hours to repository', () async {
      manager.accumulateTime(10.0, true);
      await manager.persist();

      final captured = verify(
        () => mockPrefs.persistDrivingHours(captureAny()),
      ).captured;
      final expectedTenths = 10.0 / 360.0;
      expect(captured.last as double, closeTo(expectedTenths, 0.0001));
    });
  });

  group('ServiceReminderManager - Stream Emissions', () {
    test('emits state on each accumulation', () async {
      final states = <ServiceState>[];
      manager.serviceState.listen(states.add);

      manager.accumulateTime(5.0, true);
      manager.accumulateTime(5.0, true);

      await Future<void>.delayed(Duration.zero);

      expect(states.length, 2);
    });

    test('does not emit state when delta is invalid', () async {
      final states = <ServiceState>[];
      manager.serviceState.listen(states.add);

      manager.accumulateTime(0.0, true);
      manager.accumulateTime(-1.0, true);
      manager.accumulateTime(11.0, true);

      await Future<void>.delayed(Duration.zero);

      expect(states.isEmpty, true);
    });

    test('does not emit state when not moving', () async {
      final states = <ServiceState>[];
      manager.serviceState.listen(states.add);

      manager.accumulateTime(5.0, false);

      await Future<void>.delayed(Duration.zero);

      expect(states.isEmpty, true);
    });
  });

  group('ServiceState', () {
    test('equality works correctly', () {
      const a = ServiceState(
        hoursSinceService: 5.0,
        serviceIntervalHours: 100,
        isServiceDue: false,
      );
      const b = ServiceState(
        hoursSinceService: 5.0,
        serviceIntervalHours: 100,
        isServiceDue: false,
      );
      expect(a, equals(b));
    });

    test('inequality when values differ', () {
      const a = ServiceState(
        hoursSinceService: 5.0,
        serviceIntervalHours: 100,
        isServiceDue: false,
      );
      const b = ServiceState(
        hoursSinceService: 6.0,
        serviceIntervalHours: 100,
        isServiceDue: false,
      );
      expect(a, isNot(equals(b)));
    });

    test('toString provides useful output', () {
      const state = ServiceState(
        hoursSinceService: 5.0,
        serviceIntervalHours: 100,
        isServiceDue: false,
      );
      expect(state.toString(), contains('5.0'));
      expect(state.toString(), contains('100'));
      expect(state.toString(), contains('false'));
    });
  });
}
