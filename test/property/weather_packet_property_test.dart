import 'package:glados/glados.dart';
import 'package:golf_cart_computer/domain/hot_packet_parser.dart';

/// Custom generators for weather packet property tests.
///
/// Weather Packet Format:
/// `|#01#<current_temp>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#`
extension WeatherPacketGenerators on Any {
  /// Generates a valid temperature integer in range -99 to 999.
  Generator<int> get validTemperature => intInRange(-99, 1000);

  /// Generates an invalid temperature below the valid range (-9999 to -100).
  Generator<int> get invalidTemperatureLow => intInRange(-9999, -100);

  /// Generates an invalid temperature above the valid range (1000 to 9999).
  Generator<int> get invalidTemperatureHigh => intInRange(1000, 9999);

  /// Generates a valid hour label (1-6 printable ASCII characters).
  Generator<String> get validHourLabel =>
      listWithLengthInRange(1, 6, intInRange(0x30, 0x7A)).map(
        (codeUnits) => String.fromCharCodes(codeUnits),
      );

  /// Generates an invalid hour label (> 6 characters).
  Generator<String> get invalidHourLabel =>
      listWithLengthInRange(7, 12, intInRange(0x30, 0x7A)).map(
        (codeUnits) => String.fromCharCodes(codeUnits),
      );

  /// Generates a valid glyph code (1-10 printable ASCII characters, no # or ,).
  Generator<String> get validGlyphCode =>
      listWithLengthInRange(1, 10, intInRange(0x30, 0x7A)).map(
        (codeUnits) => String.fromCharCodes(
          codeUnits.where((c) => c != 0x23 && c != 0x2C).toList(),
        ),
      );

  /// Generates a valid precipitation value in range 0.0 to 100.0.
  /// Returns the value as a string representation.
  Generator<double> get validPrecipitation =>
      doubleInRange(0.0, 100.0);

  /// Generates a valid precipitation string (formatted as double).
  Generator<String> get validPrecipitationStr =>
      doubleInRange(0.0, 100.0).map(
        (v) => v.toStringAsFixed(1),
      );

  /// Generates a non-zero precipitation value (0.1 to 100.0).
  Generator<String> get nonZeroPrecipitationStr =>
      doubleInRange(0.1, 100.0).map(
        (v) => v.toStringAsFixed(1),
      );

  /// Generates a single valid forecast section: `<hr>,<glyph>,<temp>,<precip>`
  Generator<String> get validForecastSection => combine4(
        validHourLabel,
        validGlyphCode,
        validTemperature,
        validPrecipitationStr,
        (String hour, String glyph, int temp, String precip) {
          // Ensure glyph is non-empty after filtering
          final safeGlyph = glyph.isEmpty ? 'sun' : glyph;
          return '$hour,$safeGlyph,$temp,$precip';
        },
      );

  /// Generates a complete valid weather packet string.
  Generator<String> get validWeatherPacket => combine5(
        validTemperature,
        validForecastSection,
        validForecastSection,
        validForecastSection,
        validForecastSection,
        (int currentTemp, String f1, String f2, String f3, String f4) =>
            '|#01#$currentTemp#$f1#$f2#$f3#$f4#',
      );

  /// Generates a weather packet with a specific precipitation value for
  /// testing zero-clearing behavior.
  Generator<String> get weatherPacketWithZeroPrecip => combine4(
        validTemperature,
        validHourLabel,
        validGlyphCode,
        validTemperature,
        (int currentTemp, String hour, String glyph, int forecastTemp) {
          final safeGlyph = glyph.isEmpty ? 'sun' : glyph;
          // Build a packet where all 4 forecasts have 0.0 precipitation
          final section = '$hour,$safeGlyph,$forecastTemp,0.0';
          return '|#01#$currentTemp#$section#$section#$section#$section#';
        },
      );

  /// Generates a weather packet with a specific non-zero precipitation value.
  Generator<String> get weatherPacketWithNonZeroPrecip => combine5(
        validTemperature,
        validHourLabel,
        validGlyphCode,
        validTemperature,
        nonZeroPrecipitationStr,
        (int currentTemp, String hour, String glyph, int forecastTemp,
            String precip) {
          final safeGlyph = glyph.isEmpty ? 'sun' : glyph;
          final section = '$hour,$safeGlyph,$forecastTemp,$precip';
          return '|#01#$currentTemp#$section#$section#$section#$section#';
        },
      );
}

void main() {
  final parser = HotPacketParser();

  group('Property 6: Weather packet structural validation', () {
    /// **Validates: Requirements 3.2, 3.9, 3.10, 3.11, 3.13, 3.14**
    ///
    /// For any structurally valid weather packet (starts with `|#01#`, has
    /// exactly 7 `#` and 12 `,`, valid temps/hours/precip/glyphs), the parser
    /// should accept it and return a non-null WeatherData.
    Glados(any.validWeatherPacket).test(
      'valid weather packets are accepted by the parser',
      (packet) {
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNotNull,
            reason: 'Valid packet should be accepted: $packet');
      },
    );

    /// **Validates: Requirements 3.2, 3.9, 3.10, 3.11, 3.13, 3.14**
    ///
    /// A packet missing the `|#01#` prefix should be rejected.
    Glados(any.validWeatherPacket).test(
      'packets without |#01# prefix are rejected',
      (packet) {
        // Remove the leading '|' to break the prefix
        final invalidPacket = packet.substring(1);
        final result = parser.parseWeatherPacket(invalidPacket);
        expect(result, isNull,
            reason: 'Packet without | prefix should be rejected');
      },
    );

    /// **Validates: Requirements 3.2, 3.9, 3.10, 3.11, 3.13, 3.14**
    ///
    /// A packet with wrong number of `#` delimiters should be rejected.
    Glados(any.validWeatherPacket).test(
      'packets with extra # delimiter are rejected',
      (packet) {
        // Add an extra # to break the delimiter count
        final invalidPacket = '$packet#';
        final result = parser.parseWeatherPacket(invalidPacket);
        expect(result, isNull,
            reason: 'Packet with extra # should be rejected');
      },
    );

    /// **Validates: Requirements 3.2, 3.9, 3.10, 3.11, 3.13, 3.14**
    ///
    /// A packet with wrong number of `,` delimiters should be rejected.
    Glados(any.validWeatherPacket).test(
      'packets with extra , delimiter are rejected',
      (packet) {
        // Add an extra comma to break the delimiter count
        final invalidPacket = packet.replaceFirst('#', ',extra#');
        // This changes the comma count, so it should be rejected
        final result = parser.parseWeatherPacket(invalidPacket);
        expect(result, isNull,
            reason: 'Packet with wrong comma count should be rejected');
      },
    );

    /// **Validates: Requirements 3.9**
    ///
    /// A packet with temperature above 999 should be rejected.
    Glados2(any.invalidTemperatureHigh, any.validWeatherPacket).test(
      'packets with temperature above 999 are rejected',
      (invalidTemp, validPacket) {
        // Replace the current temperature with an invalid one
        final parts = validPacket.split('#');
        parts[2] = invalidTemp.toString();
        final invalidPacket = parts.join('#');
        final result = parser.parseWeatherPacket(invalidPacket);
        expect(result, isNull,
            reason:
                'Packet with temperature $invalidTemp should be rejected');
      },
    );

    /// **Validates: Requirements 3.9**
    ///
    /// A packet with temperature below -99 should be rejected.
    Glados2(any.invalidTemperatureLow, any.validWeatherPacket).test(
      'packets with temperature below -99 are rejected',
      (invalidTemp, validPacket) {
        // Replace the current temperature with an invalid one
        final parts = validPacket.split('#');
        parts[2] = invalidTemp.toString();
        final invalidPacket = parts.join('#');
        final result = parser.parseWeatherPacket(invalidPacket);
        expect(result, isNull,
            reason:
                'Packet with temperature $invalidTemp should be rejected');
      },
    );

    /// **Validates: Requirements 3.10**
    ///
    /// A packet with hour label > 6 characters should be rejected.
    Glados2(any.invalidHourLabel, any.validTemperature).test(
      'packets with hour label > 6 chars are rejected',
      (longHour, temp) {
        // Build a packet with an oversized hour label in the first forecast
        final section = '$longHour,sun,$temp,5.0';
        final packet = '|#01#$temp#$section#2pm,cloud,70,1.0#3pm,rain,65,20.0#4pm,sun,72,0.0#';
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNull,
            reason:
                'Packet with hour label "$longHour" (${longHour.length} chars) should be rejected');
      },
    );

    /// **Validates: Requirements 3.13**
    ///
    /// A packet with glyph > 10 characters should be rejected.
    Glados(any.validTemperature).test(
      'packets with glyph > 10 chars are rejected',
      (temp) {
        // Build a packet with an oversized glyph (11 chars)
        const longGlyph = 'abcdefghijk'; // 11 characters
        final section = '1pm,$longGlyph,$temp,5.0';
        final packet =
            '|#01#$temp#$section#2pm,cloud,$temp,1.0#3pm,rain,$temp,20.0#4pm,sun,$temp,0.0#';
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNull,
            reason: 'Packet with glyph > 10 chars should be rejected');
      },
    );

    /// **Validates: Requirements 3.11**
    ///
    /// A packet with precipitation outside 0.0-100.0 should be rejected.
    Glados(any.validTemperature).test(
      'packets with precipitation > 100.0 are rejected',
      (temp) {
        final section = '1pm,sun,$temp,150.0';
        final packet =
            '|#01#$temp#$section#2pm,cloud,$temp,1.0#3pm,rain,$temp,20.0#4pm,sun,$temp,0.0#';
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNull,
            reason: 'Packet with precipitation > 100.0 should be rejected');
      },
    );

    /// **Validates: Requirements 3.11**
    ///
    /// A packet with negative precipitation should be rejected.
    Glados(any.validTemperature).test(
      'packets with negative precipitation are rejected',
      (temp) {
        final section = '1pm,sun,$temp,-5.0';
        final packet =
            '|#01#$temp#$section#2pm,cloud,$temp,1.0#3pm,rain,$temp,20.0#4pm,sun,$temp,0.0#';
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNull,
            reason: 'Packet with negative precipitation should be rejected');
      },
    );
  });

  group('Property 7: Weather packet parsing correctness', () {
    /// **Validates: Requirements 3.1, 3.3, 3.4**
    ///
    /// For any structurally valid weather packet, parsing should produce a
    /// WeatherData object with a valid current temperature and exactly 4
    /// HourForecast entries.
    Glados(any.validWeatherPacket).test(
      'valid packets produce WeatherData with current temp and 4 forecasts',
      (packet) {
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNotNull);

        // Verify it's a WeatherData with exactly 4 forecasts
        expect(result!.forecasts.length, equals(4));

        // Verify current temperature is within valid range
        expect(result.currentTemp, inInclusiveRange(-99, 999));
      },
    );

    /// **Validates: Requirements 3.1, 3.3, 3.4**
    ///
    /// Each HourForecast entry should contain a non-empty hour label,
    /// a glyph code, a temperature, and a precipitation string.
    Glados(any.validWeatherPacket).test(
      'each HourForecast has non-empty hour label, glyph, valid temp',
      (packet) {
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNotNull);

        for (final forecast in result!.forecasts) {
          // Non-empty hour label
          expect(forecast.hourLabel, isNotEmpty,
              reason: 'Hour label should be non-empty');
          expect(forecast.hourLabel.length, lessThanOrEqualTo(6));

          // Glyph code present
          expect(forecast.glyphCode, isNotNull);
          expect(forecast.glyphCode.length, lessThanOrEqualTo(10));

          // Temperature in valid range
          expect(forecast.temperature, inInclusiveRange(-99, 999));

          // Precipitation is a string (may be empty for 0.0)
          expect(forecast.precipitation, isNotNull);
        }
      },
    );

    /// **Validates: Requirements 3.1, 3.3, 3.4**
    ///
    /// The parsed current temperature should match the value in the packet.
    Glados(any.validWeatherPacket).test(
      'parsed current temperature matches the packet value',
      (packet) {
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNotNull);

        // Extract expected current temp from the packet
        final parts = packet.split('#');
        final expectedTemp = int.parse(parts[2]);
        expect(result!.currentTemp, equals(expectedTemp));
      },
    );
  });

  group('Property 8: Precipitation zero-clearing', () {
    /// **Validates: Requirements 3.12**
    ///
    /// For any weather packet where precipitation is "0.0", the parsed
    /// precipitation field should be an empty string.
    Glados(any.weatherPacketWithZeroPrecip).test(
      '0.0 precipitation is replaced with empty string',
      (packet) {
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNotNull);

        for (final forecast in result!.forecasts) {
          expect(forecast.precipitation, equals(''),
              reason:
                  'Precipitation "0.0" should be replaced with empty string');
        }
      },
    );

    /// **Validates: Requirements 3.12**
    ///
    /// For any weather packet where precipitation is non-zero, the parsed
    /// precipitation field should preserve the original numeric value string.
    Glados(any.weatherPacketWithNonZeroPrecip).test(
      'non-zero precipitation values are preserved',
      (packet) {
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNotNull);

        for (final forecast in result!.forecasts) {
          // Non-zero precipitation should not be empty
          expect(forecast.precipitation, isNotEmpty,
              reason: 'Non-zero precipitation should be preserved');

          // The value should be parseable as a double
          final precipValue = double.tryParse(forecast.precipitation);
          expect(precipValue, isNotNull,
              reason: 'Precipitation should be a valid numeric string');
          expect(precipValue, greaterThan(0.0),
              reason: 'Non-zero precipitation should be > 0.0');
        }
      },
    );

    /// **Validates: Requirements 3.12**
    ///
    /// Mixed precipitation values: verify 0.0 becomes empty and others are
    /// preserved within the same packet.
    Glados2(any.validTemperature, any.nonZeroPrecipitationStr).test(
      'mixed precipitation: 0.0 cleared, non-zero preserved in same packet',
      (temp, nonZeroPrecip) {
        // Build a packet with mix of 0.0 and non-zero precipitation
        final packet =
            '|#01#$temp#1pm,sun,$temp,0.0#2pm,cloud,$temp,$nonZeroPrecip#3pm,rain,$temp,0.0#4pm,sun,$temp,$nonZeroPrecip#';
        final result = parser.parseWeatherPacket(packet);
        expect(result, isNotNull);

        // Forecast 0 and 2 have 0.0 → empty string
        expect(result!.forecasts[0].precipitation, equals(''));
        expect(result.forecasts[2].precipitation, equals(''));

        // Forecast 1 and 3 have non-zero → preserved
        expect(result.forecasts[1].precipitation, equals(nonZeroPrecip));
        expect(result.forecasts[3].precipitation, equals(nonZeroPrecip));
      },
    );
  });
}
