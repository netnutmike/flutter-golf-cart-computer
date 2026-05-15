import 'dart:developer';

import 'package:golf_cart_computer/domain/models/entertainment_data.dart';
import 'package:golf_cart_computer/domain/models/weather_data.dart';

/// Parses structured HoT (Hands-off-Transmission) data packets received via
/// Meshtastic text messages.
///
/// Supports two packet types:
/// - Type 01: Weather data (current temp + 4-hour forecast)
/// - Type 02: Venue/event entertainment data (1-12 pairs)
class HotPacketParser {
  /// Returns true if the text starts with '|' (HoT packet indicator).
  bool isHotPacket(String text) {
    return text.isNotEmpty && text.startsWith('|');
  }

  /// Extracts the packet type code after `|#`.
  ///
  /// Returns the integer type code (e.g., 1 for weather, 2 for venue/event),
  /// or null if the format is invalid.
  int? parsePacketType(String text) {
    if (!isHotPacket(text)) return null;
    if (text.length < 4) return null;
    if (text[1] != '#') return null;

    // Find the next '#' after position 2 to extract the type code
    final nextHash = text.indexOf('#', 2);
    if (nextHash == -1) return null;

    final typeStr = text.substring(2, nextHash);
    return int.tryParse(typeStr);
  }

  /// Parses a weather packet. Returns null if validation fails.
  ///
  /// Weather Packet Format:
  /// `|#01#<current_temp>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#<hr>,<glyph>,<temp>,<precip>#`
  ///
  /// Validation rules:
  /// - Exactly 7 `#` delimiters and 12 `,` delimiters
  /// - Temperature range: -99 to 999
  /// - Hour labels: ≤6 characters
  /// - Precipitation range: 0.0 to 100.0
  /// - Glyph fields: ≤10 characters
  /// - Zero precipitation (`0.0`) replaced with empty string
  WeatherData? parseWeatherPacket(String rawPacket) {
    // Validate delimiter counts
    final hashCount = '#'.allMatches(rawPacket).length;
    if (hashCount != 7) {
      log(
        'Weather packet validation failed: expected 7 # delimiters, found $hashCount',
        name: 'HotPacketParser',
      );
      return null;
    }

    final commaCount = ','.allMatches(rawPacket).length;
    if (commaCount != 12) {
      log(
        'Weather packet validation failed: expected 12 , delimiters, found $commaCount',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Split by '#' - should produce 8 parts (before first #, between #s, after last #)
    final parts = rawPacket.split('#');
    // parts[0] = '|', parts[1] = '01', parts[2] = current_temp,
    // parts[3..6] = forecast sections, parts[7] = '' (trailing)

    if (parts.length != 8) {
      log(
        'Weather packet validation failed: unexpected segment count ${parts.length}',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Validate packet type
    if (parts[0] != '|' || parts[1] != '01') {
      log(
        'Weather packet validation failed: invalid prefix "${parts[0]}#${parts[1]}"',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Parse current temperature
    final currentTemp = int.tryParse(parts[2]);
    if (currentTemp == null) {
      log(
        'Weather packet validation failed: invalid current temperature "${parts[2]}"',
        name: 'HotPacketParser',
      );
      return null;
    }
    if (!_isValidTemperature(currentTemp)) {
      log(
        'Weather packet validation failed: current temperature $currentTemp out of range (-99 to 999)',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Parse 4 forecast sections (parts[3] through parts[6])
    final forecasts = <HourForecast>[];
    for (var i = 3; i <= 6; i++) {
      final forecast = _parseForecastSection(parts[i], i - 2);
      if (forecast == null) return null;
      forecasts.add(forecast);
    }

    return WeatherData(
      currentTemp: currentTemp,
      forecasts: forecasts,
      receivedTimestamp: '',
      isStored: false,
    );
  }

  /// Parses a venue/event packet. Returns null if validation fails.
  ///
  /// Venue/Event Packet Format:
  /// `|#02#<venue>,<event>#<venue>,<event>#...#`
  ///
  /// - 1-12 venue/event pairs
  /// - First comma in each pair separates venue from event
  /// - Both venue and event must be non-empty
  List<VenueEvent>? parseVenueEventPacket(String rawPacket) {
    // Basic prefix validation
    if (!rawPacket.startsWith('|#02#')) {
      log(
        'Venue/event packet validation failed: missing |#02# prefix',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Split by '#'
    final parts = rawPacket.split('#');
    // parts[0] = '|', parts[1] = '02', parts[2..n-1] = venue,event pairs,
    // parts[n] = '' (trailing after final #)

    if (parts.length < 4) {
      log(
        'Venue/event packet validation failed: insufficient segments',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Extract venue/event pair segments (skip prefix parts and trailing empty)
    // The pairs start at index 2 and go until the last non-empty segment
    final pairSegments = <String>[];
    for (var i = 2; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        pairSegments.add(parts[i]);
      }
    }

    if (pairSegments.isEmpty) {
      log(
        'Venue/event packet validation failed: no venue/event pairs found',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Parse each pair, limit to 12
    final venues = <VenueEvent>[];
    for (final segment in pairSegments) {
      if (venues.length >= 12) break;

      final venueEvent = _parseVenueEventPair(segment);
      if (venueEvent == null) {
        log(
          'Venue/event packet validation failed: invalid pair "$segment"',
          name: 'HotPacketParser',
        );
        return null;
      }
      venues.add(venueEvent);
    }

    if (venues.isEmpty) {
      log(
        'Venue/event packet validation failed: no valid venue/event pairs',
        name: 'HotPacketParser',
      );
      return null;
    }

    return venues;
  }

  /// Parses a single forecast section: `<hr>,<glyph>,<temp>,<precip>`
  HourForecast? _parseForecastSection(String section, int forecastIndex) {
    final fields = section.split(',');
    if (fields.length != 4) {
      log(
        'Weather packet validation failed: forecast $forecastIndex has ${fields.length} fields, expected 4',
        name: 'HotPacketParser',
      );
      return null;
    }

    final hourLabel = fields[0];
    final glyph = fields[1];
    final tempStr = fields[2];
    final precipStr = fields[3];

    // Validate hour label length
    if (hourLabel.length > 6) {
      log(
        'Weather packet validation failed: forecast $forecastIndex hour label "$hourLabel" exceeds 6 characters',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Validate glyph length
    if (glyph.length > 10) {
      log(
        'Weather packet validation failed: forecast $forecastIndex glyph "$glyph" exceeds 10 characters',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Validate temperature
    final temp = int.tryParse(tempStr);
    if (temp == null) {
      log(
        'Weather packet validation failed: forecast $forecastIndex temperature "$tempStr" is not a valid integer',
        name: 'HotPacketParser',
      );
      return null;
    }
    if (!_isValidTemperature(temp)) {
      log(
        'Weather packet validation failed: forecast $forecastIndex temperature $temp out of range (-99 to 999)',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Validate precipitation
    final precip = double.tryParse(precipStr);
    if (precip == null) {
      log(
        'Weather packet validation failed: forecast $forecastIndex precipitation "$precipStr" is not a valid number',
        name: 'HotPacketParser',
      );
      return null;
    }
    if (precip < 0.0 || precip > 100.0) {
      log(
        'Weather packet validation failed: forecast $forecastIndex precipitation $precip out of range (0.0 to 100.0)',
        name: 'HotPacketParser',
      );
      return null;
    }

    // Replace 0.0 precipitation with empty string
    final precipDisplay = precip == 0.0 ? '' : precipStr;

    return HourForecast(
      hourLabel: hourLabel,
      glyphCode: glyph,
      temperature: temp,
      precipitation: precipDisplay,
    );
  }

  /// Validates temperature is within the allowed range of -99 to 999.
  bool _isValidTemperature(int temp) {
    return temp >= -99 && temp <= 999;
  }

  /// Parses a single venue/event pair segment.
  /// Splits at the first comma; venue is before, event is after.
  /// Both must be non-empty.
  VenueEvent? _parseVenueEventPair(String segment) {
    final commaIndex = segment.indexOf(',');
    if (commaIndex == -1) return null;

    final venue = segment.substring(0, commaIndex);
    final event = segment.substring(commaIndex + 1);

    if (venue.isEmpty || event.isEmpty) return null;

    return VenueEvent(venueName: venue, eventName: event);
  }
}
