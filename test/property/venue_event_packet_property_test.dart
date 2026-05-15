import 'package:glados/glados.dart';
import 'package:golf_cart_computer/domain/hot_packet_parser.dart';
import 'package:golf_cart_computer/domain/models/entertainment_data.dart';

/// Custom generators for venue/event packet property tests.
///
/// Generates valid venue names, event names, and complete venue/event packets
/// that conform to the `|#02#<venue>,<event>#...#` format.
extension VenueEventGenerators on Any {
  /// Generates a non-empty venue name that does not contain `#` or `,`.
  /// Venue is the text before the first comma, so it must not contain commas.
  Generator<String> get venueName => listWithLengthInRange(
        1,
        20,
        intInRange(0x20, 0x7E), // printable ASCII
      ).map((codes) {
        final str = String.fromCharCodes(codes);
        // Remove '#' and ',' characters since they are delimiters
        final cleaned = str.replaceAll('#', 'X').replaceAll(',', 'X');
        // Ensure non-empty after cleaning
        return cleaned.isEmpty ? 'Venue' : cleaned;
      });

  /// Generates a non-empty event name that does not contain `#`.
  /// Event names may contain commas (text after the first comma).
  Generator<String> get eventName => listWithLengthInRange(
        1,
        30,
        intInRange(0x20, 0x7E), // printable ASCII
      ).map((codes) {
        final str = String.fromCharCodes(codes);
        // Remove '#' characters since they are pair delimiters
        final cleaned = str.replaceAll('#', 'X');
        return cleaned.isEmpty ? 'Event' : cleaned;
      });

  /// Generates a valid venue/event pair as a (venue, event) tuple.
  Generator<(String, String)> get venueEventPair =>
      combine2(venueName, eventName, (String v, String e) => (v, e));

  /// Generates a list of 1-12 venue/event pairs.
  Generator<List<(String, String)>> get venueEventPairs =>
      listWithLengthInRange(1, 12, venueEventPair);

  /// Generates a list of 13-20 venue/event pairs (exceeds the 12-pair limit).
  Generator<List<(String, String)>> get oversizedVenueEventPairs =>
      listWithLengthInRange(13, 20, venueEventPair);
}

/// Builds a raw venue/event packet string from a list of (venue, event) pairs.
String buildVenueEventPacket(List<(String, String)> pairs) {
  final buffer = StringBuffer('|#02#');
  for (final (venue, event) in pairs) {
    buffer.write('$venue,$event#');
  }
  return buffer.toString();
}

void main() {
  final parser = HotPacketParser();

  group('Property 9: Venue/event packet parsing', () {
    /// **Validates: Requirements 4.1, 4.2, 4.3, 4.6**
    ///
    /// For any valid venue/event packet with 1-12 pairs, parsing should
    /// produce a list of VenueEvent objects where each entry's venue name
    /// equals the text before the first comma and event name equals the text
    /// after the first comma.
    Glados(any.venueEventPairs).test(
      'valid packets produce correct VenueEvent list with venue = text before first comma, event = text after',
      (pairs) {
        final packet = buildVenueEventPacket(pairs);
        final result = parser.parseVenueEventPacket(packet);

        expect(result, isNotNull);
        expect(result, isA<List<VenueEvent>>());

        for (var i = 0; i < pairs.length; i++) {
          final (expectedVenue, expectedEvent) = pairs[i];
          expect(result![i].venueName, equals(expectedVenue));
          expect(result[i].eventName, equals(expectedEvent));
        }
      },
    );

    /// **Validates: Requirements 4.1, 4.2, 4.3, 4.6**
    ///
    /// For any valid venue/event packet with 1-12 pairs, the parsed list
    /// length should equal the number of input pairs.
    Glados(any.venueEventPairs).test(
      'list length equals number of valid pairs (up to 12)',
      (pairs) {
        final packet = buildVenueEventPacket(pairs);
        final result = parser.parseVenueEventPacket(packet);

        expect(result, isNotNull);
        expect(result!.length, equals(pairs.length));
      },
    );

    /// **Validates: Requirements 4.6**
    ///
    /// For packets with more than 12 pairs, only the first 12 should be
    /// returned.
    Glados(any.oversizedVenueEventPairs).test(
      'packets with more than 12 pairs are truncated to 12',
      (pairs) {
        final packet = buildVenueEventPacket(pairs);
        final result = parser.parseVenueEventPacket(packet);

        expect(result, isNotNull);
        expect(result!.length, equals(12));

        // Verify the first 12 pairs match
        for (var i = 0; i < 12; i++) {
          final (expectedVenue, expectedEvent) = pairs[i];
          expect(result[i].venueName, equals(expectedVenue));
          expect(result[i].eventName, equals(expectedEvent));
        }
      },
    );

    /// **Validates: Requirements 4.2**
    ///
    /// Event names containing commas should be preserved correctly since
    /// only the first comma separates venue from event.
    Glados(any.venueName).test(
      'event names with commas are parsed correctly (first comma splits venue from event)',
      (venue) {
        // Build a packet where the event contains commas
        final eventWithCommas = 'Live Music, Jazz, Blues';
        final packet = '|#02#$venue,$eventWithCommas#';
        final result = parser.parseVenueEventPacket(packet);

        expect(result, isNotNull);
        expect(result!.length, equals(1));
        expect(result[0].venueName, equals(venue));
        expect(result[0].eventName, equals(eventWithCommas));
      },
    );
  });
}
