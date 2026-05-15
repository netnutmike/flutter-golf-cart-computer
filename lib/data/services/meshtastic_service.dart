import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/connection_state.dart' as app;
import '../generated/meshtastic.dart';
import 'packet_framer.dart';

/// Scan result from BLE device discovery.
class MeshtasticScanResult {
  /// The BLE device found during scanning.
  final BluetoothDevice device;

  /// The advertised name of the device.
  final String name;

  /// The RSSI signal strength.
  final int rssi;

  const MeshtasticScanResult({
    required this.device,
    required this.name,
    required this.rssi,
  });
}

/// Abstract interface for Meshtastic radio communication.
///
/// Manages the BLE connection lifecycle, protobuf message framing,
/// handshake protocol, heartbeat/liveness monitoring, and message routing.
abstract class MeshtasticService {
  /// Stream of connection state changes.
  Stream<app.ConnectionState> get connectionState;

  /// Stream of the local node ID (hex string, e.g. "!a1b2c3d4").
  Stream<String> get nodeId;

  /// Stream of incoming decoded mesh packets.
  Stream<MeshPacket> get incomingPackets;

  /// Connects to a Meshtastic device by its platform identifier.
  Future<void> connect(String deviceId);

  /// Disconnects from the currently connected device.
  Future<void> disconnect();

  /// Scans for Meshtastic devices matching the name pattern.
  ///
  /// Returns devices found within the [timeout] duration (default 10s).
  Future<List<MeshtasticScanResult>> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  });

  /// Sends a text message to the specified destination on the given channel.
  Future<void> sendTextMessage(String text, int destination, int channel);

  /// Sends an admin message to the local node.
  Future<void> sendAdminMessage(AdminMessage message);

  /// Sets the position configuration on the radio.
  Future<void> setPositionConfig(Config_PositionConfig config);

  /// Reboots the radio after the specified delay.
  Future<void> rebootRadio({int delaySeconds = 5});
}

/// BLE-based implementation of [MeshtasticService].
///
/// Uses flutter_blue_plus for cross-platform BLE communication with the
/// Meshtastic radio. Implements the full connection lifecycle including
/// scanning, MTU negotiation, GATT subscription, handshake, heartbeat,
/// liveness timeout, and exponential backoff reconnection.
class BleMeshtasticService implements MeshtasticService {
  /// Meshtastic BLE service UUID.
  static const String serviceUuid = '6ba1b218-15a8-461f-9fa8-5dcae273eafd';

  /// TORADIO characteristic UUID (write).
  static const String toRadioUuid = 'f75c76d2-129e-4dad-a1dd-7866124401e7';

  /// FROMRADIO characteristic UUID (read).
  static const String fromRadioUuid = '2c55e69e-4993-11ed-b878-0242ac120002';

  /// FROMNUM characteristic UUID (notify).
  static const String fromNumUuid = 'ed9da18c-a800-4f66-a670-aa7547e34453';

  /// SharedPreferences key for persisted device ID.
  static const String _bondedDeviceKey = 'meshtastic_bonded_device_id';

  /// Name pattern for Meshtastic devices.
  static final RegExp _namePattern = RegExp(r'^.*_([0-9a-fA-F]{4})$');

  /// Heartbeat interval.
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  /// Liveness timeout (no data received after heartbeat).
  static const Duration _livenessTimeout = Duration(seconds: 60);

  /// Initial reconnection backoff delay.
  static const Duration _initialBackoff = Duration(seconds: 2);

  /// Maximum reconnection backoff delay.
  static const Duration _maxBackoff = Duration(seconds: 60);

  /// Maximum number of reconnection attempts.
  static const int _maxReconnectAttempts = 10;

  final PacketFramer _framer = PacketFramer();
  final Random _random = Random();

  // Stream controllers
  final StreamController<app.ConnectionState> _connectionStateController =
      StreamController<app.ConnectionState>.broadcast();
  final StreamController<String> _nodeIdController =
      StreamController<String>.broadcast();
  final StreamController<MeshPacket> _incomingPacketsController =
      StreamController<MeshPacket>.broadcast();

  // BLE state
  BluetoothDevice? _device;
  BluetoothCharacteristic? _toRadioChar;
  BluetoothCharacteristic? _fromRadioChar;
  BluetoothCharacteristic? _fromNumChar;
  StreamSubscription<List<int>>? _fromNumSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  // Connection state
  app.ConnectionState _currentState = app.ConnectionState.disconnected;
  int _myNodeNum = 0;
  int _negotiatedMtu = 23; // Default BLE MTU
  Config_PositionConfig? _storedPositionConfig;
  int _configId = 0;

  // Heartbeat and liveness
  Timer? _heartbeatTimer;
  Timer? _livenessTimer;

  // Reconnection
  String? _lastDeviceId;
  int _reconnectAttempts = 0;
  Duration _currentBackoff = _initialBackoff;
  Timer? _reconnectTimer;
  bool _intentionalDisconnect = false;

  @override
  Stream<app.ConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<String> get nodeId => _nodeIdController.stream;

  @override
  Stream<MeshPacket> get incomingPackets => _incomingPacketsController.stream;

  /// The current connection state.
  app.ConnectionState get currentState => _currentState;

  /// The local node number (0 if not yet known).
  int get myNodeNum => _myNodeNum;

  /// The stored position config from the last handshake.
  Config_PositionConfig? get storedPositionConfig => _storedPositionConfig;

  @override
  Future<List<MeshtasticScanResult>> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _updateState(app.ConnectionState.scanning);
    final results = <MeshtasticScanResult>[];

    try {
      // Start scanning
      await FlutterBluePlus.startScan(
        withServices: [Guid(serviceUuid)],
        timeout: timeout,
      );

      // Collect results
      await for (final scanResults in FlutterBluePlus.scanResults) {
        for (final result in scanResults) {
          final name = result.device.platformName;
          if (name.isNotEmpty && _namePattern.hasMatch(name)) {
            // Avoid duplicates
            if (!results.any((r) => r.device.remoteId == result.device.remoteId)) {
              results.add(MeshtasticScanResult(
                device: result.device,
                name: name,
                rssi: result.rssi,
              ));
            }
          }
        }
        // Break after scan completes (timeout reached)
        break;
      }
    } finally {
      await FlutterBluePlus.stopScan();
      if (results.isEmpty) {
        _updateState(app.ConnectionState.disconnected);
      } else {
        _updateState(app.ConnectionState.disconnected);
      }
    }

    return results;
  }

  @override
  Future<void> connect(String deviceId) async {
    _intentionalDisconnect = false;
    _lastDeviceId = deviceId;
    _reconnectAttempts = 0;
    _currentBackoff = _initialBackoff;

    await _performConnect(deviceId);
  }

  Future<void> _performConnect(String deviceId) async {
    _updateState(app.ConnectionState.connecting);

    try {
      _device = BluetoothDevice.fromId(deviceId);

      // Listen for disconnection events
      _connectionSubscription?.cancel();
      _connectionSubscription = _device!.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleUnexpectedDisconnect();
        }
      });

      // Connect with timeout
      await _device!.connect(timeout: const Duration(seconds: 15));

      // Negotiate MTU
      _negotiatedMtu = await _device!.requestMtu(512);

      _updateState(app.ConnectionState.connected);

      // Discover services and characteristics
      await _discoverCharacteristics();

      // Subscribe to FROMNUM notifications
      await _subscribeFromNum();

      // Perform handshake
      await _performHandshake();

      // Persist bonded device
      await _persistBondedDevice(deviceId);

      // Start heartbeat
      _startHeartbeat();

      _updateState(app.ConnectionState.ready);
    } catch (e) {
      _updateState(app.ConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  @override
  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _cancelTimers();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_device != null) {
      try {
        // Send disconnect frame
        await _sendToRadio(ToRadio(disconnect: true));
      } catch (_) {
        // Best effort
      }

      try {
        await _fromNumSubscription?.cancel();
        _fromNumSubscription = null;
        await _connectionSubscription?.cancel();
        _connectionSubscription = null;
        await _device!.disconnect();
      } catch (_) {
        // Best effort
      }
    }

    _device = null;
    _toRadioChar = null;
    _fromRadioChar = null;
    _fromNumChar = null;
    _myNodeNum = 0;
    _storedPositionConfig = null;
    _updateState(app.ConnectionState.disconnected);
  }

  /// Maximum payload size for text messages (UTF-8 encoded bytes).
  static const int maxTextPayloadBytes = 237;

  /// Validates whether a text message payload is within the allowed size limit.
  ///
  /// Returns `true` if the UTF-8 encoded byte length of [text] is ≤ 237 bytes.
  static bool isTextPayloadValid(String text) {
    final utf8Bytes = text.codeUnits.length <= text.length
        ? _utf8Encode(text)
        : _utf8Encode(text);
    return utf8Bytes.length <= maxTextPayloadBytes;
  }

  /// Determines whether an incoming packet should be accepted based on its
  /// destination address.
  ///
  /// A packet is accepted if the destination is the broadcast address
  /// (0xFFFFFFFF) or matches the [localNodeNum].
  static bool shouldAcceptPacket(int destination, int localNodeNum) {
    // 0xFFFFFFFF as a signed 32-bit int is -1
    return destination == 0xFFFFFFFF ||
        destination == -1 ||
        destination == localNodeNum;
  }

  static List<int> _utf8Encode(String text) {
    // Use dart:convert utf8 encoder
    return const Utf8Encoder().convert(text);
  }

  @override
  Future<void> sendTextMessage(
    String text,
    int destination,
    int channel,
  ) async {
    if (!isTextPayloadValid(text)) {
      throw ArgumentError(
        'Text message exceeds maximum payload size of $maxTextPayloadBytes bytes',
      );
    }

    final payload = Uint8List.fromList(const Utf8Encoder().convert(text));
    final packet = _buildMeshPacket(
      destination: destination,
      channel: channel,
      portNum: PortNum.TEXT_MESSAGE_APP,
      payload: payload,
    );

    final toRadio = ToRadio(packet: packet);
    await _sendToRadio(toRadio);
  }

  @override
  Future<void> sendAdminMessage(AdminMessage message) async {
    final packet = _buildMeshPacket(
      destination: _myNodeNum,
      channel: 0,
      portNum: PortNum.ADMIN_APP,
      payload: Uint8List.fromList(message.writeToBuffer()),
    );

    final toRadio = ToRadio(packet: packet);
    await _sendToRadio(toRadio);
  }

  @override
  Future<void> setPositionConfig(Config_PositionConfig config) async {
    _storedPositionConfig = config;
    final adminMsg = AdminMessage(
      setConfig: Config(position: config),
    );
    await sendAdminMessage(adminMsg);
  }

  @override
  Future<void> rebootRadio({int delaySeconds = 5}) async {
    final adminMsg = AdminMessage(rebootSeconds: delaySeconds);
    await sendAdminMessage(adminMsg);
  }

  /// Returns the persisted bonded device ID, if any.
  Future<String?> getBondedDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bondedDeviceKey);
  }

  // --- Private Implementation ---

  Future<void> _discoverCharacteristics() async {
    final services = await _device!.discoverServices();

    BluetoothService? meshtasticService;
    for (final service in services) {
      if (service.uuid == Guid(serviceUuid)) {
        meshtasticService = service;
        break;
      }
    }

    if (meshtasticService == null) {
      throw StateError('Meshtastic service not found on device');
    }

    for (final char in meshtasticService.characteristics) {
      final uuid = char.uuid.toString().toLowerCase();
      if (uuid == toRadioUuid) {
        _toRadioChar = char;
      } else if (uuid == fromRadioUuid) {
        _fromRadioChar = char;
      } else if (uuid == fromNumUuid) {
        _fromNumChar = char;
      }
    }

    if (_toRadioChar == null || _fromRadioChar == null || _fromNumChar == null) {
      throw StateError(
        'Required Meshtastic characteristics not found on device',
      );
    }
  }

  Future<void> _subscribeFromNum() async {
    await _fromNumChar!.setNotifyValue(true);
    _fromNumSubscription = _fromNumChar!.onValueReceived.listen((_) {
      // FROMNUM notification received — poll FROMRADIO until empty
      _pollFromRadio();
    });
  }

  Future<void> _pollFromRadio() async {
    while (true) {
      try {
        final data = await _fromRadioChar!.read();
        if (data.isEmpty) break;

        _resetLivenessTimer();

        final fromRadio = FromRadio.fromBuffer(data);
        _handleFromRadio(fromRadio);
      } catch (_) {
        break;
      }
    }
  }

  void _handleFromRadio(FromRadio fromRadio) {
    switch (fromRadio.whichPayloadVariant()) {
      case FromRadio_PayloadVariant.myInfo:
        _myNodeNum = fromRadio.myInfo.myNodeNum;
        final hexId =
            '!${_myNodeNum.toRadixString(16).padLeft(8, '0')}';
        _nodeIdController.add(hexId);

      case FromRadio_PayloadVariant.config:
        final config = fromRadio.config;
        if (config.whichPayloadVariant() == Config_PayloadVariant.position) {
          _storedPositionConfig = config.position;
        }

      case FromRadio_PayloadVariant.configCompleteId:
        // Handshake complete — config_complete_id received
        // Value should match our want_config_id
        break;

      case FromRadio_PayloadVariant.packet:
        _routeIncomingPacket(fromRadio.packet);

      case FromRadio_PayloadVariant.nodeInfo:
      case FromRadio_PayloadVariant.moduleConfig:
      case FromRadio_PayloadVariant.channel:
      case FromRadio_PayloadVariant.notSet:
        break;
    }
  }

  void _routeIncomingPacket(MeshPacket packet) {
    if (packet.whichPayloadVariant() != MeshPacket_PayloadVariant.decoded) {
      return;
    }

    // Filter by destination: accept broadcast (0xFFFFFFFF) or local node
    if (!shouldAcceptPacket(packet.to, _myNodeNum)) {
      return;
    }

    final portNum = packet.decoded.portnum;

    // Route by port number
    switch (portNum) {
      case PortNum.TEXT_MESSAGE_APP:
      case PortNum.ADMIN_APP:
      case PortNum.POSITION_APP:
      case PortNum.TELEMETRY_APP:
        _incomingPacketsController.add(packet);
      default:
        // Unhandled port numbers are silently ignored
        break;
    }
  }

  Future<void> _performHandshake() async {
    _updateState(app.ConnectionState.handshaking);

    // Generate random config ID for handshake
    _configId = _random.nextInt(0xFFFFFFFF) + 1;

    // Send want_config_id
    final toRadio = ToRadio(wantConfigId: _configId);
    await _sendToRadio(toRadio);

    // Poll for handshake responses with timeout
    final handshakeTimeout = DateTime.now().add(const Duration(seconds: 10));

    while (DateTime.now().isBefore(handshakeTimeout)) {
      try {
        final data = await _fromRadioChar!.read();
        if (data.isEmpty) {
          // Brief pause before polling again
          await Future<void>.delayed(const Duration(milliseconds: 100));
          continue;
        }

        final fromRadio = FromRadio.fromBuffer(data);
        _handleFromRadio(fromRadio);

        // Check if handshake is complete
        if (fromRadio.whichPayloadVariant() ==
            FromRadio_PayloadVariant.configCompleteId) {
          return; // Handshake complete
        }
      } catch (_) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }

    // Handshake timeout — treat as failure
    throw TimeoutException('Handshake did not complete within 10 seconds');
  }

  Future<void> _sendToRadio(ToRadio toRadio) async {
    if (_toRadioChar == null) {
      throw StateError('Not connected to Meshtastic device');
    }

    final payload = Uint8List.fromList(toRadio.writeToBuffer());
    final framed = _framer.frame(payload);
    final chunks = _framer.splitForMtu(framed, _negotiatedMtu);

    for (final chunk in chunks) {
      await _toRadioChar!.write(chunk, withoutResponse: true);
    }
  }

  MeshPacket _buildMeshPacket({
    required int destination,
    required int channel,
    required PortNum portNum,
    required Uint8List payload,
  }) {
    // Generate non-zero random packet ID
    final packetId = _random.nextInt(0xFFFFFFFF) + 1;

    return MeshPacket(
      from: _myNodeNum,
      to: destination,
      channel: channel,
      id: packetId,
      decoded: Data(
        portnum: portNum,
        payload: payload,
      ),
    );
  }

  // --- Heartbeat and Liveness ---

  void _startHeartbeat() {
    _cancelTimers();

    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      _sendHeartbeat();
    });

    _resetLivenessTimer();
  }

  void _sendHeartbeat() {
    // Send an empty ToRadio as heartbeat (want_config_id with 0 is a no-op)
    // The Meshtastic protocol uses reading FROMRADIO as the heartbeat mechanism
    _pollFromRadio();
  }

  void _resetLivenessTimer() {
    _livenessTimer?.cancel();
    _livenessTimer = Timer(_livenessTimeout, () {
      // No data received within liveness timeout — connection is dead
      _handleUnexpectedDisconnect();
    });
  }

  void _cancelTimers() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _livenessTimer?.cancel();
    _livenessTimer = null;
  }

  // --- Reconnection ---

  void _handleUnexpectedDisconnect() {
    if (_intentionalDisconnect) return;
    if (_currentState == app.ConnectionState.reconnecting) return;

    _cancelTimers();
    _fromNumSubscription?.cancel();
    _fromNumSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _toRadioChar = null;
    _fromRadioChar = null;
    _fromNumChar = null;

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    if (_lastDeviceId == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _updateState(app.ConnectionState.disconnected);
      return;
    }

    _updateState(app.ConnectionState.reconnecting);
    _reconnectAttempts++;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_currentBackoff, () {
      _performConnect(_lastDeviceId!);
    });

    // Exponential backoff: double the delay, cap at max
    _currentBackoff = Duration(
      milliseconds: min(
        _currentBackoff.inMilliseconds * 2,
        _maxBackoff.inMilliseconds,
      ),
    );
  }

  // --- State Management ---

  void _updateState(app.ConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _connectionStateController.add(newState);
    }
  }

  // --- Persistence ---

  Future<void> _persistBondedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bondedDeviceKey, deviceId);
  }

  /// Disposes all resources. Call when the service is no longer needed.
  void dispose() {
    _intentionalDisconnect = true;
    _cancelTimers();
    _reconnectTimer?.cancel();
    _fromNumSubscription?.cancel();
    _connectionSubscription?.cancel();
    _connectionStateController.close();
    _nodeIdController.close();
    _incomingPacketsController.close();
  }
}
