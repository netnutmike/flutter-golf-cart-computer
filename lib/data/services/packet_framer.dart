import 'dart:typed_data';

/// Handles framing and unframing of protobuf messages with 4-byte big-endian
/// length prefixes, and splitting framed data into MTU-sized chunks for BLE
/// writes.
class PacketFramer {
  /// Maximum payload size supported (65535 bytes).
  static const int maxPayloadSize = 65535;

  /// Size of the length prefix in bytes.
  static const int prefixSize = 4;

  /// Frames a protobuf payload with a 4-byte big-endian length prefix.
  ///
  /// The length prefix encodes the payload size (not including the prefix
  /// itself). Accepts payloads from 0 to [maxPayloadSize] bytes.
  Uint8List frame(Uint8List payload) {
    final length = payload.length;
    final framed = Uint8List(prefixSize + length);
    // Write 4-byte big-endian length prefix
    framed[0] = (length >> 24) & 0xFF;
    framed[1] = (length >> 16) & 0xFF;
    framed[2] = (length >> 8) & 0xFF;
    framed[3] = length & 0xFF;
    // Copy payload after prefix
    framed.setRange(prefixSize, prefixSize + length, payload);
    return framed;
  }

  /// Unframes a received buffer, extracting the payload after the length prefix.
  ///
  /// Returns `null` if:
  /// - The buffer is shorter than 4 bytes (no valid length prefix)
  /// - The length prefix indicates more bytes than are available in the buffer
  Uint8List? unframe(Uint8List framedData) {
    if (framedData.length < prefixSize) {
      return null;
    }
    // Read 4-byte big-endian length prefix
    final length = (framedData[0] << 24) |
        (framedData[1] << 16) |
        (framedData[2] << 8) |
        framedData[3];
    // Validate that the buffer contains enough data
    if (length < 0 || framedData.length < prefixSize + length) {
      return null;
    }
    return Uint8List.fromList(
      framedData.sublist(prefixSize, prefixSize + length),
    );
  }

  /// Splits a framed packet into MTU-sized chunks for BLE write.
  ///
  /// Each chunk is at most (mtuSize - 3) bytes, which accounts for the ATT
  /// protocol overhead. If [framedData] fits within a single chunk, a
  /// single-element list is returned.
  List<Uint8List> splitForMtu(Uint8List framedData, int mtuSize) {
    final chunkSize = mtuSize - 3;
    if (chunkSize <= 0) {
      // If MTU is too small to carry any data, return the whole frame as one
      // chunk (caller must handle this edge case at a higher level).
      return [framedData];
    }
    if (framedData.length <= chunkSize) {
      return [framedData];
    }
    final chunks = <Uint8List>[];
    var offset = 0;
    while (offset < framedData.length) {
      final end = offset + chunkSize;
      final chunk = framedData.sublist(
        offset,
        end > framedData.length ? framedData.length : end,
      );
      chunks.add(Uint8List.fromList(chunk));
      offset = end;
    }
    return chunks;
  }
}
