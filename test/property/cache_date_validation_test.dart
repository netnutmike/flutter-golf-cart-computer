import 'dart:io';

import 'package:glados/glados.dart';
import 'package:golf_cart_computer/data/repositories/cache_repository.dart';
import 'package:hive/hive.dart';

/// Custom generators for YYYYMMDD date integers.
///
/// Generates realistic date integers in the range 20000101 to 20991231.
/// This covers a wide range of valid dates for cache validation testing.
extension DateGenerators on Any {
  /// Generates a YYYYMMDD integer representing a valid-format date.
  Generator<int> get dateYYYYMMDD => intInRange(20000101, 20991232);

  /// Generates a non-empty ASCII string for raw packet content.
  Generator<String> get rawPacket =>
      listWithLengthInRange(1, 50, intInRange(32, 126))
          .map((codes) => String.fromCharCodes(codes));

  /// Generates a timestamp string like "H:MM AM/PM".
  Generator<String> get timestamp =>
      intInRange(1, 12).bind((hour) =>
          intInRange(0, 59).bind((minute) =>
              choose(['AM', 'PM']).map((ampm) =>
                  '$hour:${minute.toString().padLeft(2, '0')} $ampm')));
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_prop_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Property 10: Cache date validation', () {
    /// **Validates: Requirements 3.7, 3.8, 4.9, 4.10, 19.3, 19.4, 19.5**
    ///
    /// For any cached weather data with a stored date equal to the current date,
    /// clearStaleCache should preserve the data.
    Glados3(any.dateYYYYMMDD, any.rawPacket, any.timestamp).test(
      'weather cache is preserved when stored date equals current date',
      (storedDate, packet, ts) async {
        final box = await Hive.openBox<dynamic>(
          'weather_same_date_${DateTime.now().microsecondsSinceEpoch}',
        );
        final repository = HiveCacheRepository(box);

        await repository.cacheWeatherData(packet, ts, storedDate);
        await repository.clearStaleCache(storedDate);

        final cached = await repository.loadCachedWeather();
        expect(cached, isNotNull,
            reason: 'Weather cache should be preserved when dates match');
        expect(cached!.rawPacket, equals(packet));
        expect(cached.timestamp, equals(ts));
        expect(cached.dateYYYYMMDD, equals(storedDate));

        await box.close();
      },
    );

    /// **Validates: Requirements 3.7, 3.8, 4.9, 4.10, 19.3, 19.4, 19.5**
    ///
    /// For any cached weather data with a stored date different from the current
    /// date, clearStaleCache should discard the data.
    Glados3(any.dateYYYYMMDD, any.rawPacket, any.timestamp).test(
      'weather cache is discarded when stored date differs from current date',
      (storedDate, packet, ts) async {
        // Ensure current date differs from stored date
        final currentDate = storedDate == 20991231 ? storedDate - 1 : storedDate + 1;

        final box = await Hive.openBox<dynamic>(
          'weather_diff_date_${DateTime.now().microsecondsSinceEpoch}',
        );
        final repository = HiveCacheRepository(box);

        await repository.cacheWeatherData(packet, ts, storedDate);
        await repository.clearStaleCache(currentDate);

        final cached = await repository.loadCachedWeather();
        expect(cached, isNull,
            reason: 'Weather cache should be discarded when dates differ');

        await box.close();
      },
    );

    /// **Validates: Requirements 3.7, 3.8, 4.9, 4.10, 19.3, 19.4, 19.5**
    ///
    /// For any cached venue data with a stored date equal to the current date,
    /// clearStaleCache should preserve the data.
    Glados3(any.dateYYYYMMDD, any.rawPacket, any.timestamp).test(
      'venue cache is preserved when stored date equals current date',
      (storedDate, packet, ts) async {
        final box = await Hive.openBox<dynamic>(
          'venue_same_date_${DateTime.now().microsecondsSinceEpoch}',
        );
        final repository = HiveCacheRepository(box);

        await repository.cacheVenueData(packet, ts, storedDate);
        await repository.clearStaleCache(storedDate);

        final cached = await repository.loadCachedVenue();
        expect(cached, isNotNull,
            reason: 'Venue cache should be preserved when dates match');
        expect(cached!.rawPacket, equals(packet));
        expect(cached.timestamp, equals(ts));
        expect(cached.dateYYYYMMDD, equals(storedDate));

        await box.close();
      },
    );

    /// **Validates: Requirements 3.7, 3.8, 4.9, 4.10, 19.3, 19.4, 19.5**
    ///
    /// For any cached venue data with a stored date different from the current
    /// date, clearStaleCache should discard the data.
    Glados3(any.dateYYYYMMDD, any.rawPacket, any.timestamp).test(
      'venue cache is discarded when stored date differs from current date',
      (storedDate, packet, ts) async {
        // Ensure current date differs from stored date
        final currentDate = storedDate == 20991231 ? storedDate - 1 : storedDate + 1;

        final box = await Hive.openBox<dynamic>(
          'venue_diff_date_${DateTime.now().microsecondsSinceEpoch}',
        );
        final repository = HiveCacheRepository(box);

        await repository.cacheVenueData(packet, ts, storedDate);
        await repository.clearStaleCache(currentDate);

        final cached = await repository.loadCachedVenue();
        expect(cached, isNull,
            reason: 'Venue cache should be discarded when dates differ');

        await box.close();
      },
    );
  });
}
