import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/connection_notifier.dart';
import 'package:golf_cart_computer/application/messaging_notifier.dart';
import 'package:golf_cart_computer/data/generated/meshtastic.dart';
import 'package:golf_cart_computer/data/services/meshtastic_service.dart';
import 'package:golf_cart_computer/domain/audio_service.dart';
import 'package:golf_cart_computer/domain/models/connection_state.dart' as app;
import 'package:mocktail/mocktail.dart';

// --- Mocks ---

class MockMeshtasticService extends Mock implements MeshtasticService {}

class MockAudioService extends Mock implements AudioService {}

void main() {
  late MockMeshtasticService mockMeshtasticService;
  late MockAudioService mockAudioService;
  late StreamController<MeshPacket> incomingPacketsController;
  late StreamController<String> nodeIdController;
  late StreamController<app.ConnectionState> connectionStateController;

  setUp(() {
    mockMeshtasticService = MockMeshtasticService();
    mockAudioService = MockAudioService();
    incomingPacketsController = StreamController<MeshPacket>.broadcast();
    nodeIdController = StreamController<String>.broadcast();
    connectionStateController =
        StreamController<app.ConnectionState>.broadcast();

    when(() => mockMeshtasticService.incomingPackets)
        .thenAnswer((_) => incomingPacketsController.stream);
    when(() => mockMeshtasticService.nodeId)
        .thenAnswer((_) => nodeIdController.stream);
    when(() => mockMeshtasticService.connectionState)
        .thenAnswer((_) => connectionStateController.stream);
    when(() => mockAudioService.playMessageNotification())
        .thenAnswer((_) async {});
    when(() => mockMeshtasticService.sendTextMessage(any(), any(), any()))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    incomingPacketsController.close();
    nodeIdController.close();
    connectionStateController.close();
  });

  MessagingNotifier createNotifier({
    int speakerVolume = 10,
    List<String> preformattedMessages = const [],
  }) {
    final notifier = MessagingNotifier(
      meshtasticService: mockMeshtasticService,
      audioService: mockAudioService,
      speakerVolume: speakerVolume,
      preformattedMessages: preformattedMessages,
    );
    return notifier;
  }

  group('MessagingNotifier - Sending', () {
    test('rejects send when not connected (Req 2.12)', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.disconnected);

      final result = await notifier.sendBroadcast('Hello', 0);

      expect(result, equals(SendResult.notConnected));
      verifyNever(
        () => mockMeshtasticService.sendTextMessage(any(), any(), any()),
      );
      notifier.dispose();
    });

    test('sends broadcast message on valid channel (Req 2.3)', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      final result = await notifier.sendBroadcast('Hello mesh!', 3);

      expect(result, equals(SendResult.success));
      verify(
        () => mockMeshtasticService.sendTextMessage(
          'Hello mesh!',
          kMessagingBroadcastAddress,
          3,
        ),
      ).called(1);
      notifier.dispose();
    });

    test('sends direct message to specific node (Req 2.4)', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      final result = await notifier.sendDirect('Hi there', 0x12345678, 0);

      expect(result, equals(SendResult.success));
      verify(
        () => mockMeshtasticService.sendTextMessage(
          'Hi there',
          0x12345678,
          0,
        ),
      ).called(1);
      notifier.dispose();
    });

    test('rejects message exceeding 237-byte UTF-8 limit (Req 2.7)', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      // Create a string that exceeds 237 bytes in UTF-8.
      // Multi-byte characters: each emoji is 4 bytes.
      final longText = '🎉' * 60; // 60 * 4 = 240 bytes > 237
      final result = await notifier.sendBroadcast(longText, 0);

      expect(result, equals(SendResult.payloadTooLarge));
      verifyNever(
        () => mockMeshtasticService.sendTextMessage(any(), any(), any()),
      );
      notifier.dispose();
    });

    test('accepts message at exactly 237 bytes (Req 2.7)', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      // 237 ASCII characters = 237 bytes.
      final exactText = 'a' * 237;
      final result = await notifier.sendBroadcast(exactText, 0);

      expect(result, equals(SendResult.success));
      notifier.dispose();
    });

    test('rejects invalid channel numbers', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      expect(
        await notifier.sendBroadcast('test', -1),
        equals(SendResult.invalidChannel),
      );
      expect(
        await notifier.sendBroadcast('test', 8),
        equals(SendResult.invalidChannel),
      );
      notifier.dispose();
    });

    test('accepts all valid channels 0-7 (Req 2.3)', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      for (int ch = 0; ch <= 7; ch++) {
        final result = await notifier.sendBroadcast('test', ch);
        expect(result, equals(SendResult.success));
      }
      notifier.dispose();
    });

    test('sends preformatted message by index (Req 2.5)', () async {
      final preformatted = ['Hello!', 'On my way', 'Be right there'];
      final notifier = createNotifier(preformattedMessages: preformatted);
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      final result = await notifier.sendPreformatted(1, kMessagingBroadcastAddress, 0);

      expect(result, equals(SendResult.success));
      verify(
        () => mockMeshtasticService.sendTextMessage(
          'On my way',
          kMessagingBroadcastAddress,
          0,
        ),
      ).called(1);
      notifier.dispose();
    });

    test('rejects preformatted message with invalid index', () async {
      final preformatted = ['Hello!', 'On my way'];
      final notifier = createNotifier(preformattedMessages: preformatted);
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      final result = await notifier.sendPreformatted(5, kMessagingBroadcastAddress, 0);

      expect(result, equals(SendResult.sendError));
      notifier.dispose();
    });

    test('adds sent message to history', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      await notifier.sendBroadcast('Hello mesh!', 0);

      expect(notifier.state.messages.length, equals(1));
      expect(notifier.state.messages.first.text, equals('Hello mesh!'));
      expect(notifier.state.messages.first.isOutgoing, isTrue);
      expect(notifier.state.messages.first.channel, equals(0));
      notifier.dispose();
    });

    test('rejects empty message', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      final result = await notifier.sendBroadcast('', 0);

      expect(result, equals(SendResult.sendError));
      notifier.dispose();
    });
  });

  group('MessagingNotifier - Receiving', () {
    test('receives text message and adds to history (Req 2.1)', () async {
      final notifier = createNotifier();

      // Simulate receiving a text message packet.
      final packet = MeshPacket(
        from: 0xa1b2c3d4,
        to: 0xFFFFFFFF,
        channel: 2,
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: utf8.encode('Hello from mesh!'),
        ),
      );

      incomingPacketsController.add(packet);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.messages.length, equals(1));
      final msg = notifier.state.messages.first;
      expect(msg.text, equals('Hello from mesh!'));
      expect(msg.senderNodeId, equals('!a1b2c3d4'));
      expect(msg.channel, equals(2));
      expect(msg.isOutgoing, isFalse);
      notifier.dispose();
    });

    test('plays notification tone when volume > 0 (Req 2.10)', () async {
      final notifier = createNotifier(speakerVolume: 5);

      final packet = MeshPacket(
        from: 0x11223344,
        to: 0xFFFFFFFF,
        channel: 0,
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: utf8.encode('Test'),
        ),
      );

      incomingPacketsController.add(packet);
      await Future<void>.delayed(Duration.zero);

      verify(() => mockAudioService.playMessageNotification()).called(1);
      notifier.dispose();
    });

    test('does not play notification tone when volume is 0 (Req 2.10)', () async {
      final notifier = createNotifier(speakerVolume: 0);

      final packet = MeshPacket(
        from: 0x11223344,
        to: 0xFFFFFFFF,
        channel: 0,
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: utf8.encode('Test'),
        ),
      );

      incomingPacketsController.add(packet);
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => mockAudioService.playMessageNotification());
      notifier.dispose();
    });

    test('ignores non-text-message packets', () async {
      final notifier = createNotifier();

      // Send a POSITION_APP packet — should be ignored.
      final packet = MeshPacket(
        from: 0x11223344,
        to: 0xFFFFFFFF,
        channel: 0,
        decoded: Data(
          portnum: PortNum.POSITION_APP,
          payload: [1, 2, 3, 4],
        ),
      );

      incomingPacketsController.add(packet);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.messages, isEmpty);
      notifier.dispose();
    });

    test('formats sender node ID as hex (Req 2.1)', () async {
      final notifier = createNotifier();

      final packet = MeshPacket(
        from: 0x00FF00FF,
        to: 0xFFFFFFFF,
        channel: 0,
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: utf8.encode('test'),
        ),
      );

      incomingPacketsController.add(packet);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.messages.first.senderNodeId, equals('!00ff00ff'));
      notifier.dispose();
    });
  });

  group('MessagingNotifier - Message History', () {
    test('maintains up to 100 messages with FIFO eviction (Req 2.11)', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      // Send 105 messages.
      for (int i = 0; i < 105; i++) {
        await notifier.sendBroadcast('Message $i', 0);
      }

      expect(notifier.state.messages.length, equals(kMaxMessageHistory));
      // Oldest messages (0-4) should be evicted.
      expect(notifier.state.messages.first.text, equals('Message 5'));
      expect(notifier.state.messages.last.text, equals('Message 104'));
      notifier.dispose();
    });

    test('FIFO eviction removes oldest message first', () async {
      final notifier = createNotifier();
      notifier.updateConnectionStatus(ConnectionStatus.connected);

      // Fill to capacity.
      for (int i = 0; i < 100; i++) {
        await notifier.sendBroadcast('Msg $i', 0);
      }
      expect(notifier.state.messages.length, equals(100));
      expect(notifier.state.messages.first.text, equals('Msg 0'));

      // Add one more — oldest should be evicted.
      await notifier.sendBroadcast('Msg 100', 0);
      expect(notifier.state.messages.length, equals(100));
      expect(notifier.state.messages.first.text, equals('Msg 1'));
      expect(notifier.state.messages.last.text, equals('Msg 100'));
      notifier.dispose();
    });
  });

  group('MessagingNotifier - Payload Size', () {
    test('getUtf8ByteSize returns correct byte count for ASCII', () {
      expect(MessagingNotifier.getUtf8ByteSize('hello'), equals(5));
    });

    test('getUtf8ByteSize returns correct byte count for multi-byte chars', () {
      // '€' is 3 bytes in UTF-8.
      expect(MessagingNotifier.getUtf8ByteSize('€'), equals(3));
      // '🎉' is 4 bytes in UTF-8.
      expect(MessagingNotifier.getUtf8ByteSize('🎉'), equals(4));
    });

    test('exceedsPayloadLimit returns false at 237 bytes', () {
      final text = 'a' * 237;
      expect(MessagingNotifier.exceedsPayloadLimit(text), isFalse);
    });

    test('exceedsPayloadLimit returns true at 238 bytes', () {
      final text = 'a' * 238;
      expect(MessagingNotifier.exceedsPayloadLimit(text), isTrue);
    });

    test('updateComposedText tracks byte size', () {
      final notifier = createNotifier();
      notifier.updateComposedText('Hello 🌍');

      // 'Hello ' = 6 bytes, '🌍' = 4 bytes = 10 bytes total.
      expect(notifier.state.composedText, equals('Hello 🌍'));
      expect(notifier.state.composedByteSize, equals(10));
      notifier.dispose();
    });
  });

  group('MessagingNotifier - Preformatted Messages', () {
    test('limits preformatted messages to 20 entries (Req 2.5)', () {
      final messages = List.generate(25, (i) => 'Message $i');
      final notifier = createNotifier(preformattedMessages: messages);

      expect(
        notifier.state.preformattedMessages.length,
        equals(kMaxPreformattedMessages),
      );
      expect(notifier.state.preformattedMessages.last, equals('Message 19'));
      notifier.dispose();
    });

    test('updatePreformattedMessages replaces the list', () {
      final notifier = createNotifier(preformattedMessages: ['Old']);
      notifier.updatePreformattedMessages(['New 1', 'New 2']);

      expect(notifier.state.preformattedMessages, equals(['New 1', 'New 2']));
      notifier.dispose();
    });
  });

  group('MessagingNotifier - Connection Status', () {
    test('updateConnectionStatus updates isConnected state', () {
      final notifier = createNotifier();

      expect(notifier.state.isConnected, isFalse);

      notifier.updateConnectionStatus(ConnectionStatus.connected);
      expect(notifier.state.isConnected, isTrue);

      notifier.updateConnectionStatus(ConnectionStatus.reconnecting);
      expect(notifier.state.isConnected, isFalse);

      notifier.dispose();
    });
  });

  group('MessagingNotifier - Node ID', () {
    test('updates localNodeId from nodeId stream', () async {
      final notifier = createNotifier();

      nodeIdController.add('!deadbeef');
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.localNodeId, equals('!deadbeef'));
      notifier.dispose();
    });
  });

  group('ChatMessage - Timestamp Formatting', () {
    test('formats AM time correctly', () {
      final msg = ChatMessage(
        senderNodeId: '!12345678',
        channel: 0,
        timestamp: DateTime(2024, 6, 15, 9, 5),
        text: 'test',
        isOutgoing: false,
      );

      expect(msg.formattedTimestamp, equals('9:05 AM'));
    });

    test('formats PM time correctly', () {
      final msg = ChatMessage(
        senderNodeId: '!12345678',
        channel: 0,
        timestamp: DateTime(2024, 6, 15, 14, 30),
        text: 'test',
        isOutgoing: false,
      );

      expect(msg.formattedTimestamp, equals('2:30 PM'));
    });

    test('formats 12:00 noon as 12:00 PM', () {
      final msg = ChatMessage(
        senderNodeId: '!12345678',
        channel: 0,
        timestamp: DateTime(2024, 6, 15, 12, 0),
        text: 'test',
        isOutgoing: false,
      );

      expect(msg.formattedTimestamp, equals('12:00 PM'));
    });

    test('formats midnight as 12:00 AM', () {
      final msg = ChatMessage(
        senderNodeId: '!12345678',
        channel: 0,
        timestamp: DateTime(2024, 6, 15, 0, 0),
        text: 'test',
        isOutgoing: false,
      );

      expect(msg.formattedTimestamp, equals('12:00 AM'));
    });
  });
}
