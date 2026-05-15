import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/domain/speed_filter.dart';

void main() {
  late SpeedFilter filter;

  setUp(() {
    filter = SpeedFilter();
  });

  group('SpeedFilter - Dither Elimination', () {
    test('speed below 2.5 mph returns zero', () {
      final result = filter.filter(2.0, 1.0);
      expect(result.filteredSpeedMph, 0);
      expect(result.isMoving, false);
      expect(result.wasDiscarded, false);
    });

    test('speed of 0.0 mph returns zero', () {
      final result = filter.filter(0.0, 1.0);
      expect(result.filteredSpeedMph, 0);
      expect(result.isMoving, false);
    });

    test('speed of 2.49 mph returns zero', () {
      final result = filter.filter(2.49, 1.0);
      expect(result.filteredSpeedMph, 0);
      expect(result.isMoving, false);
    });

    test('speed exactly at 2.5 mph is not filtered as dither', () {
      // First reading above threshold - not yet moving (need 2 consecutive)
      final result = filter.filter(2.5, 1.0);
      // Not yet moving because we need 2 consecutive readings
      expect(result.filteredSpeedMph, 0);
      expect(result.isMoving, false);
    });
  });

  group('SpeedFilter - Spike Rejection', () {
    test('spike exceeding 8 mph/s is discarded', () {
      // Establish a baseline speed
      filter.filter(5.0, 1.0); // first reading
      filter.filter(5.0, 1.0); // second reading - now moving

      // Spike: 5 → 20 in 1 second = 15 mph/s acceleration
      final result = filter.filter(20.0, 1.0);
      expect(result.wasDiscarded, true);
      expect(result.filteredSpeedMph, 5); // retains last accepted
    });

    test('acceleration within 8 mph/s is accepted', () {
      // Establish baseline
      filter.filter(5.0, 1.0);
      filter.filter(5.0, 1.0); // now moving at 5

      // 5 → 12 in 1 second = 7 mph/s (within limit)
      final result = filter.filter(12.0, 1.0);
      expect(result.wasDiscarded, false);
      expect(result.filteredSpeedMph, 12);
      expect(result.isMoving, true);
    });

    test('spike rejection considers elapsed time', () {
      // Establish baseline
      filter.filter(5.0, 1.0);
      filter.filter(5.0, 1.0); // now moving at 5

      // 5 → 21 in 2 seconds = 8 mph/s (exactly at limit, not exceeding)
      final result = filter.filter(21.0, 2.0);
      expect(result.wasDiscarded, false);
    });

    test('spike rejection with short elapsed time', () {
      // Establish baseline
      filter.filter(5.0, 1.0);
      filter.filter(5.0, 1.0); // now moving at 5

      // 5 → 10 in 0.5 seconds = 10 mph/s (exceeds limit)
      final result = filter.filter(10.0, 0.5);
      expect(result.wasDiscarded, true);
      expect(result.filteredSpeedMph, 5);
    });
  });

  group('SpeedFilter - Responsive Stop Detection', () {
    test('speed below 4 mph and decreasing reports zero', () {
      // Establish a previous reading above the stop detection threshold
      filter.filter(5.0, 1.0);
      filter.filter(5.0, 1.0); // now moving

      // Speed drops to 3.5 (below 4, and decreasing from 5)
      final result = filter.filter(3.5, 1.0);
      expect(result.filteredSpeedMph, 0);
      expect(result.isMoving, false);
    });

    test('speed below 4 mph but increasing does not trigger stop detection', () {
      // First reading at 2.6 (above dither, below stop threshold)
      filter.filter(2.6, 1.0);
      // Second reading at 3.0 (increasing, below 4 mph)
      final result = filter.filter(3.0, 1.0);
      // Should not trigger stop detection because it's increasing
      // It's the 2nd consecutive reading above threshold, so should report movement
      expect(result.filteredSpeedMph, 3);
      expect(result.isMoving, true);
    });

    test('speed at exactly 4 mph and decreasing does not trigger stop detection', () {
      // Establish baseline
      filter.filter(5.0, 1.0);
      filter.filter(5.0, 1.0); // now moving at 5

      // 4.0 is not < 4.0, so stop detection should not trigger
      final result = filter.filter(4.0, 1.0);
      expect(result.filteredSpeedMph, 4);
      expect(result.isMoving, true);
    });
  });

  group('SpeedFilter - Consecutive Reading Threshold', () {
    test('requires 2 consecutive readings above threshold in normal mode', () {
      // First reading above threshold
      final result1 = filter.filter(5.0, 1.0);
      expect(result1.filteredSpeedMph, 0);
      expect(result1.isMoving, false);

      // Second reading above threshold - now reports movement
      final result2 = filter.filter(5.0, 1.0);
      expect(result2.filteredSpeedMph, 5);
      expect(result2.isMoving, true);
    });

    test('requires 3 consecutive readings above threshold when dimmed', () {
      // First reading
      final result1 = filter.filter(5.0, 1.0, isDimmed: true);
      expect(result1.filteredSpeedMph, 0);
      expect(result1.isMoving, false);

      // Second reading
      final result2 = filter.filter(5.0, 1.0, isDimmed: true);
      expect(result2.filteredSpeedMph, 0);
      expect(result2.isMoving, false);

      // Third reading - now reports movement
      final result3 = filter.filter(5.0, 1.0, isDimmed: true);
      expect(result3.filteredSpeedMph, 5);
      expect(result3.isMoving, true);
    });

    test('consecutive counter resets when speed drops below threshold', () {
      // First reading above threshold
      filter.filter(5.0, 1.0);

      // Drop below threshold - resets counter
      filter.filter(1.0, 1.0);

      // Start again - need 2 more consecutive
      final result1 = filter.filter(5.0, 1.0);
      expect(result1.filteredSpeedMph, 0);
      expect(result1.isMoving, false);

      final result2 = filter.filter(5.0, 1.0);
      expect(result2.filteredSpeedMph, 5);
      expect(result2.isMoving, true);
    });
  });

  group('SpeedFilter - Reset', () {
    test('reset clears all state', () {
      // Build up some state
      filter.filter(5.0, 1.0);
      filter.filter(5.0, 1.0); // now moving

      // Reset
      filter.reset();

      // After reset, need 2 consecutive readings again
      final result1 = filter.filter(5.0, 1.0);
      expect(result1.filteredSpeedMph, 0);
      expect(result1.isMoving, false);

      final result2 = filter.filter(5.0, 1.0);
      expect(result2.filteredSpeedMph, 5);
      expect(result2.isMoving, true);
    });

    test('reset clears spike rejection baseline', () {
      // Establish baseline
      filter.filter(5.0, 1.0);
      filter.filter(5.0, 1.0);

      filter.reset();

      // After reset, no previous speed to compare against
      // So a high speed should not be rejected as a spike
      final result1 = filter.filter(20.0, 1.0);
      expect(result1.wasDiscarded, false);
      // Still needs 2 consecutive readings
      expect(result1.filteredSpeedMph, 0);

      final result2 = filter.filter(20.0, 1.0);
      expect(result2.filteredSpeedMph, 20);
      expect(result2.isMoving, true);
    });
  });

  group('SpeedFilter - FilterResult', () {
    test('equality works correctly', () {
      const a = FilterResult(
        filteredSpeedMph: 5,
        isMoving: true,
        wasDiscarded: false,
      );
      const b = FilterResult(
        filteredSpeedMph: 5,
        isMoving: true,
        wasDiscarded: false,
      );
      expect(a, equals(b));
    });

    test('inequality when values differ', () {
      const a = FilterResult(
        filteredSpeedMph: 5,
        isMoving: true,
        wasDiscarded: false,
      );
      const b = FilterResult(
        filteredSpeedMph: 6,
        isMoving: true,
        wasDiscarded: false,
      );
      expect(a, isNot(equals(b)));
    });

    test('toString provides useful output', () {
      const result = FilterResult(
        filteredSpeedMph: 10,
        isMoving: true,
        wasDiscarded: false,
      );
      expect(
        result.toString(),
        'FilterResult(filteredSpeedMph: 10, isMoving: true, wasDiscarded: false)',
      );
    });
  });
}
