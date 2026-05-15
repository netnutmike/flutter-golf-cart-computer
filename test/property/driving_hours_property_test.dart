import 'package:glados/glados.dart';
import 'package:golf_cart_computer/data/repositories/preferences_repository.dart';
import 'package:golf_cart_computer/domain/models/odometer_state.dart';
import 'package:golf_cart_computer/domain/models/user_preferences.dart';
import 'package:golf_cart_computer/domain/service_reminder_manager.dart';

/// A simple in-memory fake [PreferencesRepository] for property testing.
///
/// Avoids mocking to keep property tests simple and focused on domain logic.
class FakePreferencesRepository implements PreferencesRepository {
  double _drivingHours = 0.0;

  @override
  Future<double> loadDrivingHours() async => _drivingHours;

  @override
  Future<void> persistDrivingHours(double tenthsOfHours) async {
    _drivingHours = tenthsOfHours;
  }

  @override
  Future<UserPreferences> loadPreferences() async => UserPreferences.defaults;

  @override
  Future<void> savePreference(String key, dynamic value) async {}

  @override
  Future<void> resetAllPreferences() async {}

  @override
  Future<void> persistOdometer(double totalMiles, double tripMiles) async {}

  @override
  Future<OdometerState> loadOdometer() async =>
      const OdometerState(totalMiles: 0.0, tripMiles: 0.0, hoursSinceService: 0.0);
}

/// Custom generators for driving hours property tests.
extension DrivingHoursGenerators on Any {
  /// Generates a valid time delta (> 0 and ≤ 10 seconds).
  Generator<double> get validDelta => doubleInRange(0.01, 10.0);

  /// Generates an invalid time delta that is zero or negative.
  Generator<double> get zeroOrNegativeDelta => doubleInRange(-100.0, 0.0);

  /// Generates an invalid time delta that exceeds 10 seconds.
  Generator<double> get tooLargeDelta => doubleInRange(10.01, 1000.0);

  /// Generates a sequence length for multiple accumulations.
  Generator<int> get sequenceLength => intInRange(1, 20);
}

void main() {
  group('Property 17: Driving hours accumulation gating', () {
    // ---------------------------------------------------------------
    // Hours accumulate ONLY when isMoving=true AND delta > 0 AND delta ≤ 10
    // ---------------------------------------------------------------

    /// **Validates: Requirements 7.1, 7.5**
    ///
    /// For any valid time delta (> 0 and ≤ 10 seconds) when the vehicle
    /// is moving, driving hours should increase.
    Glados(any.validDelta).test(
      'hours accumulate when moving with valid delta',
      (delta) {
        final manager = DefaultServiceReminderManager(
          preferencesRepository: FakePreferencesRepository(),
        );

        final hoursBefore = manager.currentHoursTenths;
        manager.accumulateTime(delta, true);
        final hoursAfter = manager.currentHoursTenths;

        expect(hoursAfter, greaterThan(hoursBefore),
            reason: 'Hours should increase when moving with valid delta $delta');
      },
    );

    /// **Validates: Requirements 7.1, 7.5**
    ///
    /// For any valid time delta when the vehicle is NOT moving (speed = 0),
    /// driving hours should NOT accumulate.
    Glados(any.validDelta).test(
      'hours do not accumulate when not moving',
      (delta) {
        final manager = DefaultServiceReminderManager(
          preferencesRepository: FakePreferencesRepository(),
        );

        final hoursBefore = manager.currentHoursTenths;
        manager.accumulateTime(delta, false);
        final hoursAfter = manager.currentHoursTenths;

        expect(hoursAfter, equals(hoursBefore),
            reason: 'Hours should not change when not moving');
      },
    );

    // ---------------------------------------------------------------
    // Deltas outside valid range are discarded
    // ---------------------------------------------------------------

    /// **Validates: Requirements 7.5**
    ///
    /// For any time delta that is zero or negative, hours should not
    /// accumulate even when the vehicle is moving.
    Glados(any.zeroOrNegativeDelta).test(
      'zero or negative deltas are discarded',
      (delta) {
        final manager = DefaultServiceReminderManager(
          preferencesRepository: FakePreferencesRepository(),
        );

        final hoursBefore = manager.currentHoursTenths;
        manager.accumulateTime(delta, true);
        final hoursAfter = manager.currentHoursTenths;

        expect(hoursAfter, equals(hoursBefore),
            reason: 'Hours should not change with delta $delta (zero or negative)');
      },
    );

    /// **Validates: Requirements 7.5**
    ///
    /// For any time delta exceeding 10 seconds, hours should not
    /// accumulate even when the vehicle is moving.
    Glados(any.tooLargeDelta).test(
      'deltas exceeding 10 seconds are discarded',
      (delta) {
        final manager = DefaultServiceReminderManager(
          preferencesRepository: FakePreferencesRepository(),
        );

        final hoursBefore = manager.currentHoursTenths;
        manager.accumulateTime(delta, true);
        final hoursAfter = manager.currentHoursTenths;

        expect(hoursAfter, equals(hoursBefore),
            reason: 'Hours should not change with delta $delta (exceeds 10s)');
      },
    );

    // ---------------------------------------------------------------
    // Accumulation correctness: amount matches expected conversion
    // ---------------------------------------------------------------

    /// **Validates: Requirements 7.1, 7.5**
    ///
    /// For any sequence of valid deltas while moving, the total accumulated
    /// hours should equal the sum of all deltas converted to tenths of hours.
    /// (1 tenth of hour = 360 seconds)
    Glados2(any.sequenceLength, any.validDelta).test(
      'accumulated hours equal sum of valid deltas converted to tenths',
      (count, delta) {
        final manager = DefaultServiceReminderManager(
          preferencesRepository: FakePreferencesRepository(),
        );

        for (var i = 0; i < count; i++) {
          manager.accumulateTime(delta, true);
        }

        final expectedTenths = (delta / 360.0) * count;
        expect(manager.currentHoursTenths, closeTo(expectedTenths, 1e-10),
            reason: 'Accumulated tenths should match sum of conversions');
      },
    );

    /// **Validates: Requirements 7.1, 7.5**
    ///
    /// For any mix of moving and stationary calls with valid deltas,
    /// only the moving calls should contribute to accumulated hours.
    Glados(any.validDelta).test(
      'only moving calls contribute to accumulation',
      (delta) {
        final manager = DefaultServiceReminderManager(
          preferencesRepository: FakePreferencesRepository(),
        );

        // Accumulate while moving
        manager.accumulateTime(delta, true);
        final afterMoving = manager.currentHoursTenths;

        // Try to accumulate while stationary - should not change
        manager.accumulateTime(delta, false);
        final afterStationary = manager.currentHoursTenths;

        expect(afterStationary, equals(afterMoving),
            reason: 'Stationary calls should not add to accumulated hours');

        // Accumulate while moving again
        manager.accumulateTime(delta, true);
        final afterMovingAgain = manager.currentHoursTenths;

        expect(afterMovingAgain, greaterThan(afterMoving),
            reason: 'Moving calls after stationary should still accumulate');
      },
    );
  });
}
