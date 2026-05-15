/// App lifecycle observer for background connectivity and state persistence.
///
/// Observes [AppLifecycleState] transitions to:
/// - Start the Android foreground service on app launch
/// - Persist odometer and driving hours before entering background
/// - Maintain Bluetooth connections when backgrounded
/// - Trigger reconnection on foreground return if connections were lost
/// - Handle app termination gracefully
///
/// Requirements: 20.1, 20.2, 20.3, 20.4, 20.5, 20.6, 20.7, 11.7
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/services/background_service.dart';
import 'connection_notifier.dart';
import 'main_notifier.dart';

/// Duration to wait before attempting reconnection on foreground return.
///
/// Requirement 20.5: Reconnect within 5 seconds of returning to foreground.
const Duration _kReconnectionDelay = Duration(seconds: 1);

/// Observes app lifecycle state and coordinates background connectivity.
///
/// This observer should be registered once during app startup and removed
/// on disposal. It manages:
/// - Android foreground service start/stop
/// - State persistence before backgrounding
/// - Reconnection attempts on foreground return
class AppLifecycleObserver with WidgetsBindingObserver {
  /// The background service for platform-specific background execution.
  final BackgroundService _backgroundService;

  /// The main notifier for persisting state before background/shutdown.
  final MainNotifier _mainNotifier;

  /// The connection notifier for checking/restoring connections.
  final ConnectionNotifier _connectionNotifier;

  /// Whether the foreground service has been started.
  bool _foregroundServiceStarted = false;

  /// Whether the app is currently in the background.
  bool _isInBackground = false;

  /// Creates an [AppLifecycleObserver] and registers it with [WidgetsBinding].
  AppLifecycleObserver({
    required BackgroundService backgroundService,
    required MainNotifier mainNotifier,
    required ConnectionNotifier connectionNotifier,
  })  : _backgroundService = backgroundService,
        _mainNotifier = mainNotifier,
        _connectionNotifier = connectionNotifier;

  /// Initializes the observer by registering with [WidgetsBinding] and
  /// starting the Android foreground service.
  ///
  /// Requirement 20.2: Start foreground service on Android at app launch.
  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    await _startForegroundService();
  }

  /// Starts the Android foreground service for background Bluetooth
  /// connectivity.
  ///
  /// On iOS this is a no-op since background modes are declared in Info.plist.
  /// Requirement 20.2: Use foreground service with persistent notification.
  Future<void> _startForegroundService() async {
    if (_foregroundServiceStarted) return;
    await _backgroundService.startForegroundService();
    _foregroundServiceStarted = true;
  }

  /// Handles app lifecycle state changes.
  ///
  /// - [AppLifecycleState.inactive]: App is transitioning (e.g., phone call).
  /// - [AppLifecycleState.paused]: App is in the background.
  /// - [AppLifecycleState.resumed]: App has returned to the foreground.
  /// - [AppLifecycleState.detached]: App is being terminated.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _onEnteredBackground();
      case AppLifecycleState.resumed:
        _onReturnedToForeground();
      case AppLifecycleState.detached:
        _onAppTerminating();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // No action needed for transient states.
        break;
    }
  }

  /// Called when the app enters the background.
  ///
  /// Requirement 11.7: Persist odometer and driving hour values before
  /// entering background.
  /// Requirement 20.1: Maintain BLE connections (handled by foreground service
  /// and iOS background modes).
  /// Requirement 20.6: Continue processing messages in background.
  void _onEnteredBackground() {
    _isInBackground = true;

    // Persist state before backgrounding — fire and forget since we may
    // not have time to await in lifecycle callbacks.
    _mainNotifier.persistBeforeSleep();
  }

  /// Called when the app returns to the foreground.
  ///
  /// Requirement 20.4: Resume displaying live data within 2 seconds.
  /// Requirement 20.5: Reconnect within 5 seconds if OS terminated
  /// connections.
  void _onReturnedToForeground() {
    if (!_isInBackground) return;
    _isInBackground = false;

    // Check connection states and attempt reconnection if needed.
    // Use a short delay to allow the system to stabilize after resume.
    Future.delayed(_kReconnectionDelay, () {
      _checkAndReconnect();
    });
  }

  /// Called when the app is being terminated.
  ///
  /// Requirement 11.7: Persist state before shutdown.
  /// Stops the foreground service to clean up resources.
  void _onAppTerminating() {
    // Persist state — best effort since the app is terminating.
    _mainNotifier.persistBeforeSleep();

    // Stop the foreground service on termination.
    _backgroundService.stopForegroundService();
    _foregroundServiceStarted = false;
  }

  /// Checks connection states and triggers reconnection if connections
  /// were lost while backgrounded.
  ///
  /// Requirement 20.5: Reconnect within 5 seconds of returning to foreground.
  void _checkAndReconnect() {
    _connectionNotifier.reconnectIfNeeded();
  }

  /// Removes this observer from [WidgetsBinding] and stops the foreground
  /// service.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_foregroundServiceStarted) {
      _backgroundService.stopForegroundService();
      _foregroundServiceStarted = false;
    }
  }
}
