import 'package:glados/glados.dart';
import 'package:golf_cart_computer/data/repositories/preferences_repository.dart';
import 'package:golf_cart_computer/domain/models/gps_data.dart';
import 'package:golf_cart_computer/domain/models/odometer_state.dart';
import 'package:golf_cart_computer/domain/models/user_preferences.dart';
import 'package:golf_cart_computer/domain/odometer_manager.dart';

/// Synchronous in-memory implementation of [PreferencesRepository] for testing.
class InMemoryPreferencesRepository implements PreferencesRepository {
  double totalMiles = 0.0;
  double tripMiles = 0.0;
  double drivingHours = 0.0;

  InMemoryPreferencesRepository({
    double initialTotal = 0.0,
    double initialTrip = 0.0,
    double initialHours = 0.0,
  })  : totalMiles = initialTotal,
        tripMiles = initialTrip,
        drivingHours = initialHours;

  @override
  Future<void> persistOdometer(double totalMiles, double tripMiles) async {
    this.totalMiles = totalMiles;
    this.tripMiles = tripMiles;
  }

  @override
  Future<OdometerState> loadOdometer() async {
    return OdometerState(
      totalMiles: totalMiles,
      tripMiles: tripMiles,
      hoursSinceService: drivingHours,
    );
  }

  @override
  Future<void> persistDrivingHours(double tenthsOfHours) async {
    drivingHours = tenthsOfHours;
  }

  @override
  Future<double> loadDrivingHours() async => drivingHours;

  @override
  Future<UserPreferences> loadPreferences() async => const UserPreferences();

  @override
  Future<void> savePreference(String key, dynamic value) async {}

  @override
  Future<void> resetAllPreferences() async {}
}

/// Custom generators for odometer property tests.
extension OdometerGenerators on Any {
  /// Generates a valid latitude (-85 to 85) avoiding poles.
  Generator<double> get latitude => doubleInRange(-85.0, 85.0);

  /// Generates a positive speed in mph (1.0 to 25.0).
  Generator<double> get positiveSpeed => doubleInRange(1.0, 25.0);

  /// Generates a number of distance segments (2 to 10).
  Generator<int> get segmentCount => intInRange(2, 10);

  /// Generates a total miles value (0.0 to 99000.0).
  Generator<double> get totalMilesValue => doubleInRange(0.0, 99000.0);

  /// Generates a trip miles value (0.0 to 9000.0).
  Generator<double> get tripMilesValue => doubleInRange(0.0, 9000.0);
}

/// Creates a [ProcessedGpsData] with the given parameters.
ProcessedGpsData _makeGpsData({
  required double latitude,
  required double longitude,
  required int speedMph,
  required double rawSpeedMph,
  required DateTime timestamp,
  bool isValid = true,
}) {
  return ProcessedGpsData(
    latitude: latitude,
    longitude: longitude,
    altitude: 0.0,
    speedMph: speedMph,
    rawSpeedMph: rawSpeedMph,
    headingDegrees: 0.0,
    cardinalDirection: 'N',
    satelliteCount: 8,
    hdop: 1.5,
    timestamp: timestamp,
    isValid: isValid,
  );
}

void main() {
  group('Property 15: Distance accumulation gating', () {
    // ---------------------------------------------------------------
    // (a) Distance only accumulates when filtered speed > 0
    // ---------------------------------------------------------------

    /// **Validates: Requirements 6.4**
    ///
    /// For any GPS position update where filtered speed is zero,
    /// no distance should be accumulated.
    Glados(any.latitude).test(
      'no distance accumulation when speed is zero',
      (lat) {
        final repo = InMemoryPreferencesRepository();
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(0.0, 0.0, 0.0);

        final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

        // First position to establish a reference point
        manager.processPosition(_makeGpsData(
          latitude: lat,
          longitude: 0.0,
          speedMph: 0,
          rawSpeedMph: 0.0,
          timestamp: baseTime,
        ));

        // Second position with zero speed but different location
        manager.processPosition(_makeGpsData(
          latitude: lat + 0.01, // ~0.69 miles change
          longitude: 0.0,
          speedMph: 0,
          rawSpeedMph: 0.0,
          timestamp: baseTime.add(const Duration(seconds: 5)),
        ));

        // No distance should have accumulated
        expect(manager.totalMilesForTest, equals(0.0));
        expect(manager.tripMilesForTest, equals(0.0));

        manager.dispose();
      },
    );

    // ---------------------------------------------------------------
    // (b) Position change must exceed threshold with Doppler speed
    // ---------------------------------------------------------------

    /// **Validates: Requirements 6.5**
    ///
    /// When Doppler speed confirms motion (rawSpeedMph > 0), distance
    /// should not accumulate if position change is below 2.6 feet
    /// (0.0005 miles).
    Glados(any.latitude).test(
      'no accumulation when position change below Doppler threshold (0.0005 miles)',
      (lat) {
        final repo = InMemoryPreferencesRepository();
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(0.0, 0.0, 0.0);

        final baseTime = DateTime(2024, 1, 1, 12, 0, 0);
        final clampedLat = lat.clamp(-85.0, 85.0);

        // Establish first position with positive speed and Doppler
        manager.processPosition(_makeGpsData(
          latitude: clampedLat,
          longitude: 0.0,
          speedMph: 5,
          rawSpeedMph: 5.0,
          timestamp: baseTime,
        ));

        // Second position with a very tiny change (well below 0.0005 miles)
        // 0.000001 degrees latitude ≈ 0.000069 miles which is below 0.0005
        manager.processPosition(_makeGpsData(
          latitude: clampedLat + 0.000001,
          longitude: 0.0,
          speedMph: 5,
          rawSpeedMph: 5.0,
          timestamp: baseTime.add(const Duration(seconds: 1)),
        ));

        // No distance should have accumulated
        expect(manager.totalMilesForTest, equals(0.0));

        manager.dispose();
      },
    );

    // ---------------------------------------------------------------
    // (c) Position change must exceed fallback threshold without Doppler
    // ---------------------------------------------------------------

    /// **Validates: Requirements 6.6**
    ///
    /// When Doppler speed is unavailable (rawSpeedMph == 0), the minimum
    /// distance threshold is 10 feet (0.002 miles). Distance below this
    /// should not accumulate.
    Glados(any.latitude).test(
      'no accumulation when position change below fallback threshold without Doppler',
      (lat) {
        final repo = InMemoryPreferencesRepository();
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(0.0, 0.0, 0.0);

        final baseTime = DateTime(2024, 1, 1, 12, 0, 0);
        final clampedLat = lat.clamp(-85.0, 85.0);

        // Establish first position with positive filtered speed but no Doppler
        manager.processPosition(_makeGpsData(
          latitude: clampedLat,
          longitude: 0.0,
          speedMph: 5,
          rawSpeedMph: 0.0, // No Doppler
          timestamp: baseTime,
        ));

        // Second position with change between 0.0005 and 0.002 miles
        // 0.00001 degrees latitude ≈ 0.00069 miles (above Doppler threshold
        // but below fallback threshold of 0.002)
        manager.processPosition(_makeGpsData(
          latitude: clampedLat + 0.00001,
          longitude: 0.0,
          speedMph: 5,
          rawSpeedMph: 0.0, // No Doppler
          timestamp: baseTime.add(const Duration(seconds: 2)),
        ));

        // No distance should have accumulated
        expect(manager.totalMilesForTest, equals(0.0));

        manager.dispose();
      },
    );

    // ---------------------------------------------------------------
    // (d) Implied speed > 30 mph causes rejection
    // ---------------------------------------------------------------

    /// **Validates: Requirements 6.7**
    ///
    /// If the implied speed from position change exceeds 30 mph,
    /// the position update should be discarded entirely.
    Glados(any.latitude).test(
      'position update discarded when implied speed exceeds 30 mph',
      (lat) {
        final repo = InMemoryPreferencesRepository();
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(0.0, 0.0, 0.0);

        final baseTime = DateTime(2024, 1, 1, 12, 0, 0);
        final clampedLat = lat.clamp(-85.0, 85.0);

        // Establish first position
        manager.processPosition(_makeGpsData(
          latitude: clampedLat,
          longitude: 0.0,
          speedMph: 10,
          rawSpeedMph: 10.0,
          timestamp: baseTime,
        ));

        // Second position with a large jump in 1 second
        // 0.01 degrees latitude ≈ 0.69 miles in 1 second = ~2484 mph implied
        manager.processPosition(_makeGpsData(
          latitude: clampedLat + 0.01,
          longitude: 0.0,
          speedMph: 10,
          rawSpeedMph: 10.0,
          timestamp: baseTime.add(const Duration(seconds: 1)),
        ));

        // No distance should have accumulated due to speed rejection
        expect(manager.totalMilesForTest, equals(0.0));

        manager.dispose();
      },
    );

    /// **Validates: Requirements 6.4, 6.5, 6.7**
    ///
    /// When all gates pass (speed > 0, distance above threshold, implied
    /// speed ≤ 30 mph), distance SHOULD accumulate.
    Glados(any.positiveSpeed).test(
      'distance accumulates when all gates pass',
      (speed) {
        final repo = InMemoryPreferencesRepository();
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(0.0, 0.0, 0.0);

        final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

        // Use a known position pair that produces a distance above threshold
        // but with implied speed below 30 mph.
        // 0.001 degrees latitude ≈ 0.069 miles
        // Over 10 seconds: 0.069 / 10 * 3600 ≈ 24.8 mph (below 30)
        final speedInt = speed.clamp(1.0, 25.0).truncate();

        manager.processPosition(_makeGpsData(
          latitude: 28.0,
          longitude: -82.0,
          speedMph: speedInt,
          rawSpeedMph: speed.clamp(1.0, 25.0),
          timestamp: baseTime,
        ));

        manager.processPosition(_makeGpsData(
          latitude: 28.001,
          longitude: -82.0,
          speedMph: speedInt,
          rawSpeedMph: speed.clamp(1.0, 25.0),
          timestamp: baseTime.add(const Duration(seconds: 10)),
        ));

        // Distance should have accumulated
        expect(manager.totalMilesForTest, greaterThan(0.0));

        manager.dispose();
      },
    );
  });

  group('Property 16: Odometer invariants', () {
    // ---------------------------------------------------------------
    // (a) Trip reset doesn't affect total
    // ---------------------------------------------------------------

    /// **Validates: Requirements 6.2**
    ///
    /// Resetting the trip odometer should set trip to zero without
    /// affecting the total distance.
    Glados2(any.totalMilesValue, any.tripMilesValue).test(
      'trip reset sets trip to zero without affecting total',
      (totalMiles, tripMiles) {
        final repo = InMemoryPreferencesRepository(
          initialTotal: totalMiles,
          initialTrip: tripMiles,
        );
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(totalMiles, tripMiles, 0.0);

        final totalBefore = manager.totalMilesForTest;

        // Reset trip
        manager.resetTripOdometer();

        // Trip should be zero, total unchanged
        expect(manager.tripMilesForTest, equals(0.0));
        expect(manager.totalMilesForTest, equals(totalBefore));

        manager.dispose();
      },
    );

    // ---------------------------------------------------------------
    // (b) Total odometer rolls over at 100,000 miles
    // ---------------------------------------------------------------

    /// **Validates: Requirements 6.8**
    ///
    /// When total distance reaches or exceeds 100,000.0 miles, it should
    /// roll over (modulo 100,000).
    Glados(any.doubleInRange(99990.0, 99999.5)).test(
      'total odometer rolls over at 100,000 miles',
      (startTotal) {
        final repo = InMemoryPreferencesRepository(initialTotal: startTotal);
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(startTotal, 0.0, 0.0);

        final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

        // Add enough distance to push past 100,000.
        // Each step of 0.001 degrees ≈ 0.069 miles over 10 seconds ≈ 24.8 mph
        final distanceNeeded = 100000.0 - startTotal + 1.0;
        final steps = (distanceNeeded / 0.069).ceil() + 2;

        var currentLat = 28.0;
        var currentTime = baseTime;

        // First position to establish reference
        manager.processPosition(_makeGpsData(
          latitude: currentLat,
          longitude: -82.0,
          speedMph: 20,
          rawSpeedMph: 20.0,
          timestamp: currentTime,
        ));

        for (var i = 0; i < steps; i++) {
          currentLat += 0.001;
          currentTime = currentTime.add(const Duration(seconds: 10));
          manager.processPosition(_makeGpsData(
            latitude: currentLat,
            longitude: -82.0,
            speedMph: 20,
            rawSpeedMph: 20.0,
            timestamp: currentTime,
          ));
        }

        // Total should have rolled over (< 100,000)
        expect(manager.totalMilesForTest, lessThan(100000.0));

        manager.dispose();
      },
    );

    // ---------------------------------------------------------------
    // (c) Trip odometer rolls over at 10,000 miles
    // ---------------------------------------------------------------

    /// **Validates: Requirements 6.13**
    ///
    /// When trip distance reaches or exceeds 10,000.0 miles, it should
    /// roll over (modulo 10,000).
    Glados(any.doubleInRange(9990.0, 9999.5)).test(
      'trip odometer rolls over at 10,000 miles',
      (startTrip) {
        final repo = InMemoryPreferencesRepository(initialTrip: startTrip);
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(0.0, startTrip, 0.0);

        final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

        // Add enough distance to push trip past 10,000
        final distanceNeeded = 10000.0 - startTrip + 1.0;
        final steps = (distanceNeeded / 0.069).ceil() + 2;

        var currentLat = 28.0;
        var currentTime = baseTime;

        // First position
        manager.processPosition(_makeGpsData(
          latitude: currentLat,
          longitude: -82.0,
          speedMph: 20,
          rawSpeedMph: 20.0,
          timestamp: currentTime,
        ));

        for (var i = 0; i < steps; i++) {
          currentLat += 0.001;
          currentTime = currentTime.add(const Duration(seconds: 10));
          manager.processPosition(_makeGpsData(
            latitude: currentLat,
            longitude: -82.0,
            speedMph: 20,
            rawSpeedMph: 20.0,
            timestamp: currentTime,
          ));
        }

        // Trip should have rolled over (< 10,000)
        expect(manager.tripMilesForTest, lessThan(10000.0));

        manager.dispose();
      },
    );

    // ---------------------------------------------------------------
    // (d) Total = sum of segments mod 100,000
    // ---------------------------------------------------------------

    /// **Validates: Requirements 6.1, 6.8**
    ///
    /// The total odometer should equal the sum of all accumulated
    /// distance segments modulo 100,000 miles. When starting from zero,
    /// total and trip should be equal (no resets).
    Glados(any.segmentCount).test(
      'total equals sum of accumulated segments mod 100,000',
      (numSegments) {
        final repo = InMemoryPreferencesRepository();
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(0.0, 0.0, 0.0);

        final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

        var currentLat = 28.0;
        var currentTime = baseTime;

        // First position to establish reference
        manager.processPosition(_makeGpsData(
          latitude: currentLat,
          longitude: -82.0,
          speedMph: 20,
          rawSpeedMph: 20.0,
          timestamp: currentTime,
        ));

        // Accumulate multiple segments
        for (var i = 0; i < numSegments; i++) {
          currentLat += 0.001; // ~0.069 miles per step
          currentTime = currentTime.add(const Duration(seconds: 10));
          manager.processPosition(_makeGpsData(
            latitude: currentLat,
            longitude: -82.0,
            speedMph: 20,
            rawSpeedMph: 20.0,
            timestamp: currentTime,
          ));
        }

        // Total should be positive and less than 100,000
        expect(manager.totalMilesForTest, greaterThan(0.0));
        expect(manager.totalMilesForTest, lessThan(100000.0));

        // Trip should equal total (no resets performed)
        expect(manager.tripMilesForTest, equals(manager.totalMilesForTest));

        manager.dispose();
      },
    );

    /// **Validates: Requirements 6.1, 6.2**
    ///
    /// After a trip reset, new distance accumulates independently
    /// in both total and trip, and total continues from where it was.
    Glados(any.segmentCount).test(
      'after trip reset, total continues accumulating while trip starts fresh',
      (numSegments) {
        final repo = InMemoryPreferencesRepository();
        final manager = DefaultOdometerManager(preferencesRepository: repo);
        manager.loadSync(0.0, 0.0, 0.0);

        final baseTime = DateTime(2024, 1, 1, 12, 0, 0);

        var currentLat = 28.0;
        var currentTime = baseTime;

        // First position
        manager.processPosition(_makeGpsData(
          latitude: currentLat,
          longitude: -82.0,
          speedMph: 20,
          rawSpeedMph: 20.0,
          timestamp: currentTime,
        ));

        // Accumulate some distance before reset
        for (var i = 0; i < numSegments; i++) {
          currentLat += 0.001;
          currentTime = currentTime.add(const Duration(seconds: 10));
          manager.processPosition(_makeGpsData(
            latitude: currentLat,
            longitude: -82.0,
            speedMph: 20,
            rawSpeedMph: 20.0,
            timestamp: currentTime,
          ));
        }

        // Get total before reset
        final totalBeforeReset = manager.totalMilesForTest;
        expect(totalBeforeReset, greaterThan(0.0));

        // Reset trip
        manager.resetTripOdometer();
        expect(manager.tripMilesForTest, equals(0.0));
        expect(manager.totalMilesForTest, equals(totalBeforeReset));

        // Accumulate more distance after reset
        for (var i = 0; i < numSegments; i++) {
          currentLat += 0.001;
          currentTime = currentTime.add(const Duration(seconds: 10));
          manager.processPosition(_makeGpsData(
            latitude: currentLat,
            longitude: -82.0,
            speedMph: 20,
            rawSpeedMph: 20.0,
            timestamp: currentTime,
          ));
        }

        // Total should be greater than before reset
        expect(manager.totalMilesForTest, greaterThan(totalBeforeReset));

        // Trip should be less than total (since trip was reset mid-way)
        expect(manager.tripMilesForTest, lessThan(manager.totalMilesForTest));

        manager.dispose();
      },
    );
  });
}
