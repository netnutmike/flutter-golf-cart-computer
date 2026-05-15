import 'package:fake_async/fake_async.dart';
import 'package:glados/glados.dart';
import 'package:golf_cart_computer/domain/models/sleep_state.dart';
import 'package:golf_cart_computer/domain/sleep_manager.dart';

/// Represents an event that can be applied to the SleepManager.
enum SleepEvent {
  gciConnected,
  gciDisconnected,
  gracePeriodExpired,
}

/// Custom generators for sleep state machine property tests.
extension SleepStateGenerators on Any {
  /// Generates a random sleep event.
  Generator<SleepEvent> get sleepEvent => choose(SleepEvent.values);

  /// Generates a sequence of 1-20 sleep events.
  Generator<List<SleepEvent>> get sleepEventSequence =>
      listWithLengthInRange(1, 20, sleepEvent);

  /// Generates a valid backlight timeout in minutes (1-60).
  Generator<int> get backlightTimeout => intInRange(1, 61);
}

/// Applies a sleep event to the manager.
void applyEvent(DefaultSleepManager manager, SleepEvent event) {
  switch (event) {
    case SleepEvent.gciConnected:
      manager.onGciConnected();
    case SleepEvent.gciDisconnected:
      manager.onGciDisconnected();
    case SleepEvent.gracePeriodExpired:
      manager.onGracePeriodExpired();
  }
}

/// Computes the expected mode after applying an event to a given current mode.
///
/// This is the reference state machine implementation that the property tests
/// validate against.
OperatingMode expectedTransition(OperatingMode current, SleepEvent event) {
  switch (current) {
    case OperatingMode.startupGrace:
      switch (event) {
        case SleepEvent.gciConnected:
          return OperatingMode.gciMode;
        case SleepEvent.gciDisconnected:
          return OperatingMode.startupGrace; // No transition
        case SleepEvent.gracePeriodExpired:
          return OperatingMode.standaloneMode;
      }
    case OperatingMode.gciMode:
      switch (event) {
        case SleepEvent.gciConnected:
          return OperatingMode.gciMode; // Already in GCI mode
        case SleepEvent.gciDisconnected:
          // Starts disconnect timer, but doesn't immediately transition.
          // Transition happens after timeout expires.
          return OperatingMode.gciMode;
        case SleepEvent.gracePeriodExpired:
          return OperatingMode.gciMode; // No effect in GCI mode
      }
    case OperatingMode.standaloneMode:
      switch (event) {
        case SleepEvent.gciConnected:
          return OperatingMode.gciMode;
        case SleepEvent.gciDisconnected:
          return OperatingMode.standaloneMode; // Already standalone
        case SleepEvent.gracePeriodExpired:
          return OperatingMode.standaloneMode; // No effect
      }
  }
}

void main() {
  group('Property 20: Sleep state machine transitions', () {
    // ---------------------------------------------------------------
    // Valid transition: STARTUP_GRACE → GCI_MODE when GCI connects
    // ---------------------------------------------------------------

    /// **Validates: Requirements 11.1, 11.3**
    ///
    /// For any backlight timeout, when GCI connects during the startup
    /// grace period, the mode should transition to GCI_MODE.
    Glados(any.backlightTimeout).test(
      'STARTUP_GRACE → GCI_MODE when GCI connects during grace period',
      (timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);

          expect(manager.currentMode, equals(OperatingMode.startupGrace));

          manager.onGciConnected();

          expect(manager.currentMode, equals(OperatingMode.gciMode));

          manager.dispose();
        });
      },
    );

    // ---------------------------------------------------------------
    // Valid transition: STARTUP_GRACE → STANDALONE_MODE on grace expiry
    // ---------------------------------------------------------------

    /// **Validates: Requirements 11.1, 11.4**
    ///
    /// For any backlight timeout, when the grace period expires without
    /// GCI connecting, the mode should transition to STANDALONE_MODE.
    Glados(any.backlightTimeout).test(
      'STARTUP_GRACE → STANDALONE_MODE when grace period expires',
      (timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);

          expect(manager.currentMode, equals(OperatingMode.startupGrace));

          // Advance time past the grace period.
          final timeoutSeconds = timeout * 60 < 30 ? 30 : timeout * 60;
          async.elapse(Duration(seconds: timeoutSeconds));

          expect(manager.currentMode, equals(OperatingMode.standaloneMode));

          manager.dispose();
        });
      },
    );

    // ---------------------------------------------------------------
    // Valid transition: GCI_MODE → STANDALONE_MODE on disconnect timeout
    // ---------------------------------------------------------------

    /// **Validates: Requirements 11.1, 11.5**
    ///
    /// For any backlight timeout, when GCI disconnects and the timeout
    /// period elapses, the mode should transition to STANDALONE_MODE.
    Glados(any.backlightTimeout).test(
      'GCI_MODE → STANDALONE_MODE when GCI disconnected for timeout period',
      (timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);

          // First, get into GCI_MODE.
          manager.onGciConnected();
          expect(manager.currentMode, equals(OperatingMode.gciMode));

          // Disconnect GCI.
          manager.onGciDisconnected();
          expect(manager.currentMode, equals(OperatingMode.gciMode));

          // Advance time past the disconnect timeout.
          final timeoutSeconds = timeout * 60 < 30 ? 30 : timeout * 60;
          async.elapse(Duration(seconds: timeoutSeconds));

          expect(manager.currentMode, equals(OperatingMode.standaloneMode));

          manager.dispose();
        });
      },
    );

    // ---------------------------------------------------------------
    // Valid transition: STANDALONE_MODE → GCI_MODE when GCI reconnects
    // ---------------------------------------------------------------

    /// **Validates: Requirements 11.1**
    ///
    /// For any backlight timeout, when GCI reconnects while in
    /// STANDALONE_MODE, the mode should transition to GCI_MODE.
    Glados(any.backlightTimeout).test(
      'STANDALONE_MODE → GCI_MODE when GCI reconnects',
      (timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);

          // Get into STANDALONE_MODE via grace period expiry.
          final timeoutSeconds = timeout * 60 < 30 ? 30 : timeout * 60;
          async.elapse(Duration(seconds: timeoutSeconds));
          expect(manager.currentMode, equals(OperatingMode.standaloneMode));

          // GCI reconnects.
          manager.onGciConnected();

          expect(manager.currentMode, equals(OperatingMode.gciMode));

          manager.dispose();
        });
      },
    );

    // ---------------------------------------------------------------
    // No invalid transitions: state machine only allows defined paths
    // ---------------------------------------------------------------

    /// **Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5**
    ///
    /// For any sequence of events, the state machine should only ever
    /// be in one of the three valid states, and transitions should only
    /// follow the defined paths.
    Glados2(any.sleepEventSequence, any.backlightTimeout).test(
      'state machine only produces valid states for any event sequence',
      (events, timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);

          // Track that we always remain in a valid state.
          for (final event in events) {
            applyEvent(manager, event);

            // The current mode must always be one of the three valid states.
            expect(
              manager.currentMode,
              isIn([
                OperatingMode.startupGrace,
                OperatingMode.gciMode,
                OperatingMode.standaloneMode,
              ]),
            );
          }

          manager.dispose();
        });
      },
    );

    /// **Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5**
    ///
    /// For any sequence of events applied to the state machine, the
    /// resulting mode should match the reference transition function.
    /// This verifies no unexpected transitions occur.
    Glados2(any.sleepEventSequence, any.backlightTimeout).test(
      'state machine transitions match reference model for any event sequence',
      (events, timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);
          var expectedMode = OperatingMode.startupGrace;

          for (final event in events) {
            expectedMode = expectedTransition(expectedMode, event);
            applyEvent(manager, event);

            expect(manager.currentMode, equals(expectedMode));
          }

          manager.dispose();
        });
      },
    );

    // ---------------------------------------------------------------
    // GCI disconnect in STARTUP_GRACE has no effect
    // ---------------------------------------------------------------

    /// **Validates: Requirements 11.1, 11.2**
    ///
    /// For any backlight timeout, disconnecting GCI during startup grace
    /// should not change the operating mode.
    Glados(any.backlightTimeout).test(
      'GCI disconnect during STARTUP_GRACE has no effect',
      (timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);

          expect(manager.currentMode, equals(OperatingMode.startupGrace));

          manager.onGciDisconnected();

          expect(manager.currentMode, equals(OperatingMode.startupGrace));

          manager.dispose();
        });
      },
    );

    // ---------------------------------------------------------------
    // Grace period expiry has no effect once in GCI_MODE
    // ---------------------------------------------------------------

    /// **Validates: Requirements 11.1, 11.3**
    ///
    /// For any backlight timeout, if GCI connects first and then the
    /// grace period timer fires, the mode should remain GCI_MODE.
    Glados(any.backlightTimeout).test(
      'grace period expiry has no effect in GCI_MODE',
      (timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);

          // Connect GCI first (cancels grace period timer).
          manager.onGciConnected();
          expect(manager.currentMode, equals(OperatingMode.gciMode));

          // Manually call onGracePeriodExpired (simulating a late callback).
          manager.onGracePeriodExpired();

          expect(manager.currentMode, equals(OperatingMode.gciMode));

          manager.dispose();
        });
      },
    );

    // ---------------------------------------------------------------
    // GCI reconnect during disconnect timeout cancels transition
    // ---------------------------------------------------------------

    /// **Validates: Requirements 11.1, 11.5**
    ///
    /// For any backlight timeout, if GCI reconnects before the disconnect
    /// timeout expires, the mode should remain GCI_MODE.
    Glados(any.backlightTimeout).test(
      'GCI reconnect during disconnect timeout cancels transition to STANDALONE',
      (timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);

          // Get into GCI_MODE.
          manager.onGciConnected();
          expect(manager.currentMode, equals(OperatingMode.gciMode));

          // Disconnect GCI (starts timeout timer).
          manager.onGciDisconnected();

          // Advance partway through the timeout.
          final timeoutSeconds = timeout * 60 < 30 ? 30 : timeout * 60;
          async.elapse(Duration(seconds: timeoutSeconds ~/ 2));
          expect(manager.currentMode, equals(OperatingMode.gciMode));

          // Reconnect before timeout expires.
          manager.onGciConnected();

          // Advance past the original timeout - should NOT transition.
          async.elapse(Duration(seconds: timeoutSeconds));
          expect(manager.currentMode, equals(OperatingMode.gciMode));

          manager.dispose();
        });
      },
    );

    // ---------------------------------------------------------------
    // Initial state is always STARTUP_GRACE
    // ---------------------------------------------------------------

    /// **Validates: Requirements 11.1, 11.2**
    ///
    /// For any backlight timeout, the initial state should always be
    /// STARTUP_GRACE.
    Glados(any.backlightTimeout).test(
      'initial state is always STARTUP_GRACE',
      (timeout) {
        fakeAsync((async) {
          final manager = DefaultSleepManager(backlightTimeoutMinutes: timeout);

          expect(manager.currentMode, equals(OperatingMode.startupGrace));

          manager.dispose();
        });
      },
    );
  });
}
