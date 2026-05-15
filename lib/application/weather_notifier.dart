import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/generated/meshtastic.dart';
import '../data/repositories/cache_repository.dart';
import '../data/services/meshtastic_service.dart';
import '../domain/audio_service.dart';
import '../domain/hot_packet_parser.dart';
import '../domain/models/weather_data.dart';

/// State for the weather screen managed by [WeatherNotifier].
class WeatherState {
  /// The current weather data, or null if no data is available.
  final WeatherData? weatherData;

  /// Whether the "new data received" indicator is currently visible.
  final bool showNewDataIndicator;

  const WeatherState({
    this.weatherData,
    this.showNewDataIndicator = false,
  });

  WeatherState copyWith({
    WeatherData? weatherData,
    bool? showNewDataIndicator,
  }) {
    return WeatherState(
      weatherData: weatherData ?? this.weatherData,
      showNewDataIndicator: showNewDataIndicator ?? this.showNewDataIndicator,
    );
  }
}

/// Manages weather data reception, caching, and display state.
///
/// Subscribes to [MeshtasticService] incoming packets for HoT weather packets,
/// parses them via [HotPacketParser], caches via [CacheRepository], and
/// triggers audio alerts on new data.
///
/// Requirements: 3.1, 3.4, 3.5, 3.6, 3.7, 3.8, 13.10, 13.11, 14.3,
///               19.1, 19.3, 19.4, 19.5, 19.6, 19.7
class WeatherNotifier extends StateNotifier<WeatherState> {
  final MeshtasticService _meshtasticService;
  final HotPacketParser _parser;
  final CacheRepository _cacheRepository;
  final AudioService _audioService;

  StreamSubscription<MeshPacket>? _packetSubscription;
  Timer? _newDataIndicatorTimer;

  WeatherNotifier({
    required MeshtasticService meshtasticService,
    required HotPacketParser parser,
    required CacheRepository cacheRepository,
    required AudioService audioService,
  })  : _meshtasticService = meshtasticService,
        _parser = parser,
        _cacheRepository = cacheRepository,
        _audioService = audioService,
        super(const WeatherState()) {
    _init();
  }

  void _init() {
    _loadCachedWeather();
    _subscribeToPackets();
  }

  /// Loads cached weather data on startup with date validation.
  ///
  /// If cached data exists and its date matches today's date, it is restored
  /// with the "(stored)" indicator. Otherwise, no data is displayed.
  /// Requirement 3.7, 19.3, 19.4, 19.5
  Future<void> _loadCachedWeather() async {
    final cached = await _cacheRepository.loadCachedWeather();
    if (cached == null) return;

    // Validate date — only restore if same day
    final today = _currentDateYYYYMMDD();
    if (cached.dateYYYYMMDD != today) {
      // Stale cache — clear it
      await _cacheRepository.clearStaleCache(today);
      return;
    }

    // Parse the cached raw packet
    final weatherData = _parser.parseWeatherPacket(cached.rawPacket);
    if (weatherData == null) return;

    // Restore with "(stored)" indicator and cached timestamp
    final restoredData = WeatherData(
      currentTemp: weatherData.currentTemp,
      forecasts: weatherData.forecasts,
      receivedTimestamp: cached.timestamp,
      isStored: true,
    );

    state = state.copyWith(weatherData: restoredData);
  }

  /// Subscribes to incoming Meshtastic packets and filters for weather data.
  void _subscribeToPackets() {
    _packetSubscription = _meshtasticService.incomingPackets.listen(
      _handleIncomingPacket,
    );
  }

  /// Handles an incoming mesh packet, checking if it's a HoT weather packet.
  void _handleIncomingPacket(MeshPacket packet) {
    // Only process TEXT_MESSAGE_APP packets
    if (packet.whichPayloadVariant() != MeshPacket_PayloadVariant.decoded) {
      return;
    }
    if (packet.decoded.portnum != PortNum.TEXT_MESSAGE_APP) {
      return;
    }

    // Decode the text payload
    final text = utf8.decode(packet.decoded.payload, allowMalformed: true);

    // Check if it's a HoT packet with weather type
    if (!_parser.isHotPacket(text)) return;
    final packetType = _parser.parsePacketType(text);
    if (packetType != 1) return;

    // Parse the weather data
    final weatherData = _parser.parseWeatherPacket(text);
    if (weatherData == null) return;

    // Generate timestamp in 12-hour format
    final timestamp = _formatTimestamp12Hour(DateTime.now());

    // Create live weather data (not stored)
    final liveData = WeatherData(
      currentTemp: weatherData.currentTemp,
      forecasts: weatherData.forecasts,
      receivedTimestamp: timestamp,
      isStored: false,
    );

    // Update state with live data
    state = state.copyWith(
      weatherData: liveData,
      showNewDataIndicator: true,
    );

    // Cache the received data
    _cacheWeatherData(text, timestamp);

    // Play alert tone for new weather data (Requirement 14.3)
    _audioService.playAlert();

    // Auto-clear "new data received" indicator after 5 seconds (Req 13.11)
    _startNewDataIndicatorTimer();
  }

  /// Caches weather data with the raw packet, timestamp, and current date.
  /// Requirement 19.1
  Future<void> _cacheWeatherData(String rawPacket, String timestamp) async {
    final dateYYYYMMDD = _currentDateYYYYMMDD();
    await _cacheRepository.cacheWeatherData(rawPacket, timestamp, dateYYYYMMDD);
  }

  /// Starts or restarts the 5-second timer to auto-clear the new data indicator.
  /// Requirement 13.11
  void _startNewDataIndicatorTimer() {
    _newDataIndicatorTimer?.cancel();
    _newDataIndicatorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        state = state.copyWith(showNewDataIndicator: false);
      }
    });
  }

  /// Formats a [DateTime] as a 12-hour timestamp string (e.g., "2:35 PM").
  /// Requirement 3.5
  String _formatTimestamp12Hour(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  /// Returns the current date as a YYYYMMDD integer.
  int _currentDateYYYYMMDD() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }

  @override
  void dispose() {
    _packetSubscription?.cancel();
    _newDataIndicatorTimer?.cancel();
    super.dispose();
  }
}
