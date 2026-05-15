import 'dart:async';

import 'package:flutter/services.dart';
import 'package:golf_cart_computer/domain/models/brightness_state.dart';

/// Abstract interface for the display brightness management system.
///
/// Controls display brightness based on time of day (sunrise/sunset) and
/// user activity. Implements inactivity timeout dimming and activity
/// detection (touch input or GPS movement).
///
/// Uses platform channels for native screen brightness control on both
/// Android and iOS.
abstract class BrightnessManager {
  /// Stream of brightness state changes.
  Stream<BrightnessState> get brightnessState;

  /// The current brightness state (synchronous access).
  BrightnessState get currentState;

  /// Reports user activity (touch input or GPS movement with speed > 0).
  ///
  /// Resets the inactivity timer and restores brightness if dimmed.
  void reportActivity();

  /// Updates the time context used for day/night brightness selection.
  ///
  /// [now] is the current time.
  /// [sunrise] is today's sunrise time.
  /// [sunset] is today's sunset time.
  void updateTimeContext(DateTime now, DateTime sunrise, DateTime sunset);

  /// Updates the day brightness level (0-10 scale).
  void setDayBrightness(int level);

  /// Updates the night brightness level (0-10 scale).
  void setNightBrightness(int level);

  /// Updates the inactivity timeout in minutes (0-60).
  ///
  /// A value of 0 disables auto-dimming.
  void setInactivityTimeout(int minutes);

  /// Disposes resources held by this manager.
  void dispose();
}

/// Default implementation of [BrightnessManager].
///
/// Manages display brightness through three mechanisms:
/// 1. Day/night selection based on current time relative to sunrise/sunset
/// 2. Inactivity timeout dimming (configurable 0-60 minutes, default 5)
/// 3. Activity detection restoring brightness from dimmed state
///
/// When sunrise/sunset times are unavailable, defaults to day brightness.
/// Timeout of 0 disables auto-dimming entirely.
class DefaultBrightnessManager implements BrightnessManager {
  /// Creates a [DefaultBrightnessManager] with the given configuration.
  ///
  /// [dayBrightness] defaults to 7 (0-10 scale).
  /// [nightBrightness] defaults to 3 (0-10 scale).
  /// [inactivityTimeoutMinutes] defaults to 5 (0-60 range, 0 disables).
  /// [methodChannel] can be injected for testing platform channel calls.
  DefaultBrightnessManager({
    int dayBrightness = 7,
    int nightBrightness = 3,
    int inactivityTimeoutMinutes = 5,
    MethodChannel? methodChannel,
  })  : _dayBrightness = dayBrightness.clamp(0, 10),
        _nightBrightness = nightBrightness.clamp(0, 10),
        _inactivityTimeoutMinutes = inactivityTimeoutMinutes.clamp(0, 60),
        _methodChannel =
            methodChannel ?? const MethodChannel('com.golfcart/brightness');

  final MethodChannel _methodChannel;

  final _stateController = StreamController<BrightnessState>.broadcast();

  // Configuration
  int _dayBrightness;
  int _nightBrightness;
  int _inactivityTimeoutMinutes;

  // Time context state
  DateTime? _sunrise;
  DateTime? _sunset;
  DateTime? _currentTime;

  // Activity tracking
  Timer? _inactivityTimer;
  bool _isDimmed = false;

  // Cached current state for synchronous access
  late BrightnessState _currentState = BrightnessState(
    currentLevel: _dayBrightness,
    isDimmed: false,
    isDaytime: true,
  );

  @override
  Stream<BrightnessState> get brightnessState => _stateController.stream;

  @override
  BrightnessState get currentState => _currentState;

  @override
  void reportActivity() {
    if (_isDimmed) {
      _isDimmed = false;
      _emitState();
      _applyBrightness(_currentBrightnessLevel);
    }
    _resetInactivityTimer();
  }

  @override
  void updateTimeContext(DateTime now, DateTime sunrise, DateTime sunset) {
    _currentTime = now;
    _sunrise = sunrise;
    _sunset = sunset;

    // If not dimmed, update brightness based on new time context
    if (!_isDimmed) {
      _emitState();
      _applyBrightness(_currentBrightnessLevel);
    }

    // Reset inactivity timer on time context update if not already dimmed
    if (!_isDimmed) {
      _resetInactivityTimer();
    }
  }

  @override
  void setDayBrightness(int level) {
    _dayBrightness = level.clamp(0, 10);
    if (!_isDimmed) {
      _emitState();
      _applyBrightness(_currentBrightnessLevel);
    }
  }

  @override
  void setNightBrightness(int level) {
    _nightBrightness = level.clamp(0, 10);
    if (!_isDimmed) {
      _emitState();
      _applyBrightness(_currentBrightnessLevel);
    }
  }

  @override
  void setInactivityTimeout(int minutes) {
    _inactivityTimeoutMinutes = minutes.clamp(0, 60);
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _stateController.close();
  }

  /// Whether it is currently daytime based on the last time context update.
  ///
  /// Returns true (day) when sunrise/sunset are unavailable.
  bool get _isDaytime {
    if (_currentTime == null || _sunrise == null || _sunset == null) {
      // Default to day brightness when sunrise/sunset unavailable
      return true;
    }
    return !_currentTime!.isBefore(_sunrise!) &&
        _currentTime!.isBefore(_sunset!);
  }

  /// The brightness level that should be active based on time of day.
  int get _currentBrightnessLevel {
    if (_isDimmed) return 0;
    return _isDaytime ? _dayBrightness : _nightBrightness;
  }

  /// Resets the inactivity timer.
  ///
  /// If timeout is 0, auto-dimming is disabled and no timer is started.
  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;

    if (_inactivityTimeoutMinutes == 0) {
      // Timeout 0 disables auto-dimming
      return;
    }

    _inactivityTimer = Timer(
      Duration(minutes: _inactivityTimeoutMinutes),
      _onInactivityTimeout,
    );
  }

  /// Called when the inactivity timer fires.
  ///
  /// Dims the display to off (brightness level 0).
  void _onInactivityTimeout() {
    _isDimmed = true;
    _emitState();
    _applyBrightness(0);
  }

  /// Emits the current brightness state to the stream.
  void _emitState() {
    _currentState = BrightnessState(
      currentLevel: _currentBrightnessLevel,
      isDimmed: _isDimmed,
      isDaytime: _isDaytime,
    );
    _stateController.add(_currentState);
  }

  /// Applies the brightness level via platform channel.
  ///
  /// The level is on a 0-10 scale, which the native side maps to the
  /// platform-appropriate brightness API.
  void _applyBrightness(int level) {
    _methodChannel.invokeMethod<void>('setBrightness', {'level': level});
  }
}
