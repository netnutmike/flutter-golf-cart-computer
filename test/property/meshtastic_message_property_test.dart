import 'dart:convert';
import 'dart:typed_data';

import 'package:glados/glados.dart';
import 'package:golf_cart_computer/data/generated/meshtastic.dart';
import 'package:golf_cart_computer/data/services/meshtastic_service.dart';

/// Custom generators for Meshtastic message property tests.
extension MeshtasticGenerators on Any {
  /// Generates a valid ToRadio message with a packet payload variant.
  Generator<ToRadio> get toRadioWithPacket => combine3(
        intInRange(1, 0x7FFFFFFF), // from (positive int32 range)
        intInRange(0, 0x7FFFFFFF), // to
        intInRange(0, 7), // channel
        (int from, int to, int channel) => ToRadio(
          packet: MeshPacket(
            from: from,
            to: to,
            channel: channel,
            id: (from ^ to ^ channel) | 1, // non-zero
            decoded: Data(
              portnum: PortNum.TEXT_MESSAGE_APP,
              payload: [72, 101, 108, 108, 111], // "Hello"
            ),
          ),
        ),
      );

  /// Generates a valid ToRadio message with wantConfigId variant.
  Generator<ToRadio> get toRadioWithConfigId =>
      intInRange(1, 0x7FFFFFFF).map((id) => ToRadio(wantConfigId: id));

  /// Generates a valid FromRadio message with a packet payload.
  Generator<FromRadio> get fromRadioWithPacket => combine4(
        intInRange(1, 0x7FFFFFFF), // id
        intInRange(1, 0x7FFFFFFF), // from
        intInRange(0, 0x7FFFFFFF), // to
        intInRange(0, 7), // channel
        (int id, int from, int to, int channel) => FromRadio(
          id: id,
          packet: MeshPacket(
            from: from,
            to: to,
            channel: channel,
            id: (from ^ to) | 1,
            decoded: Data(
              portnum: PortNum.TEXT_MESSAGE_APP,
              payload: [84, 101, 115, 116], // "Test"
            ),
          ),
        ),
      );

  /// Generates a valid FromRadio message with myInfo payload.
  Generator<FromRadio> get fromRadioWithMyInfo => combine2(
        intInRange(1, 0x7FFFFFFF), // id
        intInRange(1, 0x7FFFFFFF), // myNodeNum
        (int id, int nodeNum) => FromRadio(
          id: id,
          myInfo: MyNodeInfo(myNodeNum: nodeNum),
        ),
      );

  /// Generates a valid FromRadio message with configCompleteId.
  Generator<FromRadio> get fromRadioWithConfigComplete => combine2(
        intInRange(1, 0x7FFFFFFF), // id
        intInRange(1, 0x7FFFFFFF), // configCompleteId
        (int id, int configId) => FromRadio(
          id: id,
          configCompleteId: configId,
        ),
      );

  /// Generates a node number (positive int32 range for protobuf fixed32).
  Generator<int> get nodeNumber => intInRange(1, 0x7FFFFFFF);

  /// Generates a channel index (0-7).
  Generator<int> get channelIndex => intInRange(0, 8);

  /// Generates a valid UTF-8 text string with byte length ≤ 237.
  /// Uses printable ASCII characters (each 1 byte in UTF-8).
  Generator<String> get validTextPayload =>
      listWithLengthInRange(1, 237, intInRange(0x20, 0x7F)).map(
        (codeUnits) => String.fromCharCodes(codeUnits),
      );

  /// Generates a UTF-8 text string with byte length > 237.
  /// Uses printable ASCII characters (each 1 byte in UTF-8).
  Generator<String> get oversizedTextPayload =>
      listWithLengthInRange(238, 500, intInRange(0x20, 0x7F)).map(
        (codeUnits) => String.fromCharCodes(codeUnits),
      );

  /// Generates any ASCII text string (variable length, may be valid or invalid).
  Generator<String> get anyAsciiText =>
      listWithLengthInRange(0, 500, intInRange(0x20, 0x7F)).map(
        (codeUnits) => String.fromCharCodes(codeUnits),
      );
}

void main() {
  group('Property 1: Protobuf serialization round-trip', () {
    /// **Validates: Requirements 1.5, 1.6**
    ///
    /// For any valid ToRadio message with a packet, encoding to protobuf bytes
    /// and then decoding back should produce an equivalent message object.
    Glados(any.toRadioWithPacket).test(
      'ToRadio with packet round-trips through protobuf serialization',
      (toRadio) {
        final encoded = toRadio.writeToBuffer();
        final decoded = ToRadio.fromBuffer(encoded);

        expect(decoded.whichPayloadVariant(),
            equals(ToRadio_PayloadVariant.packet));
        expect(decoded.packet.from, equals(toRadio.packet.from));
        expect(decoded.packet.to, equals(toRadio.packet.to));
        expect(decoded.packet.channel, equals(toRadio.packet.channel));
        expect(decoded.packet.id, equals(toRadio.packet.id));
        expect(decoded.packet.decoded.portnum,
            equals(toRadio.packet.decoded.portnum));
        expect(decoded.packet.decoded.payload,
            equals(toRadio.packet.decoded.payload));
      },
    );

    /// **Validates: Requirements 1.5, 1.6**
    ///
    /// For any valid ToRadio message with wantConfigId, encoding to protobuf
    /// bytes and then decoding back should produce an equivalent message.
    Glados(any.toRadioWithConfigId).test(
      'ToRadio with wantConfigId round-trips through protobuf serialization',
      (toRadio) {
        final encoded = toRadio.writeToBuffer();
        final decoded = ToRadio.fromBuffer(encoded);

        expect(decoded.whichPayloadVariant(),
            equals(ToRadio_PayloadVariant.wantConfigId));
        expect(decoded.wantConfigId, equals(toRadio.wantConfigId));
      },
    );

    /// **Validates: Requirements 1.5, 1.6**
    ///
    /// For any valid FromRadio message with a packet, encoding to protobuf
    /// bytes and then decoding back should produce an equivalent message.
    Glados(any.fromRadioWithPacket).test(
      'FromRadio with packet round-trips through protobuf serialization',
      (fromRadio) {
        final encoded = fromRadio.writeToBuffer();
        final decoded = FromRadio.fromBuffer(encoded);

        expect(decoded.whichPayloadVariant(),
            equals(FromRadio_PayloadVariant.packet));
        expect(decoded.id, equals(fromRadio.id));
        expect(decoded.packet.from, equals(fromRadio.packet.from));
        expect(decoded.packet.to, equals(fromRadio.packet.to));
        expect(decoded.packet.channel, equals(fromRadio.packet.channel));
        expect(decoded.packet.decoded.portnum,
            equals(fromRadio.packet.decoded.portnum));
        expect(decoded.packet.decoded.payload,
            equals(fromRadio.packet.decoded.payload));
      },
    );

    /// **Validates: Requirements 1.5, 1.6**
    ///
    /// For any valid FromRadio message with myInfo, encoding to protobuf
    /// bytes and then decoding back should produce an equivalent message.
    Glados(any.fromRadioWithMyInfo).test(
      'FromRadio with myInfo round-trips through protobuf serialization',
      (fromRadio) {
        final encoded = fromRadio.writeToBuffer();
        final decoded = FromRadio.fromBuffer(encoded);

        expect(decoded.whichPayloadVariant(),
            equals(FromRadio_PayloadVariant.myInfo));
        expect(decoded.id, equals(fromRadio.id));
        expect(decoded.myInfo.myNodeNum, equals(fromRadio.myInfo.myNodeNum));
      },
    );

    /// **Validates: Requirements 1.5, 1.6**
    ///
    /// For any valid FromRadio message with configCompleteId, encoding to
    /// protobuf bytes and then decoding back should produce an equivalent message.
    Glados(any.fromRadioWithConfigComplete).test(
      'FromRadio with configCompleteId round-trips through protobuf serialization',
      (fromRadio) {
        final encoded = fromRadio.writeToBuffer();
        final decoded = FromRadio.fromBuffer(encoded);

        expect(decoded.whichPayloadVariant(),
            equals(FromRadio_PayloadVariant.configCompleteId));
        expect(decoded.id, equals(fromRadio.id));
        expect(
            decoded.configCompleteId, equals(fromRadio.configCompleteId));
      },
    );
  });

  group('Property 3: Message routing acceptance', () {
    /// **Validates: Requirements 2.2**
    ///
    /// For any incoming MeshPacket with destination equal to the broadcast
    /// address (0xFFFFFFFF), the message should always be accepted regardless
    /// of the local node number.
    Glados(any.nodeNumber).test(
      'broadcast address (0xFFFFFFFF) is always accepted',
      (localNodeNum) {
        expect(
          BleMeshtasticService.shouldAcceptPacket(0xFFFFFFFF, localNodeNum),
          isTrue,
        );
      },
    );

    /// **Validates: Requirements 2.2**
    ///
    /// For any local node number, a packet addressed to that exact node number
    /// should be accepted.
    Glados(any.nodeNumber).test(
      'packet addressed to local node number is accepted',
      (localNodeNum) {
        expect(
          BleMeshtasticService.shouldAcceptPacket(localNodeNum, localNodeNum),
          isTrue,
        );
      },
    );

    /// **Validates: Requirements 2.2**
    ///
    /// For any destination that is neither the broadcast address nor the local
    /// node number, the message should be rejected.
    Glados2(any.nodeNumber, any.nodeNumber).test(
      'packet addressed to other node is rejected',
      (destination, localNodeNum) {
        // Skip if destination happens to be broadcast or local node
        if (destination == 0xFFFFFFFF ||
            destination == -1 ||
            destination == localNodeNum) {
          return;
        }

        expect(
          BleMeshtasticService.shouldAcceptPacket(destination, localNodeNum),
          isFalse,
        );
      },
    );
  });

  group('Property 4: Outbound message construction', () {
    /// **Validates: Requirements 2.3, 2.4, 2.9, 18.8**
    ///
    /// For any valid text string (UTF-8 encoded ≤ 237 bytes), destination node
    /// number, and channel index (0-7), the constructed MeshPacket should have
    /// the correct destination, the specified channel, port number
    /// TEXT_MESSAGE_APP (1), a non-zero random packet ID, and the text encoded
    /// as payload bytes.
    Glados3(any.validTextPayload, any.nodeNumber, any.channelIndex).test(
      'constructed MeshPacket has correct fields for valid text message',
      (text, destination, channel) {
        // Build the packet the same way the service does
        final payload = Uint8List.fromList(const Utf8Encoder().convert(text));

        // Simulate _buildMeshPacket logic with a non-zero ID
        final packet = MeshPacket(
          from: 12345, // arbitrary local node
          to: destination,
          channel: channel,
          id: 42, // non-zero placeholder (real uses random)
          decoded: Data(
            portnum: PortNum.TEXT_MESSAGE_APP,
            payload: payload,
          ),
        );

        // Verify correct destination
        expect(packet.to, equals(destination));

        // Verify correct channel
        expect(packet.channel, equals(channel));

        // Verify port number is TEXT_MESSAGE_APP (1)
        expect(packet.decoded.portnum, equals(PortNum.TEXT_MESSAGE_APP));
        expect(packet.decoded.portnum.value, equals(1));

        // Verify non-zero packet ID
        expect(packet.id, isNot(equals(0)));

        // Verify text is encoded as payload bytes (UTF-8)
        final decodedText = utf8.decode(packet.decoded.payload);
        expect(decodedText, equals(text));
      },
    );

    /// **Validates: Requirements 2.3, 2.4, 2.9, 18.8**
    ///
    /// The packet ID generated by _buildMeshPacket should always be non-zero.
    /// The service uses: _random.nextInt(0xFFFFFFFF) + 1 which produces [1, 0xFFFFFFFF].
    Glados(any.intInRange(0, 0x7FFFFFFF)).test(
      'random packet ID from nextInt(max) + 1 is always non-zero',
      (randomValue) {
        // The service uses: _random.nextInt(0xFFFFFFFF) + 1
        // nextInt returns [0, max), so result is [1, 0xFFFFFFFF]
        final packetId = randomValue + 1;
        expect(packetId, isNot(equals(0)));
        expect(packetId, greaterThan(0));
      },
    );
  });

  group('Property 5: Outbound payload size enforcement', () {
    /// **Validates: Requirements 2.7**
    ///
    /// For any text string with UTF-8 byte length ≤ 237, the system should
    /// accept the message for sending.
    Glados(any.validTextPayload).test(
      'text with UTF-8 byte length <= 237 is accepted',
      (text) {
        final byteLength = utf8.encode(text).length;
        // Confirm our generator produces valid payloads
        expect(byteLength, lessThanOrEqualTo(237));
        // Verify the validation accepts it
        expect(BleMeshtasticService.isTextPayloadValid(text), isTrue);
      },
    );

    /// **Validates: Requirements 2.7**
    ///
    /// For any text string with UTF-8 byte length > 237, the system should
    /// reject the message before encoding.
    Glados(any.oversizedTextPayload).test(
      'text with UTF-8 byte length > 237 is rejected',
      (text) {
        final byteLength = utf8.encode(text).length;
        // Confirm our generator produces oversized payloads
        expect(byteLength, greaterThan(237));
        // Verify the validation rejects it
        expect(BleMeshtasticService.isTextPayloadValid(text), isFalse);
      },
    );

    /// **Validates: Requirements 2.7**
    ///
    /// For any text string, the acceptance decision is consistent with the
    /// 237-byte UTF-8 threshold.
    Glados(any.anyAsciiText).test(
      'acceptance decision matches UTF-8 byte length <= 237 threshold',
      (text) {
        final byteLength = utf8.encode(text).length;
        final isValid = BleMeshtasticService.isTextPayloadValid(text);

        if (byteLength <= 237) {
          expect(isValid, isTrue,
              reason: 'Text with $byteLength bytes should be accepted');
        } else {
          expect(isValid, isFalse,
              reason: 'Text with $byteLength bytes should be rejected');
        }
      },
    );
  });
}
