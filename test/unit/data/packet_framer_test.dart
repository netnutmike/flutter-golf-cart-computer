import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/data/services/packet_framer.dart';

void main() {
  late PacketFramer framer;

  setUp(() {
    framer = PacketFramer();
  });

  group('frame()', () {
    test('empty payload produces 4 zero bytes', () {
      final payload = Uint8List(0);
      final framed = framer.frame(payload);

      expect(framed.length, equals(4));
      expect(framed, equals(Uint8List.fromList([0x00, 0x00, 0x00, 0x00])));
    });

    test('known payload [0x01, 0x02, 0x03] produces correct length prefix + payload', () {
      final payload = Uint8List.fromList([0x01, 0x02, 0x03]);
      final framed = framer.frame(payload);

      expect(framed.length, equals(7));
      // 4-byte big-endian length prefix for 3 bytes: 0x00 0x00 0x00 0x03
      expect(framed, equals(Uint8List.fromList([0x00, 0x00, 0x00, 0x03, 0x01, 0x02, 0x03])));
    });
  });

  group('unframe()', () {
    test('valid framed data returns original payload', () {
      // Frame: length prefix [0x00, 0x00, 0x00, 0x03] + payload [0x01, 0x02, 0x03]
      final framedData = Uint8List.fromList([0x00, 0x00, 0x00, 0x03, 0x01, 0x02, 0x03]);
      final result = framer.unframe(framedData);

      expect(result, isNotNull);
      expect(result, equals(Uint8List.fromList([0x01, 0x02, 0x03])));
    });

    test('buffer shorter than 4 bytes returns null', () {
      final shortBuffer = Uint8List.fromList([0x00, 0x00, 0x01]);
      final result = framer.unframe(shortBuffer);

      expect(result, isNull);
    });

    test('length prefix exceeding buffer returns null', () {
      // Length prefix says 10 bytes, but only 3 bytes of payload available
      final framedData = Uint8List.fromList([0x00, 0x00, 0x00, 0x0A, 0x01, 0x02, 0x03]);
      final result = framer.unframe(framedData);

      expect(result, isNull);
    });
  });

  group('splitForMtu()', () {
    test('MTU 20 (chunk size 17) splits correctly', () {
      // Create framed data of 34 bytes (should split into 2 chunks of 17)
      final framedData = Uint8List(34);
      for (var i = 0; i < 34; i++) {
        framedData[i] = i;
      }

      final chunks = framer.splitForMtu(framedData, 20);

      expect(chunks.length, equals(2));
      expect(chunks[0].length, equals(17));
      expect(chunks[1].length, equals(17));
      expect(chunks[0], equals(Uint8List.fromList(List.generate(17, (i) => i))));
      expect(chunks[1], equals(Uint8List.fromList(List.generate(17, (i) => i + 17))));
    });

    test('MTU 128 (chunk size 125) splits correctly', () {
      // Create framed data of 250 bytes (should split into 2 chunks)
      final framedData = Uint8List(250);
      for (var i = 0; i < 250; i++) {
        framedData[i] = i % 256;
      }

      final chunks = framer.splitForMtu(framedData, 128);

      expect(chunks.length, equals(2));
      expect(chunks[0].length, equals(125));
      expect(chunks[1].length, equals(125));
    });

    test('MTU 512 (chunk size 509) splits correctly', () {
      // Create framed data of 1018 bytes (should split into 2 chunks)
      final framedData = Uint8List(1018);
      for (var i = 0; i < 1018; i++) {
        framedData[i] = i % 256;
      }

      final chunks = framer.splitForMtu(framedData, 512);

      expect(chunks.length, equals(2));
      expect(chunks[0].length, equals(509));
      expect(chunks[1].length, equals(509));
    });

    test('data fitting in single chunk returns single-element list', () {
      // Create framed data of 10 bytes with MTU 20 (chunk size 17)
      final framedData = Uint8List(10);
      for (var i = 0; i < 10; i++) {
        framedData[i] = i;
      }

      final chunks = framer.splitForMtu(framedData, 20);

      expect(chunks.length, equals(1));
      expect(chunks[0], equals(framedData));
    });
  });

  group('frame/unframe round-trip', () {
    test('single byte payload round-trip', () {
      final payload = Uint8List.fromList([0x42]);
      final framed = framer.frame(payload);
      final unframed = framer.unframe(framed);

      expect(unframed, isNotNull);
      expect(unframed, equals(payload));
    });

    test('larger payload round-trip', () {
      final payload = Uint8List.fromList(
        List.generate(256, (i) => i % 256),
      );
      final framed = framer.frame(payload);
      final unframed = framer.unframe(framed);

      expect(unframed, isNotNull);
      expect(unframed, equals(payload));
    });
  });
}
