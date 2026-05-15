import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/domain/brightness_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DefaultBrightnessManager manager;
  late List<MethodCall> methodCalls;
  late MethodChannel channel;

  setUp(() {
    methodCalls = [];
    channel = const MethodChannel('com.golfcart/brightness');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      methodCalls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    manager.dispose();
  });

  DefaultBrightnessManager createManager({
    int dayBrightness = 7,
    int nightBrightness = 3,
    int inactivityTimeoutMinutes = 5,
  }) {
    return DefaultBrightnessManager(
      dayBrightness: dayBrightness,
      nightBrightness: nightBrightness,
      inactivityTimeoutMinutes: inactivityTimeoutMinutes,
      methodChannel: channel,
    );
  }

  group('DefaultBrightnessManager', () {
    group('day/night brightness selection', () {
      test('uses day brightness when time is between sunrise and sunset', () {
        manager = createManager(dayBrightness: 8, nightBrightness: 2);

        final now = DateTime(2024, 6, 15, 12, 0); // noon
        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);

        manager.updateTimeContext(now, sunrise, sunset);

        expect(manager.currentState.currentLevel, 8);
        expect(manager.currentState.isDaytime, true);
        expect(manager.currentState.isDimmed, false);
      });

      test('uses night brightness when time is after sunset', () {
        manager = createManager(dayBrightness: 8, nightBrightness: 2);

        final now = DateTime(2024, 6, 15, 21, 0); // 9 PM
        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);

        manager.updateTimeContext(now, sunrise, sunset);

        expect(manager.currentState.currentLevel, 2);
        expect(manager.currentState.isDaytime, false);
        expect(manager.currentState.isDimmed, false);
      });

      test('uses night brightness when time is before sunrise', () {
        manager = createManager(dayBrightness: 8, nightBrightness: 2);

        final now = DateTime(2024, 6, 15, 4, 0); // 4 AM
        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);

        manager.updateTimeContext(now, sunrise, sunset);

        expect(manager.currentState.currentLevel, 2);
        expect(manager.currentState.isDaytime, false);
      });

      test('uses day brightness at exactly sunrise time', () {
        manager = createManager(dayBrightness: 8, nightBrightness: 2);

        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);

        manager.updateTimeContext(sunrise, sunrise, sunset);

        expect(manager.currentState.currentLevel, 8);
        expect(manager.currentState.isDaytime, true);
      });

      test('uses night brightness at exactly sunset time', () {
        manager = createManager(dayBrightness: 8, nightBrightness: 2);

        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);

        // At sunset, current time is NOT before sunset, so it's night
        manager.updateTimeContext(sunset, sunrise, sunset);

        expect(manager.currentState.isDaytime, false);
        expect(manager.currentState.currentLevel, 2);
      });

      test('defaults to day brightness when sunrise/sunset unavailable', () {
        manager = createManager(dayBrightness: 8, nightBrightness: 2);

        // No time context set - defaults to day
        expect(manager.currentState.currentLevel, 8);
        expect(manager.currentState.isDaytime, true);
      });
    });

    group('inactivity timeout dimming', () {
      test('dims display after timeout period', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 5);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Advance past the timeout
          async.elapse(const Duration(minutes: 5));

          expect(manager.currentState.isDimmed, true);
          expect(manager.currentState.currentLevel, 0);
        });
      });

      test('does not dim before timeout expires', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 5);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Advance less than the timeout
          async.elapse(const Duration(minutes: 4));

          expect(manager.currentState.isDimmed, false);
        });
      });

      test('timeout 0 disables auto-dimming', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 0);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Advance a long time - should never dim
          async.elapse(const Duration(hours: 2));

          expect(manager.currentState.isDimmed, false);
          expect(manager.currentState.currentLevel, 7);
        });
      });

      test('timeout of 1 minute dims after 1 minute', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 1);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          async.elapse(const Duration(minutes: 1));

          expect(manager.currentState.isDimmed, true);
          expect(manager.currentState.currentLevel, 0);
        });
      });
    });

    group('activity detection', () {
      test('reportActivity restores brightness when dimmed', () {
        fakeAsync((async) {
          manager = createManager(
            dayBrightness: 8,
            inactivityTimeoutMinutes: 5,
          );

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Let it dim
          async.elapse(const Duration(minutes: 5));
          expect(manager.currentState.isDimmed, true);

          // Report activity
          manager.reportActivity();

          expect(manager.currentState.isDimmed, false);
          expect(manager.currentState.currentLevel, 8);
        });
      });

      test('reportActivity resets inactivity timer', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 5);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Advance 4 minutes
          async.elapse(const Duration(minutes: 4));
          expect(manager.currentState.isDimmed, false);

          // Report activity - resets timer
          manager.reportActivity();

          // Advance another 4 minutes (total 8 from start, but only 4 from
          // last activity)
          async.elapse(const Duration(minutes: 4));
          expect(manager.currentState.isDimmed, false);

          // Advance 1 more minute (5 from last activity)
          async.elapse(const Duration(minutes: 1));
          expect(manager.currentState.isDimmed, true);
        });
      });

      test('restores night brightness when activity detected at night', () {
        fakeAsync((async) {
          manager = createManager(
            dayBrightness: 8,
            nightBrightness: 3,
            inactivityTimeoutMinutes: 5,
          );

          final now = DateTime(2024, 6, 15, 22, 0); // 10 PM
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Let it dim
          async.elapse(const Duration(minutes: 5));
          expect(manager.currentState.isDimmed, true);

          // Report activity
          manager.reportActivity();

          expect(manager.currentState.isDimmed, false);
          expect(manager.currentState.currentLevel, 3);
          expect(manager.currentState.isDaytime, false);
        });
      });

      test('reportActivity when not dimmed just resets timer', () {
        fakeAsync((async) {
          manager = createManager(
            dayBrightness: 8,
            inactivityTimeoutMinutes: 5,
          );

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Report activity before dimming
          async.elapse(const Duration(minutes: 2));
          manager.reportActivity();

          // Should still not be dimmed
          expect(manager.currentState.isDimmed, false);
          expect(manager.currentState.currentLevel, 8);
        });
      });
    });

    group('configuration changes', () {
      test('setDayBrightness updates level when daytime and not dimmed', () {
        manager = createManager(dayBrightness: 7);

        final now = DateTime(2024, 6, 15, 12, 0);
        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);
        manager.updateTimeContext(now, sunrise, sunset);

        manager.setDayBrightness(10);

        expect(manager.currentState.currentLevel, 10);
      });

      test('setNightBrightness updates level when nighttime and not dimmed',
          () {
        manager = createManager(nightBrightness: 3);

        final now = DateTime(2024, 6, 15, 22, 0);
        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);
        manager.updateTimeContext(now, sunrise, sunset);

        manager.setNightBrightness(5);

        expect(manager.currentState.currentLevel, 5);
      });

      test('setDayBrightness clamps to 0-10 range', () {
        manager = createManager(dayBrightness: 7);

        final now = DateTime(2024, 6, 15, 12, 0);
        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);
        manager.updateTimeContext(now, sunrise, sunset);

        manager.setDayBrightness(15);
        expect(manager.currentState.currentLevel, 10);

        manager.setDayBrightness(-3);
        expect(manager.currentState.currentLevel, 0);
      });

      test('setInactivityTimeout changes the timeout duration', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 10);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Change timeout to 2 minutes
          manager.setInactivityTimeout(2);

          // Advance 2 minutes
          async.elapse(const Duration(minutes: 2));

          expect(manager.currentState.isDimmed, true);
        });
      });

      test('setInactivityTimeout to 0 cancels pending timer', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 5);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Advance 3 minutes
          async.elapse(const Duration(minutes: 3));

          // Disable auto-dimming
          manager.setInactivityTimeout(0);

          // Advance past original timeout
          async.elapse(const Duration(minutes: 10));

          expect(manager.currentState.isDimmed, false);
        });
      });
    });

    group('platform channel interaction', () {
      test('applies brightness via platform channel on time context update',
          () {
        manager = createManager(dayBrightness: 8);

        final now = DateTime(2024, 6, 15, 12, 0);
        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);
        manager.updateTimeContext(now, sunrise, sunset);

        expect(methodCalls.length, 1);
        expect(methodCalls.first.method, 'setBrightness');
        expect(methodCalls.first.arguments, {'level': 8});
      });

      test('applies brightness 0 when dimmed', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 1);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          methodCalls.clear();
          async.elapse(const Duration(minutes: 1));

          expect(methodCalls.last.arguments, {'level': 0});
        });
      });

      test('restores brightness via platform channel on activity', () {
        fakeAsync((async) {
          manager = createManager(
            dayBrightness: 8,
            inactivityTimeoutMinutes: 1,
          );

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          async.elapse(const Duration(minutes: 1));
          methodCalls.clear();

          manager.reportActivity();

          expect(methodCalls.last.arguments, {'level': 8});
        });
      });
    });

    group('stream emission', () {
      test('emits state on time context update', () async {
        manager = createManager(dayBrightness: 8);

        final future = manager.brightnessState.first;

        final now = DateTime(2024, 6, 15, 12, 0);
        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);
        manager.updateTimeContext(now, sunrise, sunset);

        final state = await future;
        expect(state.currentLevel, 8);
        expect(state.isDaytime, true);
        expect(state.isDimmed, false);
      });

      test('emits state on reportActivity when dimmed', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 1);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);

          // Subscribe before any events
          final states = <dynamic>[];
          manager.brightnessState.listen(states.add);

          manager.updateTimeContext(now, sunrise, sunset);
          async.flushMicrotasks();

          async.elapse(const Duration(minutes: 1));
          async.flushMicrotasks();

          final countBeforeActivity = states.length;

          manager.reportActivity();
          async.flushMicrotasks();

          // Should have emitted at least one more state
          expect(states.length, greaterThan(countBeforeActivity));
          expect(states.last.isDimmed, false);
        });
      });
    });

    group('edge cases', () {
      test('brightness levels are clamped on construction', () {
        manager = createManager(dayBrightness: 15, nightBrightness: -5);

        // Default to day when no time context
        expect(manager.currentState.currentLevel, 10);
        expect(manager.currentState.isDaytime, true);
      });

      test('inactivity timeout clamped to 0-60 range', () {
        fakeAsync((async) {
          manager = createManager(inactivityTimeoutMinutes: 100);

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          // Should be clamped to 60 minutes
          async.elapse(const Duration(minutes: 59));
          expect(manager.currentState.isDimmed, false);

          async.elapse(const Duration(minutes: 1));
          expect(manager.currentState.isDimmed, true);
        });
      });

      test('multiple rapid time context updates do not cause issues', () {
        manager = createManager(dayBrightness: 8, nightBrightness: 3);

        final sunrise = DateTime(2024, 6, 15, 6, 0);
        final sunset = DateTime(2024, 6, 15, 20, 0);

        // Rapid updates transitioning from day to night
        for (int hour = 18; hour <= 22; hour++) {
          manager.updateTimeContext(
            DateTime(2024, 6, 15, hour, 0),
            sunrise,
            sunset,
          );
        }

        // Last state should reflect nighttime
        expect(manager.currentState.isDaytime, false);
        expect(manager.currentState.currentLevel, 3);
      });

      test('setDayBrightness does not emit when dimmed', () {
        fakeAsync((async) {
          manager = createManager(
            dayBrightness: 7,
            inactivityTimeoutMinutes: 1,
          );

          final now = DateTime(2024, 6, 15, 12, 0);
          final sunrise = DateTime(2024, 6, 15, 6, 0);
          final sunset = DateTime(2024, 6, 15, 20, 0);
          manager.updateTimeContext(now, sunrise, sunset);

          async.elapse(const Duration(minutes: 1));
          expect(manager.currentState.isDimmed, true);

          // Change day brightness while dimmed
          manager.setDayBrightness(10);

          // Should still be dimmed at 0
          expect(manager.currentState.isDimmed, true);
          expect(manager.currentState.currentLevel, 0);

          // But when restored, should use new value
          manager.reportActivity();
          expect(manager.currentState.currentLevel, 10);
        });
      });
    });
  });
}
