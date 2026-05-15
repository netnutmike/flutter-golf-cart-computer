import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/generated/meshtastic.dart';
import '../data/repositories/cache_repository.dart';
import '../data/services/meshtastic_service.dart';
import '../domain/audio_service.dart';
import '../domain/hot_packet_parser.dart';
import '../domain/models/entertainment_data.dart';

/// State for the entertainment screen.
///
/// Contains the current venue/event data, display indicators, and
/// metadata about data freshness.
class EntertainmentState {
  /// The current entertainment data to display, or null if no data available.
  final EntertainmentData? data;

  /// Whether the "new data received" indicator is currently visible.
  final bool showNewDataIndicator;

  /// Whether data is currently loading from cache.
  final bool isLoading;

  const EntertainmentState({
    this.data,
    this.showNewDataIndicator = false,
    this.isLoading = false,
  });

  /// Creates a copy with the specified fields replaced.
  EntertainmentState copyWith({
    EntertainmentData? data,
    bool? showNewDataIndicator,
    bool? isLoading,
    bool clearData = false,
  }) {
    return EntertainmentState(
      data: clearData ? null : (data ?? this.data),
      showNewDataIndicator: showNewDataIndicator ?? this.showNewDataIndicator,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Manages entertainment (venue/event) data state for the entertainment screen.
///
/// Subscribes to incoming Meshtastic packets, parses HoT venue/event packets,
/// caches data for same-day restoration, and manages display indicators.
///
/// Requirements: 4.5, 4.7, 4.8, 4.9, 4.10, 4.11, 13.10, 13.11, 14.3,
///               19.2, 19.3, 19.4, 19.5, 19.6, 19.7
class EntertainmentNotifier extends StateNotifier<EntertainmentState> {
  final MeshtasticService _meshtasticService;
  final HotPacketParser _hotPacketParser;
  final CacheRepository _cacheRepository;
  final AudioService _audioService;

  StreamSubscription<MeshPacket>? _packetSubscription;
  Timer? _newDataIndicatorTimer;

  /// Creates an [EntertainmentNotifier] and begins listening for packets.
  EntertainmentNotifier({
    required MeshtasticService meshtasticService,
    required HotPacketParser hotPacketParser,
    required CacheRepository cacheRepository,
    required AudioService audioService,
  })  : _meshtasticService = meshtasticService,
        _hotPacketParser = hotPacketParser,
        _cacheRepository = cacheRepository,
        _audioService = audioService,
        super(const EntertainmentState(isLoading: true)) {
    _init();
  }

  /// Initializes by loading cached data and subscribing to packets.
  Future<void> _init() async {
    await _loadCachedData();
    _subscribeToPackets();
  }

  /// Loads cached venue/event data on startup with date validation.
  ///
  /// If cached data exists and its date matches the current date, it is
  /// restored with a "(stored)" indicator. Otherwise, the cache is stale
  /// and the screen remains empty until fresh data arrives.
  ///
  /// Requirements: 4.9, 4.10, 19.3, 19.4, 19.5
  Future<void> _loadCachedData() async {
    try {
      final cachedVenue = await _cacheRepository.loadCachedVenue();

      if (cachedVenue == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Validate date against current date
      final now = DateTime.now();
      final currentDateYYYYMMDD =
          now.year * 10000 + now.month * 100 + now.day;

      if (cachedVenue.dateYYYYMMDD != currentDateYYYYMMDD) {
        // Stale cache — discard and show empty screen
        await _cacheRepository.clearStaleCache(currentDateYYYYMMDD);
        state = state.copyWith(isLoading: false);
        return;
      }

      // Parse the cached raw packet
      final venues =
          _hotPacketParser.parseVenueEventPacket(cachedVenue.rawPacket);

      if (venues == null || venues.isEmpty) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Restore with "(stored)" indicator
      state = state.copyWith(
        data: EntertainmentData(
          venues: venues,
          receivedTimestamp: cachedVenue.timestamp,
          isStored: true,
        ),
        isLoading: false,
      );
    } catch (_) {
      // On any error, just show empty state
      state = state.copyWith(isLoading: false);
    }
  }

  /// Subscribes to incoming Meshtastic packets and filters for HoT
  /// venue/event packets (type 02).
  void _subscribeToPackets() {
    _packetSubscription = _meshtasticService.incomingPackets.listen(
      _handlePacket,
    );
  }

  /// Handles an incoming mesh packet, checking if it contains venue/event data.
  void _handlePacket(MeshPacket packet) {
    // Only process text message packets
    if (!packet.hasDecoded()) return;
    final data = packet.decoded;
    if (data.portnum != PortNum.TEXT_MESSAGE_APP) return;

    // Decode the payload as UTF-8 text
    final text = utf8.decode(data.payload, allowMalformed: true);

    // Check if it's a HoT packet
    if (!_hotPacketParser.isHotPacket(text)) return;

    // Check if it's a venue/event packet (type 02)
    final packetType = _hotPacketParser.parsePacketType(text);
    if (packetType != 2) return;

    // Parse the venue/event data
    final venues = _hotPacketParser.parseVenueEventPacket(text);
    if (venues == null || venues.isEmpty) return;

    // Generate timestamp in 12-hour format
    final timestamp = _formatTimestamp(DateTime.now());

    // Cache the data
    _cacheVenueData(text, timestamp);

    // Update state with live data (removes "(stored)" indicator)
    // Requirements: 4.11, 19.6
    state = state.copyWith(
      data: EntertainmentData(
        venues: venues,
        receivedTimestamp: timestamp,
        isStored: false,
      ),
      showNewDataIndicator: true,
    );

    // Play alert tone for new venue data
    // Requirement: 14.3
    _audioService.playAlert();

    // Auto-clear "new data received" indicator after 5 seconds
    // Requirement: 13.11
    _startNewDataIndicatorTimer();
  }

  /// Caches venue/event data with the current GPS date.
  ///
  /// Requirement: 4.8, 19.2
  Future<void> _cacheVenueData(String rawPacket, String timestamp) async {
    final now = DateTime.now();
    final dateYYYYMMDD = now.year * 10000 + now.month * 100 + now.day;

    try {
      await _cacheRepository.cacheVenueData(rawPacket, timestamp, dateYYYYMMDD);
    } catch (_) {
      // Cache failure is non-fatal; data is still displayed live
    }
  }

  /// Formats a [DateTime] as a 12-hour timestamp string (e.g., "2:35 PM").
  ///
  /// Requirement: 4.7
  String _formatTimestamp(DateTime dateTime) {
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

  /// Starts or restarts the 5-second timer to clear the "new data" indicator.
  ///
  /// Requirement: 13.11
  void _startNewDataIndicatorTimer() {
    _newDataIndicatorTimer?.cancel();
    _newDataIndicatorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        state = state.copyWith(showNewDataIndicator: false);
      }
    });
  }

  @override
  void dispose() {
    _packetSubscription?.cancel();
    _newDataIndicatorTimer?.cancel();
    super.dispose();
  }
}
