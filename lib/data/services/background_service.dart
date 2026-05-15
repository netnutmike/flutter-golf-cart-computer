import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Abstract interface for platform-specific background execution.
///
/// On Android, this manages a foreground service with a persistent notification
/// to maintain Bluetooth and GPS connectivity when the app is backgrounded.
///
/// On iOS, background execution is handled via declared background modes
/// (`bluetooth-central` and `location`) in Info.plist, so start/stop are no-ops.
abstract class BackgroundService {
  /// Starts the foreground service (Android only).
  ///
  /// On iOS this is a no-op since background modes are declared in Info.plist.
  Future<void> startForegroundService();

  /// Stops the foreground service (Android only).
  ///
  /// On iOS this is a no-op.
  Future<void> stopForegroundService();

  /// Stream that emits `true` when the app is running in the background,
  /// and `false` when it returns to the foreground.
  Stream<bool> get isRunningInBackground;

  /// Disposes resources held by this service.
  void dispose();
}

/// Platform channel implementation of [BackgroundService].
///
/// Uses a [MethodChannel] to communicate with native Android code for
/// foreground service management, and an [EventChannel] to receive
/// background/foreground lifecycle state changes from the platform.
///
/// On iOS, start/stop foreground service calls are no-ops because iOS uses
/// declared background modes (`bluetooth-central`, `location`) in Info.plist
/// to maintain BLE connections and GPS updates when backgrounded.
class PlatformBackgroundService implements BackgroundService {
  /// Platform channel for invoking native foreground service methods.
  static const MethodChannel _methodChannel =
      MethodChannel('com.golfcart.golf_cart_computer/background_service');

  /// Event channel for receiving background/foreground state changes.
  static const EventChannel _eventChannel =
      EventChannel('com.golfcart.golf_cart_computer/background_state');

  final StreamController<bool> _backgroundStateController =
      StreamController<bool>.broadcast();

  StreamSubscription<dynamic>? _eventSubscription;

  /// Whether the foreground service is currently running (Android only).
  bool _isServiceRunning = false;

  PlatformBackgroundService() {
    _listenToLifecycleEvents();
  }

  void _listenToLifecycleEvents() {
    _eventSubscription = _eventChannel
        .receiveBroadcastStream()
        .listen(
          (dynamic event) {
            if (event is bool) {
              _backgroundStateController.add(event);
            }
          },
          onError: (dynamic error) {
            // On platforms where the event channel is not implemented,
            // silently ignore errors. The stream will simply not emit.
          },
        );
  }

  @override
  Future<void> startForegroundService() async {
    if (!Platform.isAndroid) {
      // iOS uses declared background modes; no foreground service needed.
      return;
    }
    if (_isServiceRunning) {
      return;
    }
    try {
      await _methodChannel.invokeMethod<void>('startForegroundService');
      _isServiceRunning = true;
    } on PlatformException catch (_) {
      // If the platform channel is not yet implemented on the native side,
      // fail gracefully. The service will be implemented in native code.
      _isServiceRunning = false;
    } on MissingPluginException catch (_) {
      // Channel not registered on this platform — expected during testing
      // or if native side is not yet implemented.
      _isServiceRunning = false;
    }
  }

  @override
  Future<void> stopForegroundService() async {
    if (!Platform.isAndroid) {
      // iOS uses declared background modes; no foreground service to stop.
      return;
    }
    if (!_isServiceRunning) {
      return;
    }
    try {
      await _methodChannel.invokeMethod<void>('stopForegroundService');
      _isServiceRunning = false;
    } on PlatformException catch (_) {
      // Fail gracefully if native side is not available.
    } on MissingPluginException catch (_) {
      _isServiceRunning = false;
    }
  }

  @override
  Stream<bool> get isRunningInBackground => _backgroundStateController.stream;

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _backgroundStateController.close();
  }
}
