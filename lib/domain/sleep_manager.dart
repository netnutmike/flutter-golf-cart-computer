import 'dart:async';

import 'package:golf_cart_computer/domain/models/sleep_state.dart';

/// Manages the three-state power management system for the Golf Cart Computer.
///
/// Implements the following state machine:
/// - STARTUP_GRACE (initial): Waiting for GCI to connect within grace period.
/// - GCI_MODE: GCI is connected; display stays active.
/// - STANDALONE_MODE: Operating without GCI; display dims per timeout.
///
/// State transitions:
/// - STARTUP_GRACE → GCI_MODE: GCI connects during grace period.
/// - STARTUP_GRACE → STANDALONE_MODE: Grace period expires without GCI.
/// - GCI_MODE → STANDALONE_MODE: GCI disconnected for timeout period.
/// - STANDALONE_MODE → GCI_MODE: GCI reconnects.
abstract class SleepManager {
  /// Stream of operating mode changes.
  Stream<OperatingMode> get operatingMode;

  /// Current operating mode.
  OperatingMode get currentMode;

  /// Called when the GCI connects and begins communicating.
  void onGciConnected();

  /// Called when the GCI disconnects.
  void onGciDisconnected();

  /// Called when the startup grace period expires without GCI connection.
  void onGracePeriodExpired();

  /// Disposes resources held by this manager.
  void dispose();
}

/// Default implementation of [SleepManager].
///
/// The grace period and GCI disconnect timeout are both derived from the
/// backlight timeout setting, with a minimum of 30 seconds.
class DefaultSleepManager implements SleepManager {
  /// Creates a [DefaultSleepManager].
  ///
  /// [backlightTimeoutMinutes] is the user's configured backlight timeout
  /// setting. The grace period and GCI disconnect timeout are set to this
  /// value converted to seconds, with a minimum of 30 seconds.
  DefaultSleepManager({
    required int backlightTimeoutMinutes,
  }) : _timeoutDuration = _calculateTimeout(backlightTimeoutMinutes) {
    _currentMode = OperatingMode.startupGrace;
    _startGracePeriodTimer();
  }

  /// Calculates the timeout duration from the backlight timeout setting.
  ///
  /// Converts minutes to seconds with a minimum of 30 seconds.
  static Duration _calculateTimeout(int backlightTimeoutMinutes) {
    final seconds = backlightTimeoutMinutes * 60;
    final clampedSeconds = seconds < 30 ? 30 : seconds;
    return Duration(seconds: clampedSeconds);
  }

  final Duration _timeoutDuration;

  final _operatingModeController =
      StreamController<OperatingMode>.broadcast(sync: true);

  late OperatingMode _currentMode;

  /// Timer for the startup grace period.
  Timer? _gracePeriodTimer;

  /// Timer for the GCI disconnect timeout (GCI_MODE → STANDALONE_MODE).
  Timer? _disconnectTimer;

  @override
  Stream<OperatingMode> get operatingMode => _operatingModeController.stream;

  @override
  OperatingMode get currentMode => _currentMode;

  @override
  void onGciConnected() {
    switch (_currentMode) {
      case OperatingMode.startupGrace:
        // STARTUP_GRACE → GCI_MODE: GCI connects during grace period.
        _cancelGracePeriodTimer();
        _transitionTo(OperatingMode.gciMode);
      case OperatingMode.gciMode:
        // Already in GCI_MODE; cancel any pending disconnect timer.
        _cancelDisconnectTimer();
      case OperatingMode.standaloneMode:
        // STANDALONE_MODE → GCI_MODE: GCI reconnects.
        _transitionTo(OperatingMode.gciMode);
    }
  }

  @override
  void onGciDisconnected() {
    switch (_currentMode) {
      case OperatingMode.startupGrace:
        // No action; still waiting for grace period to expire.
        break;
      case OperatingMode.gciMode:
        // Start disconnect timeout; if it expires, transition to STANDALONE.
        _startDisconnectTimer();
      case OperatingMode.standaloneMode:
        // Already in STANDALONE_MODE; no action needed.
        break;
    }
  }

  @override
  void onGracePeriodExpired() {
    if (_currentMode == OperatingMode.startupGrace) {
      // STARTUP_GRACE → STANDALONE_MODE: Grace period expired without GCI.
      _transitionTo(OperatingMode.standaloneMode);
    }
  }

  @override
  void dispose() {
    _cancelGracePeriodTimer();
    _cancelDisconnectTimer();
    _operatingModeController.close();
  }

  /// Transitions to a new operating mode and emits it on the stream.
  void _transitionTo(OperatingMode newMode) {
    _currentMode = newMode;
    _operatingModeController.add(newMode);
  }

  /// Starts the startup grace period timer.
  void _startGracePeriodTimer() {
    _gracePeriodTimer = Timer(_timeoutDuration, onGracePeriodExpired);
  }

  /// Cancels the startup grace period timer.
  void _cancelGracePeriodTimer() {
    _gracePeriodTimer?.cancel();
    _gracePeriodTimer = null;
  }

  /// Starts the GCI disconnect timeout timer.
  ///
  /// When this timer fires, the system transitions from GCI_MODE to
  /// STANDALONE_MODE.
  void _startDisconnectTimer() {
    _cancelDisconnectTimer();
    _disconnectTimer = Timer(_timeoutDuration, () {
      if (_currentMode == OperatingMode.gciMode) {
        _transitionTo(OperatingMode.standaloneMode);
      }
    });
  }

  /// Cancels the GCI disconnect timeout timer.
  void _cancelDisconnectTimer() {
    _disconnectTimer?.cancel();
    _disconnectTimer = null;
  }
}
