import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/domain/hot_packet_parser.dart';

void main() {
  late HotPacketParser parser;

  setUp(() {
    parser = HotPacketParser();
  });

  group('HotPacketParser - isHotPacket', () {
    test('returns true for string starting with |', () {
      expect(parser.isHotPacket('|#01#72#'), true);
    });

    test('returns false for empty string', () {
      expect(parser.isHotPacket(''), false);
    });

    test('returns false for string not starting with |', () {
      expect(parser.isHotPacket('Hello world'), false);
    });

    test('returns true for just |', () {
      expect(parser.isHotPacket('|'), true);
    });
  });

  group('HotPacketParser - parsePacketType', () {
    test('returns 1 for weather packet prefix', () {
      expect(parser.parsePacketType('|#01#data'), 1);
    });

    test('returns 2 for venue/event packet prefix', () {
      expect(parser.parsePacketType('|#02#data'), 2);
    });

    test('returns null for non-HoT packet', () {
      expect(parser.parsePacketType('Hello'), null);
    });

    test('returns null for empty string', () {
      expect(parser.parsePacketType(''), null);
    });

    test('returns null for string too short', () {
      expect(parser.parsePacketType('|#'), null);
    });

    test('returns null when second char is not #', () {
      expect(parser.parsePacketType('|X01#data'), null);
    });
  });

  group('HotPacketParser - parseWeatherPacket', () {
    const validPacket =
        '|#01#72#10am,sunny,75,10.5#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear,74,0.0#';

    test('parses valid weather packet correctly', () {
      final result = parser.parseWeatherPacket(validPacket);
      expect(result, isNotNull);
      expect(result!.currentTemp, 72);
      expect(result.forecasts.length, 4);

      expect(result.forecasts[0].hourLabel, '10am');
      expect(result.forecasts[0].glyphCode, 'sunny');
      expect(result.forecasts[0].temperature, 75);
      expect(result.forecasts[0].precipitation, '10.5');

      expect(result.forecasts[1].hourLabel, '11am');
      expect(result.forecasts[1].glyphCode, 'cloudy');
      expect(result.forecasts[1].temperature, 70);
      expect(result.forecasts[1].precipitation, '25.0');

      expect(result.forecasts[2].hourLabel, '12pm');
      expect(result.forecasts[2].glyphCode, 'rain');
      expect(result.forecasts[2].temperature, 68);
      expect(result.forecasts[2].precipitation, '80.0');

      expect(result.forecasts[3].hourLabel, '1pm');
      expect(result.forecasts[3].glyphCode, 'clear');
      expect(result.forecasts[3].temperature, 74);
      expect(result.forecasts[3].precipitation, '');
    });

    test('replaces 0.0 precipitation with empty string', () {
      const packet =
          '|#01#72#10am,sunny,75,0.0#11am,cloudy,70,0.0#12pm,rain,68,0.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNotNull);
      for (final forecast in result!.forecasts) {
        expect(forecast.precipitation, '');
      }
    });

    test('rejects packet with wrong # delimiter count', () {
      // Only 6 # delimiters instead of 7
      const packet = '|#01#72#10am,sunny,75,10.5#11am,cloudy,70,25.0#12pm,rain,68,80.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with wrong , delimiter count', () {
      // Missing a comma in one forecast section
      const packet =
          '|#01#72#10am,sunny,75,10.5#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with temperature out of range (too high)', () {
      const packet =
          '|#01#1000#10am,sunny,75,10.5#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with temperature out of range (too low)', () {
      const packet =
          '|#01#-100#10am,sunny,75,10.5#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });

    test('accepts boundary temperatures (-99 and 999)', () {
      const packet =
          '|#01#-99#10am,sunny,999,10.5#11am,cloudy,-99,25.0#12pm,rain,0,80.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNotNull);
      expect(result!.currentTemp, -99);
      expect(result.forecasts[0].temperature, 999);
      expect(result.forecasts[1].temperature, -99);
    });

    test('rejects packet with hour label exceeding 6 characters', () {
      const packet =
          '|#01#72#10amXXX,sunny,75,10.5#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with glyph exceeding 10 characters', () {
      const packet =
          '|#01#72#10am,12345678901,75,10.5#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with precipitation out of range', () {
      const packet =
          '|#01#72#10am,sunny,75,101.0#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with negative precipitation', () {
      const packet =
          '|#01#72#10am,sunny,75,-1.0#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with non-integer temperature', () {
      const packet =
          '|#01#72.5#10am,sunny,75,10.5#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with wrong prefix', () {
      const packet =
          '|#02#72#10am,sunny,75,10.5#11am,cloudy,70,25.0#12pm,rain,68,80.0#1pm,clear,74,0.0#';
      final result = parser.parseWeatherPacket(packet);
      expect(result, isNull);
    });
  });

  group('HotPacketParser - parseVenueEventPacket', () {
    test('parses valid venue/event packet with multiple pairs', () {
      const packet = '|#02#Town Square,Jazz Night#Lake Sumter,Karaoke#';
      final result = parser.parseVenueEventPacket(packet);
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0].venueName, 'Town Square');
      expect(result[0].eventName, 'Jazz Night');
      expect(result[1].venueName, 'Lake Sumter');
      expect(result[1].eventName, 'Karaoke');
    });

    test('parses single venue/event pair', () {
      const packet = '|#02#Town Square,Jazz Night#';
      final result = parser.parseVenueEventPacket(packet);
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].venueName, 'Town Square');
      expect(result[0].eventName, 'Jazz Night');
    });

    test('handles event name with commas (splits at first comma only)', () {
      const packet = '|#02#Venue,Event, Part 2, Extra#';
      final result = parser.parseVenueEventPacket(packet);
      expect(result, isNotNull);
      expect(result!.length, 1);
      expect(result[0].venueName, 'Venue');
      expect(result[0].eventName, 'Event, Part 2, Extra');
    });

    test('limits to 12 venue/event pairs', () {
      final pairs = List.generate(15, (i) => 'Venue$i,Event$i').join('#');
      final packet = '|#02#$pairs#';
      final result = parser.parseVenueEventPacket(packet);
      expect(result, isNotNull);
      expect(result!.length, 12);
    });

    test('rejects packet with empty venue name', () {
      const packet = '|#02#,Jazz Night#';
      final result = parser.parseVenueEventPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with empty event name', () {
      const packet = '|#02#Town Square,#';
      final result = parser.parseVenueEventPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with no comma in pair', () {
      const packet = '|#02#Town Square Jazz Night#';
      final result = parser.parseVenueEventPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with wrong prefix', () {
      const packet = '|#01#Town Square,Jazz Night#';
      final result = parser.parseVenueEventPacket(packet);
      expect(result, isNull);
    });

    test('rejects packet with no pairs', () {
      const packet = '|#02#';
      final result = parser.parseVenueEventPacket(packet);
      expect(result, isNull);
    });
  });
}
