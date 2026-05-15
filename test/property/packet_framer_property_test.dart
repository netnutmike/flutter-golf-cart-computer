import 'dart:typed_data';

import 'package:glados/glados.dart';
import 'package:golf_cart_computer/data/services/packet_framer.dart';

/// Custom generator for Uint8List payloads of varying length.
///
/// Generates byte arrays from 0 to a capped max length for test performance.
/// The property holds for 0 to 65535 bytes per the spec.
extension Uint8ListGenerators on Any {
  /// Generates a Uint8List with length between 0 and ~1000 bytes.
  Generator<Uint8List> get uint8List =>
      listWithLengthInRange(0, 1000, uint8).map(
        (bytes) => Uint8List.fromList(bytes),
      );

  /// Generates a Uint8List with length strictly less than 4 bytes (0, 1, 2, or 3).
  Generator<Uint8List> get shortUint8List =>
      listWithLengthInRange(0, 4, uint8).map(
        (bytes) => Uint8List.fromList(bytes),
      );
}

void main() {
  final framer = PacketFramer();

  group('Property 2: Packet framing round-trip', () {
    /// **Validates: Requirements 18.2**
    ///
    /// For any byte array (0 to 65535 bytes), frame then unframe produces
    /// the original payload.
    Glados(any.uint8List).test(
      'frame then unframe produces the original payload',
      (payload) {
        final framed = framer.frame(payload);
        final result = framer.unframe(framed);

        expect(result, isNotNull);
        expect(result, equals(payload));
      },
    );

    /// **Validates: Requirements 18.2**
    ///
    /// Framed data shorter than 4 bytes returns null from unframe,
    /// since there is no valid length prefix.
    Glados(any.shortUint8List).test(
      'framed data < 4 bytes returns null from unframe',
      (shortData) {
        // shortUint8List generates 0-3 byte arrays; skip if it happens to be 4
        if (shortData.length >= 4) return;

        final result = framer.unframe(shortData);
        expect(result, isNull);
      },
    );

    /// **Validates: Requirements 18.2**
    ///
    /// When the length prefix value exceeds the remaining buffer length,
    /// unframe returns null.
    Glados2(any.uint8List, any.intInRange(1, 100)).test(
      'length prefix exceeding buffer returns null',
      (payload, extraBytes) {
        final framed = framer.frame(payload);

        // Only truncate if there's payload to remove
        if (payload.isEmpty) return;

        // Truncate the framed data so the length prefix claims more data
        // than is actually available in the buffer.
        final truncateAmount = extraBytes.clamp(1, payload.length);
        final truncated = Uint8List.fromList(
          framed.sublist(0, framed.length - truncateAmount),
        );

        // The length prefix still says the original payload length, but the
        // buffer is now shorter, so unframe should return null.
        expect(framer.unframe(truncated), isNull);
      },
    );
  });
}
