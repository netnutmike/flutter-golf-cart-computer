import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/data/repositories/cache_repository.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;
  late HiveCacheRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    final box = await Hive.openBox<dynamic>(HiveCacheRepository.boxName);
    repository = HiveCacheRepository(box);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('CacheRepository - cacheWeatherData', () {
    test('stores weather data fields', () async {
      await repository.cacheWeatherData(
        '|#01#72#10am,sunny,75,10.5#11am,cloudy,70,20.0#12pm,rain,68,80.0#1pm,clear,74,0.0#',
        '2:35 PM',
        20250115,
      );

      final cached = await repository.loadCachedWeather();
      expect(cached, isNotNull);
      expect(
        cached!.rawPacket,
        '|#01#72#10am,sunny,75,10.5#11am,cloudy,70,20.0#12pm,rain,68,80.0#1pm,clear,74,0.0#',
      );
      expect(cached.timestamp, '2:35 PM');
      expect(cached.dateYYYYMMDD, 20250115);
    });

    test('overwrites previous weather data', () async {
      await repository.cacheWeatherData('old_packet', '1:00 PM', 20250114);
      await repository.cacheWeatherData('new_packet', '3:00 PM', 20250115);

      final cached = await repository.loadCachedWeather();
      expect(cached, isNotNull);
      expect(cached!.rawPacket, 'new_packet');
      expect(cached.timestamp, '3:00 PM');
      expect(cached.dateYYYYMMDD, 20250115);
    });
  });

  group('CacheRepository - cacheVenueData', () {
    test('stores venue data fields', () async {
      await repository.cacheVenueData(
        '|#02#Katie Belles,Live Band#Brownwood Paddock,DJ Night#',
        '4:15 PM',
        20250115,
      );

      final cached = await repository.loadCachedVenue();
      expect(cached, isNotNull);
      expect(
        cached!.rawPacket,
        '|#02#Katie Belles,Live Band#Brownwood Paddock,DJ Night#',
      );
      expect(cached.timestamp, '4:15 PM');
      expect(cached.dateYYYYMMDD, 20250115);
    });

    test('overwrites previous venue data', () async {
      await repository.cacheVenueData('old_venue', '1:00 PM', 20250114);
      await repository.cacheVenueData('new_venue', '5:00 PM', 20250115);

      final cached = await repository.loadCachedVenue();
      expect(cached, isNotNull);
      expect(cached!.rawPacket, 'new_venue');
      expect(cached.timestamp, '5:00 PM');
      expect(cached.dateYYYYMMDD, 20250115);
    });
  });

  group('CacheRepository - loadCachedWeather', () {
    test('returns null when no weather data cached', () async {
      final cached = await repository.loadCachedWeather();
      expect(cached, isNull);
    });

    test('returns cached weather data when present', () async {
      await repository.cacheWeatherData('packet', '10:00 AM', 20250120);

      final cached = await repository.loadCachedWeather();
      expect(cached, isNotNull);
      expect(cached!.rawPacket, 'packet');
      expect(cached.timestamp, '10:00 AM');
      expect(cached.dateYYYYMMDD, 20250120);
    });
  });

  group('CacheRepository - loadCachedVenue', () {
    test('returns null when no venue data cached', () async {
      final cached = await repository.loadCachedVenue();
      expect(cached, isNull);
    });

    test('returns cached venue data when present', () async {
      await repository.cacheVenueData('venue_packet', '6:30 PM', 20250120);

      final cached = await repository.loadCachedVenue();
      expect(cached, isNotNull);
      expect(cached!.rawPacket, 'venue_packet');
      expect(cached.timestamp, '6:30 PM');
      expect(cached.dateYYYYMMDD, 20250120);
    });
  });

  group('CacheRepository - clearStaleCache', () {
    test('clears weather cache when date does not match', () async {
      await repository.cacheWeatherData('packet', '2:00 PM', 20250114);

      await repository.clearStaleCache(20250115);

      final cached = await repository.loadCachedWeather();
      expect(cached, isNull);
    });

    test('clears venue cache when date does not match', () async {
      await repository.cacheVenueData('venue', '3:00 PM', 20250114);

      await repository.clearStaleCache(20250115);

      final cached = await repository.loadCachedVenue();
      expect(cached, isNull);
    });

    test('preserves weather cache when date matches', () async {
      await repository.cacheWeatherData('packet', '2:00 PM', 20250115);

      await repository.clearStaleCache(20250115);

      final cached = await repository.loadCachedWeather();
      expect(cached, isNotNull);
      expect(cached!.rawPacket, 'packet');
    });

    test('preserves venue cache when date matches', () async {
      await repository.cacheVenueData('venue', '3:00 PM', 20250115);

      await repository.clearStaleCache(20250115);

      final cached = await repository.loadCachedVenue();
      expect(cached, isNotNull);
      expect(cached!.rawPacket, 'venue');
    });

    test('clears weather but preserves venue when only weather is stale', () async {
      await repository.cacheWeatherData('old_weather', '1:00 PM', 20250114);
      await repository.cacheVenueData('today_venue', '3:00 PM', 20250115);

      await repository.clearStaleCache(20250115);

      final weather = await repository.loadCachedWeather();
      final venue = await repository.loadCachedVenue();
      expect(weather, isNull);
      expect(venue, isNotNull);
      expect(venue!.rawPacket, 'today_venue');
    });

    test('clears venue but preserves weather when only venue is stale', () async {
      await repository.cacheWeatherData('today_weather', '2:00 PM', 20250115);
      await repository.cacheVenueData('old_venue', '1:00 PM', 20250114);

      await repository.clearStaleCache(20250115);

      final weather = await repository.loadCachedWeather();
      final venue = await repository.loadCachedVenue();
      expect(weather, isNotNull);
      expect(weather!.rawPacket, 'today_weather');
      expect(venue, isNull);
    });

    test('handles empty cache gracefully', () async {
      // Should not throw when no data exists
      await repository.clearStaleCache(20250115);

      final weather = await repository.loadCachedWeather();
      final venue = await repository.loadCachedVenue();
      expect(weather, isNull);
      expect(venue, isNull);
    });
  });

  group('CacheRepository - create factory', () {
    test('creates repository via static factory method', () async {
      // Close existing box first to avoid conflicts
      await Hive.close();

      Hive.init(tempDir.path);
      final repo = await HiveCacheRepository.create();

      // Verify it works
      await repo.cacheWeatherData('test', '12:00 PM', 20250101);
      final cached = await repo.loadCachedWeather();
      expect(cached, isNotNull);
      expect(cached!.rawPacket, 'test');

      await Hive.close();
    });
  });

  group('CacheRepository - weather and venue independence', () {
    test('caching weather does not affect venue', () async {
      await repository.cacheVenueData('venue_data', '1:00 PM', 20250115);
      await repository.cacheWeatherData('weather_data', '2:00 PM', 20250115);

      final venue = await repository.loadCachedVenue();
      expect(venue, isNotNull);
      expect(venue!.rawPacket, 'venue_data');
    });

    test('caching venue does not affect weather', () async {
      await repository.cacheWeatherData('weather_data', '2:00 PM', 20250115);
      await repository.cacheVenueData('venue_data', '1:00 PM', 20250115);

      final weather = await repository.loadCachedWeather();
      expect(weather, isNotNull);
      expect(weather!.rawPacket, 'weather_data');
    });
  });
}
