/// Meshtastic messaging notifier for the Golf Cart Computer.
///
/// Manages sending and receiving text messages via the Meshtastic mesh network.
/// Supports broadcast messages on channels 0-7, direct messages to specific
/// node numbers, preformatted message selection, custom text composition,
/// payload size enforcement, message history with FIFO eviction, and
/// notification tones on receipt.
///
/// Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.9, 2.10, 2.11, 2.12
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/generated/meshtastic.dart';
import '../data/services/meshtastic_service.dart';
import '../domain/audio_service.dart';
import 'connection_notifier.dart';

/// Maximum UTF-8 byte length for a text message payload.
const int kMaxTextPayloadBytes = 237;

/// Maximum number of messages retained in history (FIFO eviction).
const int kMaxMessageHistory = 100;

/// Maximum number of preformatted messages.
const int kMaxPreformattedMessages = 20;

/// Broadcast address for Meshtastic messages.
const int kMessagingBroadcastAddress = 0xFFFFFFFF;

/// Represents a single message in the history.
class ChatMessage {
  /// Sender node ID in hex format (e.g., "!a1b2c3d4").
  final String senderNodeId;

  /// Channel number the message was received/sent on.
  final int channel;

  /// Timestamp of the message.
  final DateTime timestamp;

  /// The text content of the message.
  final String text;

  /// Whether this message was sent by the local node.
  final bool isOutgoing;

  /// Destination node number (for outgoing messages).
  final int? destination;

  const ChatMessage({
    required this.senderNodeId,
    required this.channel,
    required this.timestamp,
    required this.text,
    required this.isOutgoing,
    this.destination,
  });

  /// Formats the timestamp in 12-hour format with AM/PM.
  String get formattedTimestamp {
    final hour = timestamp.hour;
    final minute = timestamp.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }
}

/// Result of a send attempt.
enum SendResult {
  /// Message sent successfully.
  success,

  /// Not connected to Meshtastic radio.
  notConnected,

  /// Message payload exceeds 237-byte UTF-8 limit.
  payloadTooLarge,

  /// Channel number is out of valid range (0-7).
  invalidChannel,

  /// An error occurred during sending.
  sendError,
}

/// State for the messaging notifier.
class MessagingState {
  /// Message history (newest last), up to [kMaxMessageHistory] entries.
  final List<ChatMessage> messages;

  /// Preformatted messages available for quick selection.
  final List<String> preformattedMessages;

  /// Current text being composed.
  final String composedText;

  /// Current UTF-8 byte size of the composed text.
  final int composedByteSize;

  /// Whether the Meshtastic connection is active.
  final bool isConnected;

  /// The local node ID in hex format (e.g., "!a1b2c3d4").
  final String localNodeId;

  const MessagingState({
    this.messages = const [],
    this.preformattedMessages = const [],
    this.composedText = '',
    this.composedByteSize = 0,
    this.isConnected = false,
    this.localNodeId = '',
  });

  /// Creates a copy with optional field overrides.
  MessagingState copyWith({
    List<ChatMessage>? messages,
    List<String>? preformattedMessages,
    String? composedText,
    int? composedByteSize,
    bool? isConnected,
    String? localNodeId,
  }) {
    return MessagingState(
      messages: messages ?? this.messages,
      preformattedMessages: preformattedMessages ?? this.preformattedMessages,
      composedText: composedText ?? this.composedText,
      composedByteSize: composedByteSize ?? this.composedByteSize,
      isConnected: isConnected ?? this.isConnected,
      localNodeId: localNodeId ?? this.localNodeId,
    );
  }
}

/// Manages Meshtastic text messaging: sending, receiving, history, and
/// notification tones.
///
/// Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.9, 2.10, 2.11, 2.12
class MessagingNotifier extends StateNotifier<MessagingState> {
  final MeshtasticService _meshtasticService;
  final AudioService _audioService;

  StreamSubscription<MeshPacket>? _packetSubscription;
  StreamSubscription<String>? _nodeIdSubscription;

  /// The current speaker volume level (0-20). Volume 0 suppresses tones.
  int _speakerVolume;

  /// Connection status tracked from the ConnectionNotifier.
  ConnectionStatus _meshtasticStatus = ConnectionStatus.disconnected;

  MessagingNotifier({
    required MeshtasticService meshtasticService,
    required AudioService audioService,
    int speakerVolume = 10,
    List<String> preformattedMessages = const [],
  })  : _meshtasticService = meshtasticService,
        _audioService = audioService,
        _speakerVolume = speakerVolume,
        super(MessagingState(
          preformattedMessages: preformattedMessages.length > kMaxPreformattedMessages
              ? preformattedMessages.sublist(0, kMaxPreformattedMessages)
              : preformattedMessages,
        )) {
    _subscribeToPackets();
    _subscribeToNodeId();
  }

  /// Updates the speaker volume level.
  void updateVolume(int volume) {
    _speakerVolume = volume.clamp(0, 20);
  }

  /// Updates the Meshtastic connection status.
  void updateConnectionStatus(ConnectionStatus status) {
    _meshtasticStatus = status;
    state = state.copyWith(isConnected: status == ConnectionStatus.connected);
  }

  /// Updates the preformatted messages list (up to 20 entries).
  void updatePreformattedMessages(List<String> messages) {
    final limited = messages.length > kMaxPreformattedMessages
        ? messages.sublist(0, kMaxPreformattedMessages)
        : messages;
    state = state.copyWith(preformattedMessages: limited);
  }

  /// Updates the composed text and recalculates byte size.
  void updateComposedText(String text) {
    final byteSize = utf8.encode(text).length;
    state = state.copyWith(
      composedText: text,
      composedByteSize: byteSize,
    );
  }

  /// Returns the UTF-8 byte size of the given text.
  static int getUtf8ByteSize(String text) {
    return utf8.encode(text).length;
  }

  /// Returns whether the given text exceeds the payload limit.
  static bool exceedsPayloadLimit(String text) {
    return utf8.encode(text).length > kMaxTextPayloadBytes;
  }

  /// Sends a text message to broadcast on the specified channel.
  ///
  /// Requirement 2.3: Support sending text messages to broadcast on channels 0-7.
  /// Requirement 2.7: Enforce 237-byte UTF-8 payload limit.
  /// Requirement 2.9: Encode using TEXT_MESSAGE_APP port number.
  /// Requirement 2.12: Reject send when not connected.
  Future<SendResult> sendBroadcast(String text, int channel) async {
    return sendMessage(text, kMessagingBroadcastAddress, channel);
  }

  /// Sends a direct text message to a specific node number.
  ///
  /// Requirement 2.4: Support sending direct messages to specific node numbers.
  /// Requirement 2.7: Enforce 237-byte UTF-8 payload limit.
  /// Requirement 2.9: Encode using TEXT_MESSAGE_APP port number.
  /// Requirement 2.12: Reject send when not connected.
  Future<SendResult> sendDirect(String text, int destination, int channel) async {
    return sendMessage(text, destination, channel);
  }

  /// Sends a preformatted message by index.
  ///
  /// Requirement 2.5: Support preformatted message selection.
  Future<SendResult> sendPreformatted(int index, int destination, int channel) async {
    if (index < 0 || index >= state.preformattedMessages.length) {
      return SendResult.sendError;
    }
    final text = state.preformattedMessages[index];
    return sendMessage(text, destination, channel);
  }

  /// Core send method that validates and sends a text message.
  Future<SendResult> sendMessage(String text, int destination, int channel) async {
    // Requirement 2.12: Reject when not connected.
    if (_meshtasticStatus != ConnectionStatus.connected) {
      return SendResult.notConnected;
    }

    // Validate channel range (0-7).
    if (channel < 0 || channel > 7) {
      return SendResult.invalidChannel;
    }

    // Requirement 2.7: Enforce 237-byte UTF-8 payload limit.
    final utf8Bytes = utf8.encode(text);
    if (utf8Bytes.length > kMaxTextPayloadBytes) {
      return SendResult.payloadTooLarge;
    }

    // Empty messages are not useful.
    if (text.isEmpty) {
      return SendResult.sendError;
    }

    try {
      // Requirement 2.9: Send using TEXT_MESSAGE_APP port via MeshtasticService.
      await _meshtasticService.sendTextMessage(text, destination, channel);

      // Add to message history as outgoing.
      _addToHistory(ChatMessage(
        senderNodeId: state.localNodeId,
        channel: channel,
        timestamp: DateTime.now(),
        text: text,
        isOutgoing: true,
        destination: destination,
      ));

      return SendResult.success;
    } catch (_) {
      return SendResult.sendError;
    }
  }

  /// Subscribes to incoming mesh packets for text messages.
  void _subscribeToPackets() {
    _packetSubscription = _meshtasticService.incomingPackets.listen(
      _onPacketReceived,
    );
  }

  /// Subscribes to node ID updates.
  void _subscribeToNodeId() {
    _nodeIdSubscription = _meshtasticService.nodeId.listen((nodeId) {
      state = state.copyWith(localNodeId: nodeId);
    });
  }

  /// Handles an incoming mesh packet.
  ///
  /// Requirement 2.1: Display received messages with sender node ID (hex),
  /// channel, and timestamp in 12-hour format.
  /// Requirement 2.2: Accept messages addressed to broadcast or local node.
  /// Requirement 2.10: Play notification tone if volume > 0.
  void _onPacketReceived(MeshPacket packet) {
    // Only process text messages.
    if (packet.whichPayloadVariant() != MeshPacket_PayloadVariant.decoded) {
      return;
    }
    if (packet.decoded.portnum != PortNum.TEXT_MESSAGE_APP) {
      return;
    }

    // Decode the text payload.
    final payloadBytes = packet.decoded.payload;
    final text = utf8.decode(payloadBytes, allowMalformed: true);

    // Format sender node ID as hex.
    final senderNodeNum = packet.from;
    final senderHex = '!${senderNodeNum.toRadixString(16).padLeft(8, '0')}';

    final message = ChatMessage(
      senderNodeId: senderHex,
      channel: packet.channel,
      timestamp: DateTime.now(),
      text: text,
      isOutgoing: false,
    );

    _addToHistory(message);

    // Requirement 2.10: Play notification tone if volume > 0.
    if (_speakerVolume > 0) {
      _audioService.playMessageNotification();
    }
  }

  /// Adds a message to history with FIFO eviction at [kMaxMessageHistory].
  ///
  /// Requirement 2.11: Retain up to 100 messages, discard oldest when exceeded.
  void _addToHistory(ChatMessage message) {
    final updatedMessages = List<ChatMessage>.from(state.messages);
    updatedMessages.add(message);

    // FIFO eviction: remove oldest when exceeding limit.
    while (updatedMessages.length > kMaxMessageHistory) {
      updatedMessages.removeAt(0);
    }

    state = state.copyWith(messages: updatedMessages);
  }

  @override
  void dispose() {
    _packetSubscription?.cancel();
    _nodeIdSubscription?.cancel();
    super.dispose();
  }
}
