/// Cache repository for structured data persistence using Hive.
///
/// Manages cached weather and venue/event data with date-based
/// staleness validation. Data is stored with the raw packet,
/// a human-readable timestamp, and a YYYYMMDD date integer for
/// same-day cache restoration.
library;

import 'package:hive/hive.dart';

/// Cached weather data entry.
class CachedWeather {
  /// The raw HoT packet string as received.
  final String rawPacket;

  /// Human-readable timestamp when data was received (e.g., "2:35 PM").
  final String timestamp;

  /// Date the data was cached in YYYYMMDD format.
  final int dateYYYYMMDD;

  const CachedWeather({
    required this.rawPacket,
    required this.timestamp,
    required this.dateYYYYMMDD,
  });
}

/// Cached venue/event data entry.
class CachedVenue {
  /// The raw HoT packet string as received.
  final String rawPacket;

  /// Human-readable timestamp when data was received (e.g., "2:35 PM").
  final String timestamp;

  /// Date the data was cached in YYYYMMDD format.
  final int dateYYYYMMDD;

  const CachedVenue({
    required this.rawPacket,
    required this.timestamp,
    required this.dateYYYYMMDD,
  });
}

/// Abstract interface for cache data persistence.
///
/// Implementations store weather and venue/event data with date-based
/// validation for same-day restoration on app startup.
abstract class CacheRepository {
  /// Caches weather data with the raw packet, timestamp, and date.
  ///
  /// [rawPacket] is the full HoT packet string as received.
  /// [timestamp] is the human-readable time (e.g., "2:35 PM").
  /// [dateYYYYMMDD] is the current GPS date as an integer (e.g., 20250115).
  Future<void> cacheWeatherData(
    String rawPacket,
    String timestamp,
    int dateYYYYMMDD,
  );

  /// Caches venue/event data with the raw packet, timestamp, and date.
  ///
  /// [rawPacket] is the full HoT packet string as received.
  /// [timestamp] is the human-readable time (e.g., "2:35 PM").
  /// [dateYYYYMMDD] is the current GPS date as an integer (e.g., 20250115).
  Future<void> cacheVenueData(
    String rawPacket,
    String timestamp,
    int dateYYYYMMDD,
  );

  /// Loads cached weather data if available.
  ///
  /// Returns null if no cached weather data exists.
  Future<CachedWeather?> loadCachedWeather();

  /// Loads cached venue/event data if available.
  ///
  /// Returns null if no cached venue data exists.
  Future<CachedVenue?> loadCachedVenue();

  /// Clears stale cache entries whose stored date does not match
  /// [currentDateYYYYMMDD].
  ///
  /// Weather and venue caches are evaluated independently — only
  /// entries with a mismatched date are discarded.
  Future<void> clearStaleCache(int currentDateYYYYMMDD);
}

/// Hive-based implementation of [CacheRepository].
///
/// Uses a single Hive box to store weather and venue cache entries
/// as key-value pairs with structured fields.
class HiveCacheRepository implements CacheRepository {
  /// Hive box name for cache storage.
  static const String boxName = 'gcd_cache';

  // Keys for weather cache fields.
  static const String _weatherRawPacketKey = 'weather_raw_packet';
  static const String _weatherTimestampKey = 'weather_timestamp';
  static const String _weatherDateKey = 'weather_date';

  // Keys for venue cache fields.
  static const String _venueRawPacketKey = 'venue_raw_packet';
  static const String _venueTimestampKey = 'venue_timestamp';
  static const String _venueDateKey = 'venue_date';

  final Box<dynamic> _box;

  /// Creates a [HiveCacheRepository] with the given Hive box.
  ///
  /// The box should be opened before constructing this repository.
  HiveCacheRepository(this._box);

  /// Opens the Hive box and returns a configured [HiveCacheRepository].
  ///
  /// Call this during app initialization after [Hive.init] has been called.
  static Future<HiveCacheRepository> create() async {
    final box = await Hive.openBox<dynamic>(boxName);
    return HiveCacheRepository(box);
  }

  @override
  Future<void> cacheWeatherData(
    String rawPacket,
    String timestamp,
    int dateYYYYMMDD,
  ) async {
    await _box.put(_weatherRawPacketKey, rawPacket);
    await _box.put(_weatherTimestampKey, timestamp);
    await _box.put(_weatherDateKey, dateYYYYMMDD);
  }

  @override
  Future<void> cacheVenueData(
    String rawPacket,
    String timestamp,
    int dateYYYYMMDD,
  ) async {
    await _box.put(_venueRawPacketKey, rawPacket);
    await _box.put(_venueTimestampKey, timestamp);
    await _box.put(_venueDateKey, dateYYYYMMDD);
  }

  @override
  Future<CachedWeather?> loadCachedWeather() async {
    final rawPacket = _box.get(_weatherRawPacketKey) as String?;
    final timestamp = _box.get(_weatherTimestampKey) as String?;
    final date = _box.get(_weatherDateKey) as int?;

    if (rawPacket == null || timestamp == null || date == null) {
      return null;
    }

    return CachedWeather(
      rawPacket: rawPacket,
      timestamp: timestamp,
      dateYYYYMMDD: date,
    );
  }

  @override
  Future<CachedVenue?> loadCachedVenue() async {
    final rawPacket = _box.get(_venueRawPacketKey) as String?;
    final timestamp = _box.get(_venueTimestampKey) as String?;
    final date = _box.get(_venueDateKey) as int?;

    if (rawPacket == null || timestamp == null || date == null) {
      return null;
    }

    return CachedVenue(
      rawPacket: rawPacket,
      timestamp: timestamp,
      dateYYYYMMDD: date,
    );
  }

  @override
  Future<void> clearStaleCache(int currentDateYYYYMMDD) async {
    final weatherDate = _box.get(_weatherDateKey) as int?;
    if (weatherDate != null && weatherDate != currentDateYYYYMMDD) {
      await _box.delete(_weatherRawPacketKey);
      await _box.delete(_weatherTimestampKey);
      await _box.delete(_weatherDateKey);
    }

    final venueDate = _box.get(_venueDateKey) as int?;
    if (venueDate != null && venueDate != currentDateYYYYMMDD) {
      await _box.delete(_venueRawPacketKey);
      await _box.delete(_venueTimestampKey);
      await _box.delete(_venueDateKey);
    }
  }
}
