import 'package:glados/glados.dart';
import 'package:golf_cart_computer/domain/speed_filter.dart';

/// Custom generators for speed filter property tests.
extension SpeedFilterGenerators on Any {
  /// Generates a raw speed below the dither threshold (0.0 to 2.49).
  Generator<double> get ditherSpeed => doubleInRange(0.0, 2.49);

  /// Generates a valid elapsed time between readings (0.5 to 5.0 seconds).
  Generator<double> get elapsedSeconds => doubleInRange(0.5, 5.0);

  /// Generates a speed above the dither threshold (2.5 to 25.0 mph).
  Generator<double> get movingSpeed => doubleInRange(2.5, 25.0);

  /// Generates a speed in the stop detection zone (2.5 to 3.99 mph).
  Generator<double> get stopDetectionSpeed => doubleInRange(2.5, 3.99);

  /// Generates a moderate base speed for spike rejection tests (5.0 to 15.0 mph).
  Generator<double> get baseSpeed => doubleInRange(5.0, 15.0);
}

void main() {
  group('Property 11: GPS speed filtering pipeline', () {
    // ---------------------------------------------------------------
    // (a) Dither elimination: raw speed < 2.5 mph → filtered speed 0
    // ---------------------------------------------------------------

    /// **Validates: Requirements 5.4**
    ///
    /// For any raw speed below 2.5 mph, the filtered output should be zero
    /// and the vehicle should not be considered moving.
    Glados2(any.ditherSpeed, any.elapsedSeconds).test(
      'dither elimination: raw speed below 2.5 mph maps to zero',
      (rawSpeed, elapsed) {
        final filter = SpeedFilter();
        final result = filter.filter(rawSpeed, elapsed);

        expect(result.filteredSpeedMph, equals(0));
        expect(result.isMoving, isFalse);
        expect(result.wasDiscarded, isFalse);
      },
    );

    // ---------------------------------------------------------------
    // (b) Spike rejection: acceleration > 8 mph/s is discarded
    // ---------------------------------------------------------------

    /// **Validates: Requirements 5.5**
    ///
    /// For any base speed and elapsed time, if the next reading exceeds
    /// 8 mph/s acceleration from the last accepted speed, it should be
    /// discarded.
    Glados2(any.baseSpeed, any.elapsedSeconds).test(
      'spike rejection: acceleration exceeding 8 mph/s is discarded',
      (baseSpeed, elapsed) {
        final filter = SpeedFilter();

        // First, establish a base speed by feeding enough consecutive
        // readings to get past the consecutive threshold.
        filter.filter(baseSpeed, elapsed);
        filter.filter(baseSpeed, elapsed);

        // Now create a spike that exceeds 8 mph/s acceleration.
        // The spike must be > baseSpeed + (8 * elapsed).
        final spikeSpeed = baseSpeed + (8.0 * elapsed) + 1.0;
        final result = filter.filter(spikeSpeed, elapsed);

        expect(result.wasDiscarded, isTrue);
      },
    );

    /// **Validates: Requirements 5.5**
    ///
    /// For any base speed and elapsed time, if the next reading does NOT
    /// exceed 8 mph/s acceleration, it should NOT be discarded.
    Glados2(any.baseSpeed, any.elapsedSeconds).test(
      'spike rejection: acceleration within 8 mph/s is accepted',
      (baseSpeed, elapsed) {
        final filter = SpeedFilter();

        // Establish a base speed.
        filter.filter(baseSpeed, elapsed);
        filter.filter(baseSpeed, elapsed);

        // Create a speed increase that is within the 8 mph/s limit.
        final acceptableSpeed = baseSpeed + (8.0 * elapsed) - 1.0;
        // Only test if the acceptable speed is still above dither threshold
        if (acceptableSpeed < SpeedFilter.ditherThresholdMph) return;

        final result = filter.filter(acceptableSpeed, elapsed);

        expect(result.wasDiscarded, isFalse);
      },
    );

    // ---------------------------------------------------------------
    // (c) Responsive stop detection: speed < 4 mph and decreasing → 0
    // ---------------------------------------------------------------

    /// **Validates: Requirements 5.6**
    ///
    /// When a speed reading is below 4 mph and is decreasing from the
    /// previous reading, the output should be zero.
    Glados(any.stopDetectionSpeed).test(
      'responsive stop detection: speed < 4 mph and decreasing reports zero',
      (speed) {
        final filter = SpeedFilter();

        // Feed a speed in the stop detection zone first.
        // Use a slightly higher speed as the previous reading.
        final higherSpeed = speed + 0.5;
        // Make sure higherSpeed is still below 4 mph for stop detection
        if (higherSpeed >= SpeedFilter.stopDetectionThresholdMph) return;

        filter.filter(higherSpeed, 1.0);

        // Now feed a lower speed (still in the zone).
        final result = filter.filter(speed, 1.0);

        expect(result.filteredSpeedMph, equals(0));
        expect(result.isMoving, isFalse);
      },
    );

    // ---------------------------------------------------------------
    // (d) Consecutive reading threshold: 2 normal, 3 dimmed
    // ---------------------------------------------------------------

    /// **Validates: Requirements 5.7**
    ///
    /// In normal mode, movement is only reported after 2 consecutive
    /// readings above the 2.5 mph threshold.
    Glados2(any.movingSpeed, any.elapsedSeconds).test(
      'consecutive threshold: 1 reading above threshold does not report movement (normal)',
      (speed, elapsed) {
        final filter = SpeedFilter();

        // Ensure speed won't trigger stop detection (must be >= 4 mph)
        if (speed < SpeedFilter.stopDetectionThresholdMph) return;

        final result = filter.filter(speed, elapsed);

        // First reading above threshold should NOT report movement yet.
        expect(result.filteredSpeedMph, equals(0));
        expect(result.isMoving, isFalse);
      },
    );

    /// **Validates: Requirements 5.7**
    ///
    /// In normal mode, 2 consecutive readings above threshold reports movement.
    Glados2(any.movingSpeed, any.elapsedSeconds).test(
      'consecutive threshold: 2 readings above threshold reports movement (normal)',
      (speed, elapsed) {
        final filter = SpeedFilter();

        // Ensure speed won't trigger stop detection
        if (speed < SpeedFilter.stopDetectionThresholdMph) return;

        // Feed two consecutive readings above threshold.
        filter.filter(speed, elapsed);
        final result = filter.filter(speed, elapsed);

        expect(result.filteredSpeedMph, equals(speed.truncate()));
        expect(result.isMoving, isTrue);
      },
    );

    /// **Validates: Requirements 5.7**
    ///
    /// In dimmed mode, 2 consecutive readings above threshold does NOT
    /// report movement (requires 3).
    Glados2(any.movingSpeed, any.elapsedSeconds).test(
      'consecutive threshold: 2 readings above threshold does not report movement (dimmed)',
      (speed, elapsed) {
        final filter = SpeedFilter();

        // Ensure speed won't trigger stop detection
        if (speed < SpeedFilter.stopDetectionThresholdMph) return;

        // Feed two consecutive readings in dimmed mode.
        filter.filter(speed, elapsed, isDimmed: true);
        final result = filter.filter(speed, elapsed, isDimmed: true);

        // In dimmed mode, 2 is not enough - need 3.
        expect(result.filteredSpeedMph, equals(0));
        expect(result.isMoving, isFalse);
      },
    );

    /// **Validates: Requirements 5.7**
    ///
    /// In dimmed mode, 3 consecutive readings above threshold reports movement.
    Glados2(any.movingSpeed, any.elapsedSeconds).test(
      'consecutive threshold: 3 readings above threshold reports movement (dimmed)',
      (speed, elapsed) {
        final filter = SpeedFilter();

        // Ensure speed won't trigger stop detection
        if (speed < SpeedFilter.stopDetectionThresholdMph) return;

        // Feed three consecutive readings in dimmed mode.
        filter.filter(speed, elapsed, isDimmed: true);
        filter.filter(speed, elapsed, isDimmed: true);
        final result = filter.filter(speed, elapsed, isDimmed: true);

        expect(result.filteredSpeedMph, equals(speed.truncate()));
        expect(result.isMoving, isTrue);
      },
    );
  });
}
