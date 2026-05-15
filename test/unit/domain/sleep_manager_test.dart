import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/domain/models/sleep_state.dart';
import 'package:golf_cart_computer/domain/sleep_manager.dart';

void main() {
  group('DefaultSleepManager - Initial State', () {
    test('starts in STARTUP_GRACE mode', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 5);
        expect(manager.currentMode, OperatingMode.startupGrace);
        manager.dispose();
      });
    });

    test('emits initial mode on stream subscription', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 5);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // No emission yet until a transition occurs
        async.flushMicrotasks();
        expect(modes, isEmpty);

        manager.dispose();
      });
    });
  });

  group('DefaultSleepManager - Grace Period Timeout', () {
    test('grace period uses backlight timeout in seconds (minimum 30s)', () {
      fakeAsync((async) {
        // 5 minutes = 300 seconds
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 5);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // Advance 299 seconds - should still be in grace
        async.elapse(const Duration(seconds: 299));
        expect(manager.currentMode, OperatingMode.startupGrace);
        expect(modes, isEmpty);

        // Advance 1 more second to hit 300 seconds
        async.elapse(const Duration(seconds: 1));
        expect(manager.currentMode, OperatingMode.standaloneMode);
        expect(modes, [OperatingMode.standaloneMode]);

        manager.dispose();
      });
    });

    test('grace period minimum is 30 seconds when backlight timeout is 0', () {
      fakeAsync((async) {
        // 0 minutes → should clamp to 30 seconds minimum
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 0);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // Advance 29 seconds - still in grace
        async.elapse(const Duration(seconds: 29));
        expect(manager.currentMode, OperatingMode.startupGrace);

        // Advance 1 more second to hit 30 seconds
        async.elapse(const Duration(seconds: 1));
        expect(manager.currentMode, OperatingMode.standaloneMode);
        expect(modes, [OperatingMode.standaloneMode]);

        manager.dispose();
      });
    });

    test('STARTUP_GRACE transitions to STANDALONE_MODE on grace period expiry',
        () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 1);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // 1 minute = 60 seconds
        async.elapse(const Duration(seconds: 60));
        expect(manager.currentMode, OperatingMode.standaloneMode);
        expect(modes, [OperatingMode.standaloneMode]);

        manager.dispose();
      });
    });
  });

  group('DefaultSleepManager - STARTUP_GRACE → GCI_MODE', () {
    test('transitions to GCI_MODE when GCI connects during grace period', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 5);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // GCI connects after 10 seconds (within grace period)
        async.elapse(const Duration(seconds: 10));
        manager.onGciConnected();
        async.flushMicrotasks();

        expect(manager.currentMode, OperatingMode.gciMode);
        expect(modes, [OperatingMode.gciMode]);

        manager.dispose();
      });
    });

    test('grace period timer is cancelled when GCI connects', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 1);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // GCI connects after 30 seconds
        async.elapse(const Duration(seconds: 30));
        manager.onGciConnected();
        expect(manager.currentMode, OperatingMode.gciMode);

        // Grace period would have expired at 60 seconds, but should not fire
        async.elapse(const Duration(seconds: 60));
        expect(manager.currentMode, OperatingMode.gciMode);
        expect(modes, [OperatingMode.gciMode]);

        manager.dispose();
      });
    });
  });

  group('DefaultSleepManager - GCI_MODE → STANDALONE_MODE', () {
    test(
        'transitions to STANDALONE_MODE when GCI disconnected for timeout period',
        () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 1);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // Connect GCI
        manager.onGciConnected();
        expect(manager.currentMode, OperatingMode.gciMode);

        // Disconnect GCI
        manager.onGciDisconnected();
        expect(manager.currentMode, OperatingMode.gciMode); // Still in GCI mode

        // Wait for timeout (60 seconds for 1-minute backlight timeout)
        async.elapse(const Duration(seconds: 59));
        expect(manager.currentMode, OperatingMode.gciMode);

        async.elapse(const Duration(seconds: 1));
        expect(manager.currentMode, OperatingMode.standaloneMode);
        expect(modes, [OperatingMode.gciMode, OperatingMode.standaloneMode]);

        manager.dispose();
      });
    });

    test('disconnect timer is cancelled if GCI reconnects before timeout', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 1);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // Connect, then disconnect
        manager.onGciConnected();
        manager.onGciDisconnected();

        // Wait 30 seconds (half the timeout)
        async.elapse(const Duration(seconds: 30));
        expect(manager.currentMode, OperatingMode.gciMode);

        // Reconnect before timeout
        manager.onGciConnected();

        // Wait past the original timeout
        async.elapse(const Duration(seconds: 60));
        expect(manager.currentMode, OperatingMode.gciMode);

        // Only one transition emitted (the initial connect)
        expect(modes, [OperatingMode.gciMode]);

        manager.dispose();
      });
    });
  });

  group('DefaultSleepManager - STANDALONE_MODE → GCI_MODE', () {
    test('transitions to GCI_MODE when GCI reconnects in standalone mode', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 1);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // Let grace period expire → STANDALONE_MODE
        async.elapse(const Duration(seconds: 60));
        expect(manager.currentMode, OperatingMode.standaloneMode);

        // GCI connects
        manager.onGciConnected();
        async.flushMicrotasks();
        expect(manager.currentMode, OperatingMode.gciMode);
        expect(modes, [OperatingMode.standaloneMode, OperatingMode.gciMode]);

        manager.dispose();
      });
    });

    test(
        'transitions from STANDALONE (via GCI disconnect) back to GCI_MODE on reconnect',
        () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 1);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // Connect GCI → GCI_MODE
        manager.onGciConnected();
        async.flushMicrotasks();
        // Disconnect GCI, wait for timeout → STANDALONE_MODE
        manager.onGciDisconnected();
        async.elapse(const Duration(seconds: 60));
        expect(manager.currentMode, OperatingMode.standaloneMode);

        // Reconnect → GCI_MODE
        manager.onGciConnected();
        async.flushMicrotasks();
        expect(manager.currentMode, OperatingMode.gciMode);
        expect(modes, [
          OperatingMode.gciMode,
          OperatingMode.standaloneMode,
          OperatingMode.gciMode,
        ]);

        manager.dispose();
      });
    });
  });

  group('DefaultSleepManager - Edge Cases', () {
    test('onGciDisconnected in STARTUP_GRACE has no effect', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 1);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        manager.onGciDisconnected();
        expect(manager.currentMode, OperatingMode.startupGrace);
        expect(modes, isEmpty);

        manager.dispose();
      });
    });

    test('onGciDisconnected in STANDALONE_MODE has no effect', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 1);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // Get to STANDALONE_MODE
        async.elapse(const Duration(seconds: 60));
        expect(manager.currentMode, OperatingMode.standaloneMode);

        // Disconnect in standalone - no effect
        manager.onGciDisconnected();
        expect(manager.currentMode, OperatingMode.standaloneMode);
        expect(modes, [OperatingMode.standaloneMode]);

        manager.dispose();
      });
    });

    test('onGracePeriodExpired has no effect when not in STARTUP_GRACE', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 5);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        // Transition to GCI_MODE
        manager.onGciConnected();
        async.flushMicrotasks();
        expect(manager.currentMode, OperatingMode.gciMode);

        // Manually calling onGracePeriodExpired should have no effect
        manager.onGracePeriodExpired();
        async.flushMicrotasks();
        expect(manager.currentMode, OperatingMode.gciMode);
        expect(modes, [OperatingMode.gciMode]);

        manager.dispose();
      });
    });

    test('multiple onGciConnected calls in GCI_MODE are idempotent', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 5);
        final modes = <OperatingMode>[];
        manager.operatingMode.listen(modes.add);

        manager.onGciConnected();
        manager.onGciConnected();
        manager.onGciConnected();
        async.flushMicrotasks();

        expect(manager.currentMode, OperatingMode.gciMode);
        // Only one transition emitted
        expect(modes, [OperatingMode.gciMode]);

        manager.dispose();
      });
    });

    test('disconnect and reconnect cycle resets disconnect timer', () {
      fakeAsync((async) {
        final manager = DefaultSleepManager(backlightTimeoutMinutes: 1);

        // Connect
        manager.onGciConnected();

        // Disconnect, wait 30s, reconnect, disconnect again
        manager.onGciDisconnected();
        async.elapse(const Duration(seconds: 30));
        manager.onGciConnected();
        manager.onGciDisconnected();

        // Wait 59 seconds from second disconnect - should still be GCI_MODE
        async.elapse(const Duration(seconds: 59));
        expect(manager.currentMode, OperatingMode.gciMode);

        // 1 more second completes the timeout from second disconnect
        async.elapse(const Duration(seconds: 1));
        expect(manager.currentMode, OperatingMode.standaloneMode);

        manager.dispose();
      });
    });
  });
}
