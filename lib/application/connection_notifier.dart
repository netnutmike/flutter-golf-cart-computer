/// Connection management notifier for the Golf Cart Computer.
///
/// Manages independent connection state for Meshtastic (BLE) and GCI
/// (Bluetooth Classic/BLE) connections. Coordinates initial connection
/// on app startup using persisted device identifiers, handles permission
/// checks, and sends protocol messages on connection establishment.
///
/// Requirements: 17.1, 17.2, 17.3, 17.4, 17.5, 2.8, 3.8
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/repositories/cache_repository.dart';
import '../data/repositories/preferences_repository.dart';
import '../data/services/meshtastic_service.dart';
import '../data/services/telemetry_service.dart';
import '../domain/models/connection_state.dart' as app;
import '../domain/models/user_preferences.dart';

/// Simplified connection status exposed to the UI.
///
/// Maps the detailed [app.ConnectionState] to the four states required
/// by Requirement 17.2.
enum ConnectionStatus {
  /// No active connection.
  disconnected,

  /// Connection attempt in progress (includes scanning and handshaking).
  connecting,

  /// Fully connected and operational.
  connected,

  /// Connection lost, attempting automatic reconnection.
  reconnecting,
}

/// Combined connection state for both Meshtastic and GCI connections.
class DualConnectionState {
  /// Current Meshtastic connection status.
  final ConnectionStatus meshtastic;

  /// Current GCI connection status.
  final ConnectionStatus gci;

  const DualConnectionState({
    this.meshtastic = ConnectionStatus.disconnected,
    this.gci = ConnectionStatus.disconnected,
  });

  /// Creates a copy with optional field overrides.
  DualConnectionState copyWith({
    ConnectionStatus? meshtastic,
    ConnectionStatus? gci,
  }) {
    return DualConnectionState(
      meshtastic: meshtastic ?? this.meshtastic,
      gci: gci ?? this.gci,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DualConnectionState &&
          runtimeType == other.runtimeType &&
          meshtastic == other.meshtastic &&
          gci == other.gci;

  @override
  int get hashCode => Object.hash(meshtastic, gci);
}

/// Maps a detailed [app.ConnectionState] to a simplified [ConnectionStatus].
ConnectionStatus _mapConnectionState(app.ConnectionState state) {
  switch (state) {
    case app.ConnectionState.disconnected:
      return ConnectionStatus.disconnected;
    case app.ConnectionState.scanning:
    case app.ConnectionState.connecting:
    case app.ConnectionState.connected:
    case app.ConnectionState.handshaking:
      return ConnectionStatus.connecting;
    case app.ConnectionState.ready:
      return ConnectionStatus.connected;
    case app.ConnectionState.reconnecting:
      return ConnectionStatus.reconnecting;
  }
}

/// AWAKE notification message sent on Meshtastic connection established.
///
/// Requirement 2.8: Send AWAKE notification on channel 0 to broadcast.
const String kAwakeMessage = '~#01#GC#AWAKE#';

/// Stale cache request message sent when cached data is outdated.
///
/// Requirement 3.8: Request fresh weather and entertainment data.
const String kStaleCacheRequestMessage = '~#01#GC#REQ_WX_ENT#';

/// Broadcast address for Meshtastic messages.
const int kBroadcastAddress = 0xFFFFFFFF;

/// Channel 0 for system messages.
const int kSystemChannel = 0;

/// Manages dual Bluetooth connections (Meshtastic + GCI) with independent
/// state tracking, permission handling, and startup coordination.
///
/// Uses Riverpod [StateNotifier] pattern to expose [DualConnectionState]
/// to the UI layer.
class ConnectionNotifier extends StateNotifier<DualConnectionState> {
  final MeshtasticService _meshtasticService;
  final TelemetryService _telemetryService;
  final PreferencesRepository _preferencesRepository;
  final CacheRepository _cacheRepository;

  StreamSubscription<app.ConnectionState>? _meshtasticStateSub;
  StreamSubscription<app.ConnectionState>? _gciStateSub;

  /// Tracks whether the AWAKE message has been sent for the current session.
  bool _awakeSent = false;

  /// Tracks whether the stale cache request has been sent for the current session.
  bool _staleCacheRequestSent = false;

  /// The loaded user preferences (cached after initial load).
  UserPreferences? _preferences;

  ConnectionNotifier({
    required MeshtasticService meshtasticService,
    required TelemetryService telemetryService,
    required PreferencesRepository preferencesRepository,
    required CacheRepository cacheRepository,
  })  : _meshtasticService = meshtasticService,
        _telemetryService = telemetryService,
        _preferencesRepository = preferencesRepository,
        _cacheRepository = cacheRepository,
        super(const DualConnectionState()) {
    _subscribeToConnectionStates();
  }

  /// Subscribes to connection state streams from both services.
  void _subscribeToConnectionStates() {
    _meshtasticStateSub =
        _meshtasticService.connectionState.listen(_onMeshtasticStateChanged);
    _gciStateSub =
        _telemetryService.connectionState.listen(_onGciStateChanged);
  }

  /// Handles Meshtastic connection state changes.
  void _onMeshtasticStateChanged(app.ConnectionState rawState) {
    final status = _mapConnectionState(rawState);
    state = state.copyWith(meshtastic: status);

    // Requirement 2.8: Send AWAKE on first connection established.
    if (rawState == app.ConnectionState.ready && !_awakeSent) {
      _sendAwakeNotification();
    }
  }

  /// Handles GCI connection state changes.
  void _onGciStateChanged(app.ConnectionState rawState) {
    final status = _mapConnectionState(rawState);
    state = state.copyWith(gci: status);
  }

  /// Coordinates initial connection on app startup.
  ///
  /// Loads persisted device identifiers and attempts connection to both
  /// Meshtastic and GCI if configured. Checks permissions before connecting.
  Future<void> initialize() async {
    _preferences = await _preferencesRepository.loadPreferences();

    // Check permissions before attempting connections.
    final hasBluetoothPermission = await _checkBluetoothPermissions();
    if (!hasBluetoothPermission) {
      // Cannot connect without Bluetooth permissions.
      // State remains disconnected; UI should prompt user.
      return;
    }

    // Connect to Meshtastic if enabled and device ID is persisted.
    if (_preferences!.meshtasticEnabled &&
        _preferences!.meshtasticDeviceId != null) {
      _connectMeshtastic(_preferences!.meshtasticDeviceId!);
    }

    // Connect to GCI if device address is persisted.
    if (_preferences!.gciDeviceAddress != null) {
      _connectGci(_preferences!.gciDeviceAddress!);
    }
  }

  /// Checks and requests Bluetooth permissions.
  ///
  /// Returns true if all required Bluetooth permissions are granted.
  /// Requirement 17.6: Request permissions before connection attempts.
  Future<bool> _checkBluetoothPermissions() async {
    final bluetoothScan = await Permission.bluetoothScan.status;
    final bluetoothConnect = await Permission.bluetoothConnect.status;

    if (bluetoothScan.isGranted && bluetoothConnect.isGranted) {
      return true;
    }

    // Request permissions that are not yet granted.
    final results = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final scanGranted = results[Permission.bluetoothScan]?.isGranted ?? false;
    final connectGranted =
        results[Permission.bluetoothConnect]?.isGranted ?? false;

    return scanGranted && connectGranted;
  }

  /// Initiates Meshtastic connection.
  Future<void> _connectMeshtastic(String deviceId) async {
    state = state.copyWith(meshtastic: ConnectionStatus.connecting);
    try {
      await _meshtasticService.connect(deviceId);
    } catch (_) {
      // Connection errors are handled by the service's reconnection logic.
      // State will be updated via the stream subscription.
    }
  }

  /// Initiates GCI connection.
  Future<void> _connectGci(String deviceAddress) async {
    state = state.copyWith(gci: ConnectionStatus.connecting);
    try {
      await _telemetryService.connect(deviceAddress);
    } catch (_) {
      // Connection errors are handled by the service's reconnection logic.
      // State will be updated via the stream subscription.
    }
  }

  /// Sends the AWAKE notification on Meshtastic connection established.
  ///
  /// Requirement 2.8: Send `~#01#GC#AWAKE#` on channel 0 to broadcast.
  Future<void> _sendAwakeNotification() async {
    _awakeSent = true;
    try {
      await _meshtasticService.sendTextMessage(
        kAwakeMessage,
        kBroadcastAddress,
        kSystemChannel,
      );
    } catch (_) {
      // Best effort — don't fail the connection flow.
    }

    // After AWAKE, check if cache is stale and send request if needed.
    await _checkAndRequestStaleCache();
  }

  /// Checks if cached weather/venue data is stale and sends a request
  /// for fresh data if needed.
  ///
  /// Requirement 3.8: If stored data is from a previous day or absent,
  /// send `~#01#GC#REQ_WX_ENT#` on channel 0 to broadcast.
  Future<void> _checkAndRequestStaleCache() async {
    if (_staleCacheRequestSent) return;

    final now = DateTime.now();
    final currentDate = now.year * 10000 + now.month * 100 + now.day;

    final cachedWeather = await _cacheRepository.loadCachedWeather();
    final cachedVenue = await _cacheRepository.loadCachedVenue();

    final weatherStale =
        cachedWeather == null || cachedWeather.dateYYYYMMDD != currentDate;
    final venueStale =
        cachedVenue == null || cachedVenue.dateYYYYMMDD != currentDate;

    if (weatherStale || venueStale) {
      _staleCacheRequestSent = true;
      try {
        await _meshtasticService.sendTextMessage(
          kStaleCacheRequestMessage,
          kBroadcastAddress,
          kSystemChannel,
        );
      } catch (_) {
        // Best effort — don't fail the connection flow.
      }
    }
  }

  /// Manually triggers a Meshtastic connection attempt.
  ///
  /// Used when the user enables Meshtastic or selects a new device.
  Future<void> connectMeshtastic(String deviceId) async {
    final hasPermission = await _checkBluetoothPermissions();
    if (!hasPermission) return;
    await _connectMeshtastic(deviceId);
  }

  /// Manually triggers a GCI connection attempt.
  ///
  /// Used when the user pairs a new GCI device.
  Future<void> connectGci(String deviceAddress) async {
    final hasPermission = await _checkBluetoothPermissions();
    if (!hasPermission) return;
    await _connectGci(deviceAddress);
  }

  /// Disconnects from the Meshtastic radio.
  Future<void> disconnectMeshtastic() async {
    await _meshtasticService.disconnect();
  }

  /// Disconnects from the GCI.
  Future<void> disconnectGci() async {
    await _telemetryService.disconnect();
  }

  /// Returns the current dual connection state.
  ///
  /// Provides read access to the connection state for external observers
  /// (e.g., lifecycle observer) that need to check connection status.
  DualConnectionState get currentState => state;

  /// Attempts reconnection for any disconnected services.
  ///
  /// Checks current connection states and re-initializes connections
  /// for any service that is currently disconnected. Used by the lifecycle
  /// observer when the app returns to the foreground.
  ///
  /// Requirement 20.5: Reconnect within 5 seconds of returning to foreground.
  Future<void> reconnectIfNeeded() async {
    final current = state;
    if (current.meshtastic == ConnectionStatus.disconnected ||
        current.gci == ConnectionStatus.disconnected) {
      await initialize();
    }
  }

  @override
  void dispose() {
    _meshtasticStateSub?.cancel();
    _gciStateSub?.cancel();
    super.dispose();
  }
}
