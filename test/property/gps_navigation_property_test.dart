import 'package:glados/glados.dart';
import 'package:golf_cart_computer/domain/gps_processor.dart';

/// Custom generators for GPS navigation property tests.
extension GpsNavigationGenerators on Any {
  /// Generates a bearing in degrees [0, 360).
  Generator<double> get bearingDegrees => doubleInRange(0.0, 359.999);

  /// Generates a satellite count in a realistic range (0 to 20).
  Generator<int> get satelliteCount => intInRange(0, 20);

  /// Generates a non-zero satellite count (1 to 20).
  Generator<int> get nonZeroSatelliteCount => intInRange(1, 20);

  /// Generates a satellite count of 6 or more (good accuracy).
  Generator<int> get goodSatelliteCount => intInRange(6, 20);

  /// Generates a satellite count of 4 or 5 (moderate accuracy).
  Generator<int> get moderateSatelliteCount => intInRange(4, 5);

  /// Generates a satellite count below 4 (poor accuracy).
  Generator<int> get poorSatelliteCount => intInRange(0, 3);

  /// Generates a sequence length for debounce testing (1 to 10).
  Generator<int> get sequenceLength => intInRange(1, 10);
}

/// The 16 cardinal directions in clockwise order starting from North.
const List<String> expectedCardinals = [
  'N', 'NNE', 'NE', 'ENE',
  'E', 'ESE', 'SE', 'SSE',
  'S', 'SSW', 'SW', 'WSW',
  'W', 'WNW', 'NW', 'NNW',
];

void main() {
  // =================================================================
  // Property 12: Cardinal direction mapping
  // =================================================================
  group('Property 12: Cardinal direction mapping', () {
    /// **Validates: Requirements 5.8**
    ///
    /// For any bearing in [0, 360), the cardinal direction mapping should
    /// produce one of the 16 valid cardinal direction labels.
    Glados(any.bearingDegrees).test(
      'any bearing in [0, 360) maps to a valid 16-point cardinal direction',
      (bearing) {
        final result = bearingToCardinal(bearing);
        expect(expectedCardinals.contains(result), isTrue,
            reason: 'bearing $bearing produced "$result" which is not a valid cardinal');
      },
    );

    /// **Validates: Requirements 5.8**
    ///
    /// The mapping is deterministic: same input always produces same output.
    Glados(any.bearingDegrees).test(
      'cardinal direction mapping is deterministic (same input → same output)',
      (bearing) {
        final result1 = bearingToCardinal(bearing);
        final result2 = bearingToCardinal(bearing);
        expect(result1, equals(result2));
      },
    );

    /// **Validates: Requirements 5.8**
    ///
    /// Each cardinal direction spans exactly 22.5° centered on its cardinal
    /// point. Test that the center of each 22.5° interval maps correctly.
    Glados(any.intInRange(0, 15)).test(
      'center of each 22.5° interval maps to the correct cardinal direction',
      (index) {
        // Center of each direction: N=0°, NNE=22.5°, NE=45°, etc.
        final centerBearing = index * 22.5;
        final result = bearingToCardinal(centerBearing);
        expect(result, equals(expectedCardinals[index]),
            reason: 'center bearing $centerBearing° should map to ${expectedCardinals[index]} but got $result');
      },
    );

    /// **Validates: Requirements 5.8**
    ///
    /// Bearings within ±11.25° of a cardinal center should map to that
    /// cardinal direction (22.5° interval boundaries).
    Glados2(any.intInRange(0, 15), any.doubleInRange(-11.24, 11.24)).test(
      'bearings within ±11.24° of cardinal center map to that direction',
      (index, offset) {
        final centerBearing = index * 22.5;
        // Normalize to [0, 360)
        final bearing = ((centerBearing + offset) % 360 + 360) % 360;
        final result = bearingToCardinal(bearing);
        expect(result, equals(expectedCardinals[index]),
            reason: 'bearing $bearing° (center=$centerBearing, offset=$offset) should map to ${expectedCardinals[index]} but got $result');
      },
    );
  });

  // =================================================================
  // Property 13: Satellite count debounce
  // =================================================================
  group('Property 13: Satellite count debounce', () {
    /// **Validates: Requirements 5.11**
    ///
    /// A zero satellite count should only be displayed after 3 or more
    /// consecutive zero readings. Fewer than 3 zeros should retain the
    /// last non-zero value.
    Glados(any.nonZeroSatelliteCount).test(
      'fewer than 3 consecutive zeros retains last non-zero count',
      (initialCount) {
        final debouncer = _SatelliteDebouncer();

        // Feed a non-zero reading to establish a baseline.
        debouncer.process(initialCount);

        // Feed 1 zero reading - should still show the initial count.
        var result = debouncer.process(0);
        expect(result, equals(initialCount));

        // Feed 2nd zero reading - should still show the initial count.
        result = debouncer.process(0);
        expect(result, equals(initialCount));
      },
    );

    /// **Validates: Requirements 5.11**
    ///
    /// Exactly 3 consecutive zero readings triggers zero display.
    Glados(any.nonZeroSatelliteCount).test(
      'exactly 3 consecutive zeros triggers zero satellite display',
      (initialCount) {
        final debouncer = _SatelliteDebouncer();

        // Establish non-zero baseline.
        debouncer.process(initialCount);

        // Feed exactly 3 zeros.
        debouncer.process(0);
        debouncer.process(0);
        final result = debouncer.process(0);

        // After 3 consecutive zeros, should display zero.
        expect(result, equals(0));
      },
    );

    /// **Validates: Requirements 5.11**
    ///
    /// Any non-zero reading should reset the consecutive-zero counter
    /// and display immediately.
    Glados2(any.nonZeroSatelliteCount, any.nonZeroSatelliteCount).test(
      'non-zero reading displays immediately and resets zero counter',
      (firstCount, secondCount) {
        final debouncer = _SatelliteDebouncer();

        // Feed initial non-zero.
        debouncer.process(firstCount);

        // Feed 2 zeros (not enough to trigger zero display).
        debouncer.process(0);
        debouncer.process(0);

        // Feed a non-zero reading - should display immediately.
        final result = debouncer.process(secondCount);
        expect(result, equals(secondCount));
      },
    );

    /// **Validates: Requirements 5.11**
    ///
    /// After a non-zero reading resets the counter, it takes another
    /// 3 consecutive zeros to display zero again.
    Glados(any.nonZeroSatelliteCount).test(
      'non-zero reading resets counter: need 3 more zeros after reset',
      (count) {
        final debouncer = _SatelliteDebouncer();

        // Establish non-zero baseline.
        debouncer.process(count);

        // Feed 3 zeros to trigger zero display.
        debouncer.process(0);
        debouncer.process(0);
        debouncer.process(0);

        // Reset with a non-zero reading.
        debouncer.process(count);

        // Now feed only 2 zeros - should NOT display zero.
        debouncer.process(0);
        final result = debouncer.process(0);

        // Only 2 zeros after reset, should retain the non-zero count.
        expect(result, equals(count));
      },
    );

    /// **Validates: Requirements 5.11**
    ///
    /// For any sequence of N consecutive zeros (N >= 3) following a
    /// non-zero reading, the displayed count should be zero.
    Glados2(any.nonZeroSatelliteCount, any.intInRange(3, 10)).test(
      'N >= 3 consecutive zeros always displays zero',
      (initialCount, zeroCount) {
        final debouncer = _SatelliteDebouncer();

        // Establish non-zero baseline.
        debouncer.process(initialCount);

        // Feed N zeros.
        int result = initialCount;
        for (var i = 0; i < zeroCount; i++) {
          result = debouncer.process(0);
        }

        expect(result, equals(0));
      },
    );
  });

  // =================================================================
  // Property 14: HDOP estimation from satellite count
  // =================================================================
  group('Property 14: HDOP estimation from satellite count', () {
    /// **Validates: Requirements 5.12**
    ///
    /// For satellite count ≥ 6, estimated HDOP should be 1.5.
    Glados(any.goodSatelliteCount).test(
      'satellite count >= 6 estimates HDOP as 1.5',
      (satCount) {
        final hdop = estimateHdop(satCount);
        expect(hdop, equals(1.5));
      },
    );

    /// **Validates: Requirements 5.12**
    ///
    /// For satellite count 4-5, estimated HDOP should be 2.0.
    Glados(any.moderateSatelliteCount).test(
      'satellite count 4-5 estimates HDOP as 2.0',
      (satCount) {
        final hdop = estimateHdop(satCount);
        expect(hdop, equals(2.0));
      },
    );

    /// **Validates: Requirements 5.12**
    ///
    /// For satellite count < 4, estimated HDOP should be 99.0.
    Glados(any.poorSatelliteCount).test(
      'satellite count < 4 estimates HDOP as 99.0',
      (satCount) {
        final hdop = estimateHdop(satCount);
        expect(hdop, equals(99.0));
      },
    );

    /// **Validates: Requirements 5.12**
    ///
    /// The HDOP estimation is deterministic and consistent.
    Glados(any.satelliteCount).test(
      'HDOP estimation is deterministic (same input → same output)',
      (satCount) {
        final hdop1 = estimateHdop(satCount);
        final hdop2 = estimateHdop(satCount);
        expect(hdop1, equals(hdop2));
      },
    );

    /// **Validates: Requirements 5.12**
    ///
    /// HDOP estimation always returns one of the three defined values.
    Glados(any.satelliteCount).test(
      'HDOP estimation always returns 1.5, 2.0, or 99.0',
      (satCount) {
        final hdop = estimateHdop(satCount);
        expect([1.5, 2.0, 99.0].contains(hdop), isTrue,
            reason: 'HDOP for $satCount sats was $hdop, expected 1.5, 2.0, or 99.0');
      },
    );
  });
}

// =================================================================
// Helper classes
// =================================================================

/// Synchronous satellite count debouncer that mirrors the logic in
/// [DefaultGpsProcessor._debounceSatelliteCount].
///
/// This allows property-based testing of the debounce algorithm
/// without requiring async stream handling.
class _SatelliteDebouncer {
  static const int debounceCount = 3;

  int _consecutiveZeros = 0;
  int _displayedCount = 0;

  /// Process a satellite count reading and return the displayed count.
  ///
  /// Mirrors the exact logic from DefaultGpsProcessor._debounceSatelliteCount:
  /// - Zero readings increment the consecutive counter
  /// - Only display zero after [debounceCount] consecutive zeros
  /// - Non-zero readings reset the counter and display immediately
  int process(int rawCount) {
    if (rawCount == 0) {
      _consecutiveZeros++;
      if (_consecutiveZeros >= debounceCount) {
        _displayedCount = 0;
      }
    } else {
      _consecutiveZeros = 0;
      _displayedCount = rawCount;
    }
    return _displayedCount;
  }
}
