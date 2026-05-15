/// Telemetry service for GCI ESP-32 Bluetooth communication.
///
/// Manages the Bluetooth connection to the GCI (Golf Cart Internal) computer,
/// handling message framing, telemetry data parsing, heartbeat keep-alive,
/// pairing, and platform-specific transport (BLE on iOS, Bluetooth Classic
/// SPP preferred on Android with BLE fallback).
library;

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/connection_state.dart' as app;
import '../../domain/models/gci_message.dart';
import '../../domain/models/telemetry_data.dart';

/// Abstract interface for the GCI telemetry service.
///
/// Provides connection management, telemetry data streaming, heartbeat,
/// GPS data sending, and status notifications to the GCI.
abstract class TelemetryService {
  /// Stream of connection state changes.
  Stream<app.ConnectionState> get connectionState;

  /// Stream of parsed telemetry data from the GCI.
  Stream<TelemetryData> get telemetryData;

  /// Connects to the GCI at the given device address.
  Future<void> connect(String deviceAddress);

  /// Disconnects from the GCI.
  Future<void> disconnect();

  /// Sends a heartbeat message to the GCI.
  Future<void> sendHeartbeat();

  /// Sends GPS data to the GCI.
  Future<void> sendGpsData(GciGpsPayload gpsData);

  /// Sends the at-home status to the GCI (single-byte boolean payload).
  Future<void> sendIsHome(bool isHome);

  /// Sends the daytime status to the GCI (single-byte boolean payload).
  Future<void> sendIsDaytime(bool isDaytime);

  /// Initiates pairing with a new GCI device via broadcast discovery.
  ///
  /// Broadcasts a pairing command and waits for an ACK within [timeout].
  /// If no ACK is received, restores the previously paired device address.
  Future<void> pairNewDevice({Duration timeout = const Duration(seconds: 6)});

  /// Disposes resources held by this service.
  void dispose();
}

/// GCI message envelope header size in bytes.
///
/// Wire format: type(1) + timestamp(4 LE) + seq_num(2 LE) + data_len(2 LE) = 9 bytes.
const int _kHeaderSize = 9;

/// Heartbeat interval in seconds.
const int _kHeartbeatIntervalSeconds = 10;

/// Timeout for disconnect detection (4 missed heartbeats).
const int _kTimeoutSeconds = 40;

/// Pairing timeout in seconds.
const int _kPairingTimeoutSeconds = 6;

/// Initial reconnection backoff delay.
const Duration _kInitialBackoff = Duration(seconds: 2);

/// Maximum reconnection backoff delay.
const Duration _kMaxBackoff = Duration(seconds: 60);

/// SharedPreferences key for persisted GCI device address.
const String _kGciDeviceAddressKey = 'pref_gci_device_address';

/// GCI command code for adding a peer (pairing).
const int _kCmdAddPeer = 1;

// --- Message Encoding/Decoding Utilities ---

/// Encodes a [GciMessage] into its wire-format byte representation.
///
/// Wire format:
/// ```
/// | type (1 byte) | timestamp (4 bytes LE) | seq_num (2 bytes LE) | data_len (2 bytes LE) | data (variable) |
/// ```
Uint8List encodeGciMessage(GciMessage message) {
  final dataLen = message.payload.length;
  final buffer = ByteData(_kHeaderSize + dataLen);

  // Type (1 byte)
  buffer.setUint8(0, message.type.code);

  // Timestamp (4 bytes, little-endian)
  buffer.setUint32(1, message.timestamp, Endian.little);

  // Sequence number (2 bytes, little-endian)
  buffer.setUint16(5, message.sequenceNumber, Endian.little);

  // Data length (2 bytes, little-endian)
  buffer.setUint16(7, dataLen, Endian.little);

  // Copy payload data
  final bytes = buffer.buffer.asUint8List();
  bytes.setRange(_kHeaderSize, _kHeaderSize + dataLen, message.payload);

  return bytes;
}

/// Decodes a wire-format byte buffer into a [GciMessage].
///
/// Returns null if the buffer is too short or the message type is unrecognized.
GciMessage? decodeGciMessage(Uint8List data) {
  if (data.length < _kHeaderSize) return null;

  final byteData = ByteData.sublistView(data);

  // Type (1 byte)
  final typeCode = byteData.getUint8(0);
  final type = GciMessageType.fromCode(typeCode);
  if (type == null) return null;

  // Timestamp (4 bytes, little-endian)
  final timestamp = byteData.getUint32(1, Endian.little);

  // Sequence number (2 bytes, little-endian)
  final sequenceNumber = byteData.getUint16(5, Endian.little);

  // Data length (2 bytes, little-endian)
  final dataLen = byteData.getUint16(7, Endian.little);

  // Validate we have enough data
  if (data.length < _kHeaderSize + dataLen) return null;

  // Extract payload
  final payload = Uint8List.fromList(
    data.sublist(_kHeaderSize, _kHeaderSize + dataLen),
  );

  return GciMessage(
    type: type,
    timestamp: timestamp,
    sequenceNumber: sequenceNumber,
    payload: payload,
  );
}

/// Parses a 20-byte little-endian telemetry payload into a [GciTelemetryPayload].
///
/// Returns null if the payload is fewer than 20 bytes.
GciTelemetryPayload? parseTelemetryPayload(Uint8List payload) {
  if (payload.length < 20) return null;

  final byteData = ByteData.sublistView(payload);

  return GciTelemetryPayload(
    modeLights: byteData.getInt32(0, Endian.little),
    outdoorLum: byteData.getInt32(4, Endian.little),
    airTemp: byteData.getFloat32(8, Endian.little),
    battVolts: byteData.getFloat32(12, Endian.little),
    fuel: byteData.getFloat32(16, Endian.little),
  );
}

/// Encodes a [GciGpsPayload] into a 24-byte little-endian buffer.
///
/// Layout: latitude(f64) + longitude(f64) + altitude(f32) + speed(f32) + heading(f32) + satelliteCount(i32)
/// Note: The design specifies float64 for lat/lon but the total is 24 bytes,
/// which means: lat(8) + lon(8) + alt(4) + speed(4) = 24 bytes.
/// However, the spec says 24 bytes with 6 fields. Recalculating:
/// If lat/lon are float32: 4+4+4+4+4+4 = 24 bytes.
/// The design says "latitude(float64?), longitude(float64?)" but that would be 32 bytes.
/// Following the 24-byte constraint from the spec, we use float32 for all fields:
/// lat(f32) + lon(f32) + alt(f32) + speed(f32) + heading(f32) + satCount(i32) = 24 bytes.
Uint8List encodeGpsPayload(GciGpsPayload gpsData) {
  final buffer = ByteData(24);

  buffer.setFloat32(0, gpsData.latitude.toDouble(), Endian.little);
  buffer.setFloat32(4, gpsData.longitude.toDouble(), Endian.little);
  buffer.setFloat32(8, gpsData.altitude.toDouble(), Endian.little);
  buffer.setFloat32(12, gpsData.speed.toDouble(), Endian.little);
  buffer.setFloat32(16, gpsData.heading.toDouble(), Endian.little);
  buffer.setInt32(20, gpsData.satelliteCount, Endian.little);

  return buffer.buffer.asUint8List();
}

/// Encodes a single-byte boolean payload (1 = true, 0 = false).
Uint8List encodeBoolPayload(bool value) {
  return Uint8List.fromList([value ? 1 : 0]);
}

// --- TelemetryService Implementation ---

/// Platform-aware implementation of [TelemetryService].
///
/// Uses BLE on iOS and prefers Bluetooth Classic SPP on Android with BLE
/// fallback. Manages heartbeat keep-alive, timeout detection, pairing,
/// and exponential backoff reconnection.
class PlatformTelemetryService implements TelemetryService {
  /// Platform channel for Bluetooth Classic SPP on Android.
  static const MethodChannel _sppChannel =
      MethodChannel('com.golfcart.golf_cart_computer/bluetooth_spp');

  final StreamController<app.ConnectionState> _connectionStateController =
      StreamController<app.ConnectionState>.broadcast();

  final StreamController<TelemetryData> _telemetryDataController =
      StreamController<TelemetryData>.broadcast();

  /// Current connection state.
  app.ConnectionState _currentState = app.ConnectionState.disconnected;

  /// Sequence number for outbound messages.
  int _sequenceNumber = 0;

  /// Timer for periodic heartbeat sending.
  Timer? _heartbeatTimer;

  /// Timer for timeout detection (no response from GCI).
  Timer? _timeoutTimer;

  /// Timer for reconnection backoff.
  Timer? _reconnectTimer;

  /// Current reconnection backoff duration.
  Duration _currentBackoff = _kInitialBackoff;

  /// Whether we are using BLE transport (vs Bluetooth Classic SPP).
  bool _useBle = true;

  /// The connected BLE device (when using BLE transport).
  BluetoothDevice? _bleDevice;

  /// The BLE characteristic for writing data to GCI.
  BluetoothCharacteristic? _writeCharacteristic;

  /// The BLE characteristic for reading data from GCI.
  BluetoothCharacteristic? _readCharacteristic;

  /// Subscription to BLE characteristic notifications.
  StreamSubscription<List<int>>? _notifySubscription;

  /// Subscription to BLE connection state changes.
  StreamSubscription<BluetoothConnectionState>? _bleConnectionSubscription;

  /// The currently connected/paired device address.
  String? _deviceAddress;

  /// The previously paired device address (for pairing rollback).
  String? _previousDeviceAddress;

  /// Whether the service has been disposed.
  bool _disposed = false;

  /// Whether auto-reconnect is enabled.
  bool _autoReconnect = true;

  /// Buffer for accumulating incoming BLE data.
  final List<int> _receiveBuffer = [];

  /// SharedPreferences instance for persisting device address.
  SharedPreferences? _prefs;

  PlatformTelemetryService();

  @override
  Stream<app.ConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<TelemetryData> get telemetryData => _telemetryDataController.stream;

  @override
  Future<void> connect(String deviceAddress) async {
    if (_disposed) return;

    _deviceAddress = deviceAddress;
    _autoReconnect = true;
    _updateState(app.ConnectionState.connecting);

    try {
      if (Platform.isAndroid) {
        // Try Bluetooth Classic SPP first on Android
        final connected = await _connectSpp(deviceAddress);
        if (!connected) {
          // Fall back to BLE
          _useBle = true;
          await _connectBle(deviceAddress);
        } else {
          _useBle = false;
        }
      } else {
        // iOS: always use BLE
        _useBle = true;
        await _connectBle(deviceAddress);
      }

      _updateState(app.ConnectionState.ready);
      _startHeartbeat();
      _resetTimeout();
      _currentBackoff = _kInitialBackoff;

      // Persist the paired device address
      await _persistDeviceAddress(deviceAddress);
    } catch (e) {
      _updateState(app.ConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    _autoReconnect = false;
    _stopHeartbeat();
    _stopTimeout();
    _cancelReconnect();

    await _disconnectTransport();
    _updateState(app.ConnectionState.disconnected);
  }

  @override
  Future<void> sendHeartbeat() async {
    final message = GciMessage(
      type: GciMessageType.heartbeat,
      timestamp: _currentTimestamp(),
      sequenceNumber: _nextSequenceNumber(),
      payload: Uint8List(0),
    );
    await _sendMessage(message);
  }

  @override
  Future<void> sendGpsData(GciGpsPayload gpsData) async {
    final payload = encodeGpsPayload(gpsData);
    final message = GciMessage(
      type: GciMessageType.gpsData,
      timestamp: _currentTimestamp(),
      sequenceNumber: _nextSequenceNumber(),
      payload: payload,
    );
    await _sendMessage(message);
  }

  @override
  Future<void> sendIsHome(bool isHome) async {
    final message = GciMessage(
      type: GciMessageType.isHome,
      timestamp: _currentTimestamp(),
      sequenceNumber: _nextSequenceNumber(),
      payload: encodeBoolPayload(isHome),
    );
    await _sendMessage(message);
  }

  @override
  Future<void> sendIsDaytime(bool isDaytime) async {
    final message = GciMessage(
      type: GciMessageType.isDaytime,
      timestamp: _currentTimestamp(),
      sequenceNumber: _nextSequenceNumber(),
      payload: encodeBoolPayload(isDaytime),
    );
    await _sendMessage(message);
  }

  @override
  Future<void> pairNewDevice({
    Duration timeout = const Duration(seconds: _kPairingTimeoutSeconds),
  }) async {
    // Save current device address for rollback
    _previousDeviceAddress = _deviceAddress;

    // Disconnect current connection if any
    await _disconnectTransport();
    _stopHeartbeat();
    _stopTimeout();

    _updateState(app.ConnectionState.scanning);

    try {
      // Broadcast discovery: scan for GCI devices
      final device = await _scanForGciDevice(timeout);

      if (device == null) {
        // No device found — restore previous
        _restorePreviousDevice();
        return;
      }

      // Attempt connection and send pairing command
      _deviceAddress = device.remoteId.str;
      _updateState(app.ConnectionState.connecting);

      await _connectBle(_deviceAddress!);
      _useBle = true;

      // Send pairing command with MAC address
      final macBytes = _parseMacAddress(_deviceAddress!);
      final commandPayload = _buildCommandPayload(_kCmdAddPeer, macBytes);

      final pairingMessage = GciMessage(
        type: GciMessageType.command,
        timestamp: _currentTimestamp(),
        sequenceNumber: _nextSequenceNumber(),
        payload: commandPayload,
      );
      await _sendMessage(pairingMessage);

      // Wait for ACK within timeout
      final ackReceived = await _waitForAck(timeout);

      if (!ackReceived) {
        // No ACK — disconnect and restore previous
        await _disconnectTransport();
        _restorePreviousDevice();
        return;
      }

      // Pairing successful
      _updateState(app.ConnectionState.ready);
      _startHeartbeat();
      _resetTimeout();
      _currentBackoff = _kInitialBackoff;

      // Persist new device address
      await _persistDeviceAddress(_deviceAddress!);
    } catch (e) {
      _restorePreviousDevice();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stopHeartbeat();
    _stopTimeout();
    _cancelReconnect();
    _notifySubscription?.cancel();
    _bleConnectionSubscription?.cancel();
    _connectionStateController.close();
    _telemetryDataController.close();
  }

  // --- Private: Transport Layer ---

  /// Attempts a Bluetooth Classic SPP connection on Android via platform channel.
  Future<bool> _connectSpp(String deviceAddress) async {
    try {
      final result = await _sppChannel.invokeMethod<bool>(
        'connect',
        {'address': deviceAddress},
      );
      if (result == true) {
        // Set up SPP data listener
        _sppChannel.setMethodCallHandler(_handleSppMethodCall);
        return true;
      }
      return false;
    } on PlatformException catch (_) {
      return false;
    } on MissingPluginException catch (_) {
      return false;
    }
  }

  /// Handles incoming method calls from the SPP platform channel.
  Future<dynamic> _handleSppMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDataReceived':
        final data = call.arguments as Uint8List?;
        if (data != null) {
          _onDataReceived(data);
        }
      case 'onDisconnected':
        _onTransportDisconnected();
    }
    return null;
  }

  /// Connects to the GCI via BLE.
  Future<void> _connectBle(String deviceAddress) async {
    final deviceId = DeviceIdentifier(deviceAddress);
    _bleDevice = BluetoothDevice(remoteId: deviceId);

    await _bleDevice!.connect(timeout: const Duration(seconds: 15));

    // Discover services
    final services = await _bleDevice!.discoverServices();

    // Find the GCI service and characteristics
    // GCI uses a simple UART-like BLE service
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.properties.write ||
            characteristic.properties.writeWithoutResponse) {
          _writeCharacteristic = characteristic;
        }
        if (characteristic.properties.notify) {
          _readCharacteristic = characteristic;
        }
      }
    }

    if (_writeCharacteristic == null) {
      throw Exception('GCI write characteristic not found');
    }

    // Subscribe to notifications if available
    if (_readCharacteristic != null) {
      await _readCharacteristic!.setNotifyValue(true);
      _notifySubscription = _readCharacteristic!.onValueReceived.listen(
        (data) => _onDataReceived(Uint8List.fromList(data)),
      );
    }

    // Listen for BLE disconnection events
    _bleConnectionSubscription = _bleDevice!.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _onTransportDisconnected();
      }
    });
  }

  /// Disconnects the current transport (BLE or SPP).
  Future<void> _disconnectTransport() async {
    _notifySubscription?.cancel();
    _notifySubscription = null;
    _bleConnectionSubscription?.cancel();
    _bleConnectionSubscription = null;

    if (_useBle && _bleDevice != null) {
      try {
        await _bleDevice!.disconnect();
      } catch (_) {
        // Ignore disconnect errors
      }
      _bleDevice = null;
      _writeCharacteristic = null;
      _readCharacteristic = null;
    } else if (!_useBle) {
      try {
        await _sppChannel.invokeMethod<void>('disconnect');
      } catch (_) {
        // Ignore disconnect errors
      }
    }

    _receiveBuffer.clear();
  }

  /// Sends a raw byte buffer over the current transport.
  Future<void> _sendRawBytes(Uint8List data) async {
    if (_useBle) {
      if (_writeCharacteristic == null) return;
      await _writeCharacteristic!.write(data, withoutResponse: false);
    } else {
      try {
        await _sppChannel.invokeMethod<void>('write', {'data': data});
      } catch (_) {
        // Write failure — transport may be disconnected
      }
    }
  }

  // --- Private: Message Handling ---

  /// Sends a [GciMessage] by encoding it and writing to the transport.
  Future<void> _sendMessage(GciMessage message) async {
    final encoded = encodeGciMessage(message);
    await _sendRawBytes(encoded);
  }

  /// Called when data is received from the transport.
  void _onDataReceived(Uint8List data) {
    _receiveBuffer.addAll(data);
    _processReceiveBuffer();
  }

  /// Processes the receive buffer, extracting complete messages.
  void _processReceiveBuffer() {
    while (_receiveBuffer.length >= _kHeaderSize) {
      // Peek at data_len to determine if we have a complete message
      final headerBytes = Uint8List.fromList(_receiveBuffer.sublist(0, _kHeaderSize));
      final byteData = ByteData.sublistView(headerBytes);
      final dataLen = byteData.getUint16(7, Endian.little);

      final totalLen = _kHeaderSize + dataLen;
      if (_receiveBuffer.length < totalLen) {
        // Not enough data yet — wait for more
        break;
      }

      // Extract the complete message bytes
      final messageBytes = Uint8List.fromList(
        _receiveBuffer.sublist(0, totalLen),
      );
      _receiveBuffer.removeRange(0, totalLen);

      // Decode and handle the message
      final message = decodeGciMessage(messageBytes);
      if (message != null) {
        _handleIncomingMessage(message);
      }
    }
  }

  /// Handles a decoded incoming GCI message.
  void _handleIncomingMessage(GciMessage message) {
    // Any valid message resets the timeout
    _resetTimeout();

    switch (message.type) {
      case GciMessageType.telemetry:
        _handleTelemetryMessage(message);
      case GciMessageType.ack:
        _handleAckMessage(message);
      case GciMessageType.heartbeat:
        // Heartbeat response received — timeout already reset above
        break;
      default:
        // Other message types are not expected from GCI
        break;
    }
  }

  /// Handles an incoming telemetry message.
  void _handleTelemetryMessage(GciMessage message) {
    // Requirement 8.17: discard packets with payload < 20 bytes
    if (message.payload.length < 20) return;

    final telemetryPayload = parseTelemetryPayload(message.payload);
    if (telemetryPayload == null) return;

    final telemetry = TelemetryData(
      headlightMode: telemetryPayload.modeLights,
      outdoorLuminosity: telemetryPayload.outdoorLum,
      airTemperature: telemetryPayload.airTemp,
      batteryVoltage: telemetryPayload.battVolts,
      fuelLevel: telemetryPayload.fuel,
      lastUpdated: DateTime.now(),
    );

    _telemetryDataController.add(telemetry);
  }

  /// Completer for ACK waiting during pairing.
  Completer<bool>? _ackCompleter;

  /// Handles an incoming ACK message.
  void _handleAckMessage(GciMessage message) {
    _ackCompleter?.complete(true);
  }

  /// Waits for an ACK message within the given timeout.
  Future<bool> _waitForAck(Duration timeout) async {
    _ackCompleter = Completer<bool>();
    try {
      return await _ackCompleter!.future.timeout(
        timeout,
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    } finally {
      _ackCompleter = null;
    }
  }

  // --- Private: Heartbeat and Timeout ---

  /// Starts the periodic heartbeat timer.
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: _kHeartbeatIntervalSeconds),
      (_) => sendHeartbeat(),
    );
  }

  /// Stops the heartbeat timer.
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Resets the timeout timer (called on any received message).
  void _resetTimeout() {
    _stopTimeout();
    _timeoutTimer = Timer(
      const Duration(seconds: _kTimeoutSeconds),
      _onTimeout,
    );
  }

  /// Stops the timeout timer.
  void _stopTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// Called when the timeout expires (4 missed heartbeats).
  void _onTimeout() {
    _stopHeartbeat();
    _stopTimeout();
    _disconnectTransport();
    _updateState(app.ConnectionState.disconnected);
    _scheduleReconnect();
  }

  // --- Private: Reconnection ---

  /// Called when the transport layer reports a disconnection.
  void _onTransportDisconnected() {
    if (_disposed) return;
    if (_currentState == app.ConnectionState.disconnected) return;

    _stopHeartbeat();
    _stopTimeout();
    _updateState(app.ConnectionState.disconnected);

    if (_autoReconnect) {
      _scheduleReconnect();
    }
  }

  /// Schedules a reconnection attempt with exponential backoff.
  void _scheduleReconnect() {
    if (_disposed || !_autoReconnect || _deviceAddress == null) return;

    _cancelReconnect();
    _updateState(app.ConnectionState.reconnecting);

    _reconnectTimer = Timer(_currentBackoff, () {
      _attemptReconnect();
    });

    // Increase backoff for next attempt (exponential, capped at max)
    _currentBackoff = Duration(
      milliseconds: (_currentBackoff.inMilliseconds * 2).clamp(
        _kInitialBackoff.inMilliseconds,
        _kMaxBackoff.inMilliseconds,
      ),
    );
  }

  /// Attempts to reconnect to the last known device.
  Future<void> _attemptReconnect() async {
    if (_disposed || !_autoReconnect || _deviceAddress == null) return;

    try {
      await connect(_deviceAddress!);
    } catch (_) {
      // connect() handles its own error state and scheduling
    }
  }

  /// Cancels any pending reconnection timer.
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  // --- Private: Pairing Helpers ---

  /// Scans for a GCI device within the given timeout.
  Future<BluetoothDevice?> _scanForGciDevice(Duration timeout) async {
    BluetoothDevice? foundDevice;

    final scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      for (final result in results) {
        // Accept any device found during pairing scan
        // In production, this would filter by GCI service UUID or name pattern
        if (result.device.platformName.isNotEmpty) {
          foundDevice = result.device;
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: timeout);
    await Future<void>.delayed(timeout);
    await FlutterBluePlus.stopScan();
    await scanSubscription.cancel();

    return foundDevice;
  }

  /// Restores the previously paired device address after a failed pairing.
  void _restorePreviousDevice() {
    _deviceAddress = _previousDeviceAddress;
    _previousDeviceAddress = null;

    if (_deviceAddress != null) {
      _updateState(app.ConnectionState.reconnecting);
      _scheduleReconnect();
    } else {
      _updateState(app.ConnectionState.disconnected);
    }
  }

  /// Builds a command payload with command number and MAC address.
  Uint8List _buildCommandPayload(int cmdNumber, Uint8List macAddress) {
    // Command payload: cmdNumber(1 byte) + macAddress(6 bytes) = 7 bytes
    final buffer = Uint8List(7);
    buffer[0] = cmdNumber;
    buffer.setRange(1, 7, macAddress);
    return buffer;
  }

  /// Parses a MAC address string (e.g., "AA:BB:CC:DD:EE:FF") into 6 bytes.
  Uint8List _parseMacAddress(String address) {
    final parts = address.split(':');
    if (parts.length == 6) {
      return Uint8List.fromList(
        parts.map((p) => int.parse(p, radix: 16)).toList(),
      );
    }
    // If not a standard MAC format, return zeros
    return Uint8List(6);
  }

  // --- Private: State and Utilities ---

  /// Updates the connection state and emits to the stream.
  void _updateState(app.ConnectionState newState) {
    if (_disposed) return;
    _currentState = newState;
    _connectionStateController.add(newState);
  }

  /// Returns the current Unix timestamp in seconds.
  int _currentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// Returns the next sequence number (wraps at 65535).
  int _nextSequenceNumber() {
    final seq = _sequenceNumber;
    _sequenceNumber = (_sequenceNumber + 1) & 0xFFFF;
    return seq;
  }

  /// Persists the paired device address to shared preferences.
  Future<void> _persistDeviceAddress(String address) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_kGciDeviceAddressKey, address);
  }

  /// Loads the persisted device address from shared preferences.
  Future<String?> loadPersistedDeviceAddress() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getString(_kGciDeviceAddressKey);
  }
}
