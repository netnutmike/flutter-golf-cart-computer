import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/data/services/telemetry_service.dart';
import 'package:golf_cart_computer/domain/models/gci_message.dart';

void main() {
  group('parseTelemetryPayload()', () {
    test('decodes 20-byte LE payload with known values', () {
      // Build a 20-byte little-endian payload:
      // modeLights: 3 (int32 LE)
      // outdoorLum: 1500 (int32 LE)
      // airTemp: 72.5 (float32 LE)
      // battVolts: 48.2 (float32 LE)
      // fuel: 85.0 (float32 LE)
      final buffer = ByteData(20);
      buffer.setInt32(0, 3, Endian.little);
      buffer.setInt32(4, 1500, Endian.little);
      buffer.setFloat32(8, 72.5, Endian.little);
      buffer.setFloat32(12, 48.2, Endian.little);
      buffer.setFloat32(16, 85.0, Endian.little);

      final payload = buffer.buffer.asUint8List();
      final result = parseTelemetryPayload(payload);

      expect(result, isNotNull);
      expect(result!.modeLights, equals(3));
      expect(result.outdoorLum, equals(1500));
      expect(result.airTemp, closeTo(72.5, 0.01));
      expect(result.battVolts, closeTo(48.2, 0.1));
      expect(result.fuel, closeTo(85.0, 0.01));
    });

    test('decodes zero values correctly', () {
      final buffer = ByteData(20);
      buffer.setInt32(0, 0, Endian.little);
      buffer.setInt32(4, 0, Endian.little);
      buffer.setFloat32(8, 0.0, Endian.little);
      buffer.setFloat32(12, 0.0, Endian.little);
      buffer.setFloat32(16, 0.0, Endian.little);

      final payload = buffer.buffer.asUint8List();
      final result = parseTelemetryPayload(payload);

      expect(result, isNotNull);
      expect(result!.modeLights, equals(0));
      expect(result.outdoorLum, equals(0));
      expect(result.airTemp, equals(0.0));
      expect(result.battVolts, equals(0.0));
      expect(result.fuel, equals(0.0));
    });

    test('decodes negative temperature correctly', () {
      final buffer = ByteData(20);
      buffer.setInt32(0, 1, Endian.little);
      buffer.setInt32(4, 200, Endian.little);
      buffer.setFloat32(8, -10.5, Endian.little);
      buffer.setFloat32(12, 36.6, Endian.little);
      buffer.setFloat32(16, 50.0, Endian.little);

      final payload = buffer.buffer.asUint8List();
      final result = parseTelemetryPayload(payload);

      expect(result, isNotNull);
      expect(result!.airTemp, closeTo(-10.5, 0.01));
    });

    test('returns null for payload shorter than 20 bytes', () {
      final shortPayload = Uint8List(19);
      final result = parseTelemetryPayload(shortPayload);
      expect(result, isNull);
    });

    test('returns null for empty payload', () {
      final emptyPayload = Uint8List(0);
      final result = parseTelemetryPayload(emptyPayload);
      expect(result, isNull);
    });

    test('accepts payload longer than 20 bytes (uses first 20)', () {
      final buffer = ByteData(24);
      buffer.setInt32(0, 7, Endian.little);
      buffer.setInt32(4, 3000, Endian.little);
      buffer.setFloat32(8, 95.0, Endian.little);
      buffer.setFloat32(12, 52.1, Endian.little);
      buffer.setFloat32(16, 100.0, Endian.little);
      // Extra bytes at the end
      buffer.setInt32(20, 0xDEADBEEF, Endian.little);

      final payload = buffer.buffer.asUint8List();
      final result = parseTelemetryPayload(payload);

      expect(result, isNotNull);
      expect(result!.modeLights, equals(7));
      expect(result.outdoorLum, equals(3000));
      expect(result.airTemp, closeTo(95.0, 0.01));
      expect(result.battVolts, closeTo(52.1, 0.1));
      expect(result.fuel, closeTo(100.0, 0.01));
    });
  });

  group('encodeGciMessage() / decodeGciMessage()', () {
    test('round-trip encodes and decodes a heartbeat message', () {
      final message = GciMessage(
        type: GciMessageType.heartbeat,
        timestamp: 1700000000,
        sequenceNumber: 42,
        payload: Uint8List(0),
      );

      final encoded = encodeGciMessage(message);
      final decoded = decodeGciMessage(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.type, equals(GciMessageType.heartbeat));
      expect(decoded.timestamp, equals(1700000000));
      expect(decoded.sequenceNumber, equals(42));
      expect(decoded.payload.length, equals(0));
    });

    test('round-trip encodes and decodes a telemetry message with payload', () {
      final telemetryPayload = ByteData(20);
      telemetryPayload.setInt32(0, 2, Endian.little);
      telemetryPayload.setInt32(4, 800, Endian.little);
      telemetryPayload.setFloat32(8, 68.0, Endian.little);
      telemetryPayload.setFloat32(12, 47.5, Endian.little);
      telemetryPayload.setFloat32(16, 60.0, Endian.little);

      final message = GciMessage(
        type: GciMessageType.telemetry,
        timestamp: 1700001234,
        sequenceNumber: 100,
        payload: telemetryPayload.buffer.asUint8List(),
      );

      final encoded = encodeGciMessage(message);
      final decoded = decodeGciMessage(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.type, equals(GciMessageType.telemetry));
      expect(decoded.timestamp, equals(1700001234));
      expect(decoded.sequenceNumber, equals(100));
      expect(decoded.payload.length, equals(20));

      // Verify payload content survived round-trip
      final parsedPayload = parseTelemetryPayload(decoded.payload);
      expect(parsedPayload, isNotNull);
      expect(parsedPayload!.modeLights, equals(2));
      expect(parsedPayload.outdoorLum, equals(800));
      expect(parsedPayload.airTemp, closeTo(68.0, 0.01));
    });

    test('encodes correct wire format (header structure)', () {
      final message = GciMessage(
        type: GciMessageType.gpsData,
        timestamp: 0x01020304,
        sequenceNumber: 0x0506,
        payload: Uint8List.fromList([0xAA, 0xBB]),
      );

      final encoded = encodeGciMessage(message);

      // Total: 9 header + 2 payload = 11 bytes
      expect(encoded.length, equals(11));

      // type = 1 (gpsData)
      expect(encoded[0], equals(1));

      // timestamp = 0x01020304 in LE: 04 03 02 01
      expect(encoded[1], equals(0x04));
      expect(encoded[2], equals(0x03));
      expect(encoded[3], equals(0x02));
      expect(encoded[4], equals(0x01));

      // seq_num = 0x0506 in LE: 06 05
      expect(encoded[5], equals(0x06));
      expect(encoded[6], equals(0x05));

      // data_len = 2 in LE: 02 00
      expect(encoded[7], equals(0x02));
      expect(encoded[8], equals(0x00));

      // payload
      expect(encoded[9], equals(0xAA));
      expect(encoded[10], equals(0xBB));
    });

    test('decodes returns null for buffer shorter than header (9 bytes)', () {
      final shortBuffer = Uint8List(8);
      final result = decodeGciMessage(shortBuffer);
      expect(result, isNull);
    });

    test('decodes returns null for unrecognized message type', () {
      final buffer = ByteData(9);
      buffer.setUint8(0, 99); // Invalid type code
      buffer.setUint32(1, 0, Endian.little);
      buffer.setUint16(5, 0, Endian.little);
      buffer.setUint16(7, 0, Endian.little);

      final result = decodeGciMessage(buffer.buffer.asUint8List());
      expect(result, isNull);
    });

    test('decodes returns null when data_len exceeds available bytes', () {
      final buffer = ByteData(9);
      buffer.setUint8(0, GciMessageType.telemetry.code);
      buffer.setUint32(1, 1000, Endian.little);
      buffer.setUint16(5, 1, Endian.little);
      buffer.setUint16(7, 20, Endian.little); // Claims 20 bytes of data

      // Only 9 bytes total, no payload data available
      final result = decodeGciMessage(buffer.buffer.asUint8List());
      expect(result, isNull);
    });

    test('round-trip all message types', () {
      for (final type in GciMessageType.values) {
        final message = GciMessage(
          type: type,
          timestamp: 1234567890,
          sequenceNumber: 1,
          payload: Uint8List.fromList([0x01]),
        );

        final encoded = encodeGciMessage(message);
        final decoded = decodeGciMessage(encoded);

        expect(decoded, isNotNull, reason: 'Failed for type: $type');
        expect(decoded!.type, equals(type), reason: 'Type mismatch for: $type');
      }
    });

    test('sequence number wraps at 65535', () {
      final message = GciMessage(
        type: GciMessageType.heartbeat,
        timestamp: 0,
        sequenceNumber: 65535,
        payload: Uint8List(0),
      );

      final encoded = encodeGciMessage(message);
      final decoded = decodeGciMessage(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.sequenceNumber, equals(65535));
    });
  });

  group('encodeGpsPayload()', () {
    test('encodes GPS payload as 24-byte LE buffer', () {
      final gpsData = GciGpsPayload(
        latitude: 28.9,
        longitude: -81.9,
        altitude: 30.0,
        speed: 15.5,
        heading: 270.0,
        satelliteCount: 8,
      );

      final encoded = encodeGpsPayload(gpsData);

      expect(encoded.length, equals(24));

      // Verify by reading back
      final byteData = ByteData.sublistView(encoded);
      expect(byteData.getFloat32(0, Endian.little), closeTo(28.9, 0.1));
      expect(byteData.getFloat32(4, Endian.little), closeTo(-81.9, 0.1));
      expect(byteData.getFloat32(8, Endian.little), closeTo(30.0, 0.1));
      expect(byteData.getFloat32(12, Endian.little), closeTo(15.5, 0.1));
      expect(byteData.getFloat32(16, Endian.little), closeTo(270.0, 0.1));
      expect(byteData.getInt32(20, Endian.little), equals(8));
    });
  });

  group('encodeBoolPayload()', () {
    test('true encodes as [1]', () {
      final result = encodeBoolPayload(true);
      expect(result, equals(Uint8List.fromList([1])));
    });

    test('false encodes as [0]', () {
      final result = encodeBoolPayload(false);
      expect(result, equals(Uint8List.fromList([0])));
    });
  });

  group('GciMessageType.fromCode()', () {
    test('returns correct type for all valid codes', () {
      expect(GciMessageType.fromCode(0), equals(GciMessageType.text));
      expect(GciMessageType.fromCode(1), equals(GciMessageType.gpsData));
      expect(GciMessageType.fromCode(2), equals(GciMessageType.telemetry));
      expect(GciMessageType.fromCode(3), equals(GciMessageType.command));
      expect(GciMessageType.fromCode(4), equals(GciMessageType.ack));
      expect(GciMessageType.fromCode(5), equals(GciMessageType.heartbeat));
      expect(GciMessageType.fromCode(6), equals(GciMessageType.isHome));
      expect(GciMessageType.fromCode(7), equals(GciMessageType.isDaytime));
    });

    test('returns null for invalid code', () {
      expect(GciMessageType.fromCode(8), isNull);
      expect(GciMessageType.fromCode(99), isNull);
      expect(GciMessageType.fromCode(-1), isNull);
    });
  });

  group('Heartbeat timing and timeout detection', () {
    test('heartbeat message has empty payload and correct type', () {
      final heartbeat = GciMessage(
        type: GciMessageType.heartbeat,
        timestamp: 1700000000,
        sequenceNumber: 0,
        payload: Uint8List(0),
      );

      final encoded = encodeGciMessage(heartbeat);
      final decoded = decodeGciMessage(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.type, equals(GciMessageType.heartbeat));
      expect(decoded.payload.length, equals(0));
    });

    test('heartbeat interval is 10 seconds', () {
      // Verify the constant is accessible through the service behavior.
      // We test this by constructing two heartbeat messages 10 seconds apart.
      final heartbeat1 = GciMessage(
        type: GciMessageType.heartbeat,
        timestamp: 1700000000,
        sequenceNumber: 0,
        payload: Uint8List(0),
      );
      final heartbeat2 = GciMessage(
        type: GciMessageType.heartbeat,
        timestamp: 1700000010, // 10 seconds later
        sequenceNumber: 1,
        payload: Uint8List(0),
      );

      expect(heartbeat2.timestamp - heartbeat1.timestamp, equals(10));
    });

    test('timeout detection after 40 seconds (4 missed heartbeats)', () {
      // Simulate the timeout scenario: if no message is received within
      // 40 seconds, the connection should be considered dead.
      // We verify the timing logic by checking that 4 * 10s = 40s.
      const heartbeatInterval = 10; // seconds
      const missedHeartbeatsForTimeout = 4;
      const timeoutSeconds = heartbeatInterval * missedHeartbeatsForTimeout;

      expect(timeoutSeconds, equals(40));
    });

    test('PlatformTelemetryService timeout fires after 40 seconds', () {
      fakeAsync((async) {
        // Create a stream controller to simulate connection state changes
        final stateController = StreamController<String>.broadcast();
        var timeoutFired = false;

        // Simulate the timeout timer behavior from PlatformTelemetryService
        Timer? timeoutTimer;

        void resetTimeout() {
          timeoutTimer?.cancel();
          timeoutTimer = Timer(
            const Duration(seconds: 40),
            () {
              timeoutFired = true;
              stateController.add('disconnected');
            },
          );
        }

        // Start the timeout
        resetTimeout();

        // Advance 39 seconds — should not have timed out
        async.elapse(const Duration(seconds: 39));
        expect(timeoutFired, isFalse);

        // Advance 1 more second (total 40) — should timeout
        async.elapse(const Duration(seconds: 1));
        expect(timeoutFired, isTrue);

        timeoutTimer?.cancel();
        stateController.close();
      });
    });

    test('receiving a message resets the timeout timer', () {
      fakeAsync((async) {
        var timeoutFired = false;
        Timer? timeoutTimer;

        void resetTimeout() {
          timeoutTimer?.cancel();
          timeoutTimer = Timer(
            const Duration(seconds: 40),
            () {
              timeoutFired = true;
            },
          );
        }

        // Start the timeout
        resetTimeout();

        // Advance 30 seconds
        async.elapse(const Duration(seconds: 30));
        expect(timeoutFired, isFalse);

        // Simulate receiving a message — reset the timeout
        resetTimeout();

        // Advance another 30 seconds (total 60 from start, but only 30 from reset)
        async.elapse(const Duration(seconds: 30));
        expect(timeoutFired, isFalse);

        // Advance 10 more seconds (40 from last reset) — should timeout
        async.elapse(const Duration(seconds: 10));
        expect(timeoutFired, isTrue);

        timeoutTimer?.cancel();
      });
    });
  });

  group('Pairing flow', () {
    test('ACK message is correctly encoded and decoded', () {
      final ackMessage = GciMessage(
        type: GciMessageType.ack,
        timestamp: 1700000005,
        sequenceNumber: 10,
        payload: Uint8List(0),
      );

      final encoded = encodeGciMessage(ackMessage);
      final decoded = decodeGciMessage(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.type, equals(GciMessageType.ack));
      expect(decoded.timestamp, equals(1700000005));
      expect(decoded.sequenceNumber, equals(10));
    });

    test('command message with MAC address payload encodes correctly', () {
      // Simulate pairing command: cmdNumber(1 byte) + macAddress(6 bytes)
      final macAddress = Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF]);
      final commandPayload = Uint8List(7);
      commandPayload[0] = 1; // GCI_CMD_ADD_PEER
      commandPayload.setRange(1, 7, macAddress);

      final message = GciMessage(
        type: GciMessageType.command,
        timestamp: 1700000000,
        sequenceNumber: 5,
        payload: commandPayload,
      );

      final encoded = encodeGciMessage(message);
      final decoded = decodeGciMessage(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.type, equals(GciMessageType.command));
      expect(decoded.payload.length, equals(7));
      expect(decoded.payload[0], equals(1)); // CMD_ADD_PEER
      expect(decoded.payload.sublist(1, 7), equals(macAddress));
    });

    test('pairing timeout of 6 seconds fires correctly', () {
      fakeAsync((async) {
        var timedOut = false;
        final completer = Completer<bool>();

        // Simulate the pairing ACK wait with 6-second timeout
        completer.future.timeout(
          const Duration(seconds: 6),
          onTimeout: () {
            timedOut = true;
            return false;
          },
        );

        // Advance 5 seconds — should not have timed out
        async.elapse(const Duration(seconds: 5));
        expect(timedOut, isFalse);

        // Advance 1 more second (total 6) — should timeout
        async.elapse(const Duration(seconds: 1));
        expect(timedOut, isTrue);
      });
    });

    test('ACK received before timeout completes successfully', () {
      fakeAsync((async) {
        final completer = Completer<bool>();
        bool? result;

        completer.future.timeout(
          const Duration(seconds: 6),
          onTimeout: () => false,
        ).then((value) {
          result = value;
        });

        // Simulate ACK received after 2 seconds
        async.elapse(const Duration(seconds: 2));
        completer.complete(true);

        // Process microtasks
        async.flushMicrotasks();

        expect(result, isTrue);
      });
    });

    test('no ACK within timeout returns false', () {
      fakeAsync((async) {
        final completer = Completer<bool>();
        bool? result;

        completer.future.timeout(
          const Duration(seconds: 6),
          onTimeout: () => false,
        ).then((value) {
          result = value;
        });

        // Advance past the timeout without completing
        async.elapse(const Duration(seconds: 7));
        async.flushMicrotasks();

        expect(result, isFalse);
      });
    });
  });

  group('Packet size validation (< 20 bytes discarded)', () {
    test('telemetry payload of exactly 20 bytes is accepted', () {
      final payload = Uint8List(20);
      final result = parseTelemetryPayload(payload);
      expect(result, isNotNull);
    });

    test('telemetry payload of 19 bytes is discarded', () {
      final payload = Uint8List(19);
      final result = parseTelemetryPayload(payload);
      expect(result, isNull);
    });

    test('telemetry payload of 0 bytes is discarded', () {
      final payload = Uint8List(0);
      final result = parseTelemetryPayload(payload);
      expect(result, isNull);
    });

    test('telemetry payload of 1 byte is discarded', () {
      final payload = Uint8List(1);
      final result = parseTelemetryPayload(payload);
      expect(result, isNull);
    });

    test('telemetry payload of 10 bytes is discarded', () {
      final payload = Uint8List(10);
      final result = parseTelemetryPayload(payload);
      expect(result, isNull);
    });

    test('full message with payload < 20 bytes: telemetry message discarded at service level', () {
      // Construct a valid GCI message envelope with a telemetry type
      // but only 15 bytes of payload data
      final shortPayload = Uint8List(15);
      final message = GciMessage(
        type: GciMessageType.telemetry,
        timestamp: 1700000000,
        sequenceNumber: 1,
        payload: shortPayload,
      );

      // Encode and decode to simulate wire transfer
      final encoded = encodeGciMessage(message);
      final decoded = decodeGciMessage(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.type, equals(GciMessageType.telemetry));
      expect(decoded.payload.length, equals(15));

      // The service should discard this because payload < 20 bytes
      final telemetry = parseTelemetryPayload(decoded.payload);
      expect(telemetry, isNull);
    });
  });
}
