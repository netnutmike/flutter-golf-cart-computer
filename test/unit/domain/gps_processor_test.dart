import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/domain/gps_processor.dart';
import 'package:golf_cart_computer/domain/models/gps_data.dart';

void main() {
  group('bearingToCardinal', () {
    test('converts 0° to N', () {
      expect(bearingToCardinal(0), 'N');
    });

    test('converts 360° to N (wraps)', () {
      expect(bearingToCardinal(360), 'N');
    });

    test('converts 90° to E', () {
      expect(bearingToCardinal(90), 'E');
    });

    test('converts 180° to S', () {
      expect(bearingToCardinal(180), 'S');
    });

    test('converts 270° to W', () {
      expect(bearingToCardinal(270), 'W');
    });

    test('converts 45° to NE', () {
      expect(bearingToCardinal(45), 'NE');
    });

    test('converts 135° to SE', () {
      expect(bearingToCardinal(135), 'SE');
    });

    test('converts 225° to SW', () {
      expect(bearingToCardinal(225), 'SW');
    });

    test('converts 315° to NW', () {
      expect(bearingToCardinal(315), 'NW');
    });

    test('converts 22.5° to NNE', () {
      expect(bearingToCardinal(22.5), 'NNE');
    });

    test('converts 11.24° to N (just below boundary)', () {
      expect(bearingToCardinal(11.24), 'N');
    });

    test('converts 11.26° to NNE (just above boundary)', () {
      expect(bearingToCardinal(11.26), 'NNE');
    });

    test('converts 348.75° to N (lower boundary)', () {
      expect(bearingToCardinal(348.75), 'N');
    });

    test('handles negative bearing by normalizing', () {
      expect(bearingToCardinal(-90), 'W');
    });

    test('handles bearing > 360 by normalizing', () {
      expect(bearingToCardinal(450), 'E');
    });
  });

  group('estimateHdop', () {
    test('returns 1.5 for 6 satellites', () {
      expect(estimateHdop(6), 1.5);
    });

    test('returns 1.5 for 10 satellites', () {
      expect(estimateHdop(10), 1.5);
    });

    test('returns 2.0 for 5 satellites', () {
      expect(estimateHdop(5), 2.0);
    });

    test('returns 2.0 for 4 satellites', () {
      expect(estimateHdop(4), 2.0);
    });

    test('returns 99.0 for 3 satellites', () {
      expect(estimateHdop(3), 99.0);
    });

    test('returns 99.0 for 0 satellites', () {
      expect(estimateHdop(0), 99.0);
    });
  });

  group('DefaultGpsProcessor', () {
    late DefaultGpsProcessor processor;

    setUp(() {
      processor = DefaultGpsProcessor();
    });

    tearDown(() {
      processor.dispose();
    });

    group('satellite count debounce', () {
      test('displays non-zero satellite count immediately', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(_makePosition(satelliteCount: 8));
        await Future<void>.delayed(Duration.zero);

        expect(results.last.satelliteCount, 8);
      });

      test('retains last non-zero count after 1 zero reading', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(_makePosition(satelliteCount: 8));
        await Future<void>.delayed(Duration.zero);
        processor.processRawPosition(_makePosition(satelliteCount: 0));
        await Future<void>.delayed(Duration.zero);

        expect(results.last.satelliteCount, 8);
      });

      test('retains last non-zero count after 2 zero readings', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(_makePosition(satelliteCount: 8));
        await Future<void>.delayed(Duration.zero);
        processor.processRawPosition(_makePosition(satelliteCount: 0));
        await Future<void>.delayed(Duration.zero);
        processor.processRawPosition(_makePosition(satelliteCount: 0));
        await Future<void>.delayed(Duration.zero);

        expect(results.last.satelliteCount, 8);
      });

      test('displays zero after 3 consecutive zero readings', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(_makePosition(satelliteCount: 8));
        await Future<void>.delayed(Duration.zero);
        processor.processRawPosition(_makePosition(satelliteCount: 0));
        await Future<void>.delayed(Duration.zero);
        processor.processRawPosition(_makePosition(satelliteCount: 0));
        await Future<void>.delayed(Duration.zero);
        processor.processRawPosition(_makePosition(satelliteCount: 0));
        await Future<void>.delayed(Duration.zero);

        expect(results.last.satelliteCount, 0);
      });

      test('resets counter on non-zero reading', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(_makePosition(satelliteCount: 8));
        await Future<void>.delayed(Duration.zero);
        processor.processRawPosition(_makePosition(satelliteCount: 0));
        await Future<void>.delayed(Duration.zero);
        processor.processRawPosition(_makePosition(satelliteCount: 0));
        await Future<void>.delayed(Duration.zero);
        // Non-zero resets the counter
        processor.processRawPosition(_makePosition(satelliteCount: 5));
        await Future<void>.delayed(Duration.zero);
        processor.processRawPosition(_makePosition(satelliteCount: 0));
        await Future<void>.delayed(Duration.zero);

        // Should still show 5 (only 1 zero after reset)
        expect(results.last.satelliteCount, 5);
      });
    });

    group('HDOP estimation', () {
      test('uses provided HDOP when available', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(
          _makePosition(satelliteCount: 8, hdop: 0.9),
        );
        await Future<void>.delayed(Duration.zero);

        expect(results.last.hdop, 0.9);
      });

      test('estimates HDOP when not provided', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(
          _makePosition(satelliteCount: 8, hdop: null),
        );
        await Future<void>.delayed(Duration.zero);

        expect(results.last.hdop, 1.5);
      });
    });

    group('heading conversion', () {
      test('emits correct cardinal direction', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(
          _makePosition(headingDegrees: 45),
        );
        await Future<void>.delayed(Duration.zero);

        expect(results.last.cardinalDirection, 'NE');
      });
    });

    group('dual GPS source', () {
      test('uses device GPS as primary source', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(
          _makePosition(latitude: 28.9, longitude: -81.9, satelliteCount: 8),
        );
        await Future<void>.delayed(Duration.zero);

        expect(results.last.latitude, 28.9);
      });

      test('uses Meshtastic as fallback when device GPS unavailable',
          () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        // Device GPS reports invalid (0 satellites)
        processor.processRawPosition(
          _makePosition(
            latitude: 0,
            longitude: 0,
            satelliteCount: 0,
            isValid: false,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Meshtastic position should be accepted
        processor.processMeshtasticPosition(MeshtasticPosition(
          latitude: 28.9,
          longitude: -81.9,
          altitude: 30,
          speedMph: 10,
          headingDegrees: 90,
          satelliteCount: 6,
          timestamp: DateTime.now().toUtc(),
        ));
        await Future<void>.delayed(Duration.zero);

        expect(results.last.latitude, 28.9);
      });

      test('ignores Meshtastic when device GPS is valid', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        // Device GPS is valid
        processor.processRawPosition(
          _makePosition(latitude: 28.9, longitude: -81.9, satelliteCount: 8),
        );
        await Future<void>.delayed(Duration.zero);

        // Meshtastic position should be ignored
        processor.processMeshtasticPosition(MeshtasticPosition(
          latitude: 30.0,
          longitude: -80.0,
          altitude: 30,
          speedMph: 10,
          headingDegrees: 90,
          satelliteCount: 6,
          timestamp: DateTime.now().toUtc(),
        ));
        await Future<void>.delayed(Duration.zero);

        // Should still show device GPS position
        expect(results.last.latitude, 28.9);
      });
    });

    group('speed filtering integration', () {
      test('filters low speeds to zero via SpeedFilter', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(_makePosition(speedMph: 1.5));
        await Future<void>.delayed(Duration.zero);

        expect(results.last.speedMph, 0);
      });

      test('preserves raw speed in output', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        processor.processRawPosition(_makePosition(speedMph: 1.5));
        await Future<void>.delayed(Duration.zero);

        expect(results.last.rawSpeedMph, 1.5);
      });
    });

    group('invalid speed handling', () {
      test('reports zero when last speed < 5 mph and speed invalid', () async {
        final results = <ProcessedGpsData>[];
        processor.gpsState.listen(results.add);

        // First establish a low speed
        processor.processRawPosition(_makePosition(speedMph: 3.0));
        await Future<void>.delayed(Duration.zero);

        // Now send invalid speed (-1 indicates invalid)
        processor.processRawPosition(
          _makePosition(speedMph: -1, isSpeedValid: false),
        );
        await Future<void>.delayed(Duration.zero);

        expect(results.last.speedMph, 0);
      });
    });

    group('navigation data', () {
      test('emits navigation data with date and time', () async {
        final results = <NavigationData>[];
        processor.navigationData.listen(results.add);

        final timestamp = DateTime.utc(2024, 1, 15, 19, 30, 0);
        processor.processRawPosition(
          _makePosition(
            latitude: 28.9,
            longitude: -81.9,
            timestamp: timestamp,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(results.last.dateString, isNotEmpty);
        expect(results.last.timeString, isNotEmpty);
        expect(results.last.sunriseTime, isNotEmpty);
        expect(results.last.sunsetTime, isNotEmpty);
      });

      test('emits isDaytime based on sunrise/sunset', () async {
        final results = <NavigationData>[];
        processor.navigationData.listen(results.add);

        // Noon UTC on Jan 15 - should be daytime in Florida
        final timestamp = DateTime.utc(2024, 1, 15, 17, 0, 0);
        processor.processRawPosition(
          _makePosition(
            latitude: 28.9,
            longitude: -81.9,
            timestamp: timestamp,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(results.last.isDaytime, isTrue);
      });
    });
  });

  group('calculateSunriseSunset', () {
    test('returns reasonable sunrise/sunset for Florida in January', () {
      final result = calculateSunriseSunset(
        latitude: 28.9,
        longitude: -81.9,
        date: DateTime(2024, 1, 15),
      );

      // Sunrise in Florida in January is around 7:15 AM local
      expect(result.sunrise.hour, inInclusiveRange(6, 8));
      // Sunset in Florida in January is around 5:45 PM local
      expect(result.sunset.hour, inInclusiveRange(17, 19));
      // Sunset should be after sunrise
      expect(result.sunset.isAfter(result.sunrise), isTrue);
    });

    test('returns reasonable sunrise/sunset for equator', () {
      final result = calculateSunriseSunset(
        latitude: 0,
        longitude: 0,
        date: DateTime(2024, 3, 20), // Equinox
      );

      // Near equinox at equator with longitude 0, sunrise ~6 AM UTC,
      // sunset ~6 PM UTC. Convert back to UTC for timezone-independent check.
      final sunriseUtc = result.sunrise.toUtc();
      final sunsetUtc = result.sunset.toUtc();
      expect(sunriseUtc.hour, inInclusiveRange(5, 7));
      expect(sunsetUtc.hour, inInclusiveRange(17, 19));
    });
  });
}

/// Helper to create a RawPosition with sensible defaults.
RawPosition _makePosition({
  double latitude = 28.9,
  double longitude = -81.9,
  double altitude = 30,
  double speedMph = 0,
  double headingDegrees = 0,
  int satelliteCount = 8,
  double? hdop = 1.5,
  DateTime? timestamp,
  bool isValid = true,
  bool isSpeedValid = true,
}) {
  // If speed is marked invalid, use a negative value to signal it
  final actualSpeed = isSpeedValid ? speedMph : -1.0;
  return RawPosition(
    latitude: latitude,
    longitude: longitude,
    altitude: altitude,
    speedMph: actualSpeed,
    headingDegrees: headingDegrees,
    satelliteCount: satelliteCount,
    hdop: hdop,
    timestamp: timestamp ?? DateTime.now().toUtc(),
    isValid: isValid,
  );
}
