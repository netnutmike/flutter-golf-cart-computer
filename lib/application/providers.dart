/// Riverpod provider definitions for the Golf Cart Computer application.
///
/// Providers are organized by architectural layer:
/// - Data providers: external communication, persistence, platform APIs
/// - Domain providers: pure business logic, data transformation, algorithms
/// - Application providers: state notifiers coordinating domain logic and UI
///
/// Requirements: 16.2
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/cache_repository.dart';
import '../data/repositories/preferences_repository.dart';
import '../data/services/background_service.dart';
import '../data/services/location_service.dart';
import '../data/services/meshtastic_service.dart';
import '../data/services/telemetry_service.dart';
import '../domain/audio_service.dart';
import '../domain/brightness_manager.dart';
import '../domain/geofence_manager.dart';
import '../domain/gps_processor.dart';
import '../domain/hot_packet_parser.dart';
import '../domain/odometer_manager.dart';
import '../domain/service_reminder_manager.dart';
import '../domain/sleep_manager.dart';
import '../domain/speed_filter.dart';
import 'config_notifier.dart';
import 'entertainment_notifier.dart';
import 'main_notifier.dart';
import 'messaging_notifier.dart';
import 'radio_admin_notifier.dart';
import 'connection_notifier.dart';
import 'weather_notifier.dart';

// =============================================================================
// Data Layer Providers
// =============================================================================

/// Provides the [MeshtasticService] for BLE communication with the
/// Meshtastic radio.
final meshtasticServiceProvider = Provider<MeshtasticService>((ref) {
  return BleMeshtasticService();
});

/// Provides the [TelemetryService] for Bluetooth communication with the
/// GCI ESP-32 computer.
final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return PlatformTelemetryService();
});

/// Provides the [LocationService] for cross-platform GPS access.
final locationServiceProvider = Provider<LocationService>((ref) {
  return GeolocatorLocationService();
});

/// Provides the [PreferencesRepository] for persistent key-value storage.
///
/// Requires [SharedPreferences] to be initialized before use. Override this
/// provider in tests or initialize via `ProviderScope.overrides`.
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  throw UnimplementedError(
    'preferencesRepositoryProvider must be overridden with an initialized '
    'SharedPreferencesRepository instance.',
  );
});

/// Provides the [CacheRepository] for structured data persistence using Hive.
///
/// Requires Hive to be initialized before use. Override this provider in
/// tests or initialize via `ProviderScope.overrides`.
final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  throw UnimplementedError(
    'cacheRepositoryProvider must be overridden with an initialized '
    'HiveCacheRepository instance.',
  );
});

/// Provides the [BackgroundService] for platform-specific background execution.
final backgroundServiceProvider = Provider<BackgroundService>((ref) {
  return PlatformBackgroundService();
});

// =============================================================================
// Domain Layer Providers
// =============================================================================

/// Provides the [SpeedFilter] for GPS speed filtering pipeline.
final speedFilterProvider = Provider<SpeedFilter>((ref) {
  return SpeedFilter();
});

/// Provides the [GpsProcessor] for processing raw GPS data.
final gpsProcessorProvider = Provider<GpsProcessor>((ref) {
  final speedFilter = ref.watch(speedFilterProvider);
  return DefaultGpsProcessor(speedFilter: speedFilter);
});

/// Provides the [OdometerManager] for distance accumulation tracking.
final odometerManagerProvider = Provider<OdometerManager>((ref) {
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return DefaultOdometerManager(
    preferencesRepository: preferencesRepository,
  );
});

/// Provides the [ServiceReminderManager] for driving hours and maintenance
/// tracking.
final serviceReminderProvider = Provider<ServiceReminderManager>((ref) {
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return DefaultServiceReminderManager(
    preferencesRepository: preferencesRepository,
  );
});

/// Provides the [HotPacketParser] for parsing structured HoT data packets.
final hotPacketParserProvider = Provider<HotPacketParser>((ref) {
  return HotPacketParser();
});

/// Provides the [SleepManager] for three-state power management.
///
/// The backlight timeout is sourced from user preferences. Defaults to 5
/// minutes if preferences are not yet loaded.
final sleepManagerProvider = Provider<SleepManager>((ref) {
  return DefaultSleepManager(backlightTimeoutMinutes: 5);
});

/// Provides the [BrightnessManager] for display brightness control.
final brightnessManagerProvider = Provider<BrightnessManager>((ref) {
  return DefaultBrightnessManager();
});

/// Provides the [GeofenceManager] for home location and at-home status.
final geofenceManagerProvider = Provider<GeofenceManager>((ref) {
  return GeofenceManagerImpl();
});

/// Provides the [AudioService] for sound playback.
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioServiceImpl();
});

// =============================================================================
// Application Layer Providers
// =============================================================================

/// Provides the [MainNotifier] for the main screen state.
///
/// Subscribes to GPS, odometer, service reminder, geofence, sleep,
/// brightness, and telemetry streams to produce a unified [MainScreenState].
/// Coordinates GPS interval changes and GCI notifications.
///
/// Requirements: 5.3, 5.8, 5.9, 5.10, 5.13, 5.14, 5.17, 5.18, 6.3, 7.6,
///   8.3, 8.4, 8.5, 8.6, 8.13, 8.14, 9.5, 9.6, 11.6, 11.7, 12.4, 12.8
final mainNotifierProvider =
    StateNotifierProvider<MainNotifier, MainScreenState>((ref) {
  final gpsProcessor = ref.watch(gpsProcessorProvider);
  final odometerManager = ref.watch(odometerManagerProvider);
  final serviceReminderManager = ref.watch(serviceReminderProvider);
  final geofenceManager = ref.watch(geofenceManagerProvider);
  final sleepManager = ref.watch(sleepManagerProvider);
  final brightnessManager = ref.watch(brightnessManagerProvider);
  final telemetryService = ref.watch(telemetryServiceProvider);
  final meshtasticService = ref.watch(meshtasticServiceProvider);

  // Temperature offset defaults to 0; will be updated when preferences load.
  return MainNotifier(
    gpsProcessor: gpsProcessor,
    odometerManager: odometerManager,
    serviceReminderManager: serviceReminderManager,
    geofenceManager: geofenceManager,
    sleepManager: sleepManager,
    brightnessManager: brightnessManager,
    telemetryService: telemetryService,
    meshtasticService: meshtasticService,
    temperatureOffset: 0,
  );
});

/// Provides the weather screen state notifier.
///
/// Manages weather data reception from Meshtastic HoT packets, caching,
/// and display state including "(stored)" indicator and new data alerts.
final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final meshtasticService = ref.watch(meshtasticServiceProvider);
  final parser = ref.watch(hotPacketParserProvider);
  final cacheRepository = ref.watch(cacheRepositoryProvider);
  final audioService = ref.watch(audioServiceProvider);

  return WeatherNotifier(
    meshtasticService: meshtasticService,
    parser: parser,
    cacheRepository: cacheRepository,
    audioService: audioService,
  );
});

/// Provides the entertainment screen state notifier.
///
/// Manages venue/event data from HoT packets, caching, and display indicators.
final entertainmentNotifierProvider =
    StateNotifierProvider<EntertainmentNotifier, EntertainmentState>((ref) {
  return EntertainmentNotifier(
    meshtasticService: ref.watch(meshtasticServiceProvider),
    hotPacketParser: ref.watch(hotPacketParserProvider),
    cacheRepository: ref.watch(cacheRepositoryProvider),
    audioService: ref.watch(audioServiceProvider),
  );
});

/// Provides the configuration screen state notifier.
///
/// Manages all user preferences, home location, GCI pairing,
/// Meshtastic enable/disable, service hours reset, trip odometer reset,
/// preference reset, and manual app restart.
///
/// Requirements: 9.1, 9.2, 9.8, 13.5, 13.7, 13.8, 15.3, 15.4, 12.7,
///              11.8, 7.9, 6.2, 14.4, 14.6
final configNotifierProvider =
    StateNotifierProvider<ConfigNotifier, ConfigState>((ref) {
  final notifier = ConfigNotifier(
    preferencesRepository: ref.watch(preferencesRepositoryProvider),
    locationService: ref.watch(locationServiceProvider),
    telemetryService: ref.watch(telemetryServiceProvider),
    meshtasticService: ref.watch(meshtasticServiceProvider),
    geofenceManager: ref.watch(geofenceManagerProvider),
    odometerManager: ref.watch(odometerManagerProvider),
    serviceReminderManager: ref.watch(serviceReminderProvider),
    audioService: ref.watch(audioServiceProvider),
  );
  // Initialize preferences loading asynchronously.
  notifier.initialize();
  return notifier;
});

/// Provides the connection management state notifier.
///
/// Manages independent connection state for Meshtastic and GCI,
/// coordinates initial connection on startup, handles permission checks,
/// and sends protocol messages on connection establishment.
///
/// Requirements: 17.1, 17.2, 17.3, 17.4, 17.5, 2.8, 3.8
final connectionNotifierProvider =
    StateNotifierProvider<ConnectionNotifier, DualConnectionState>((ref) {
  final meshtasticService = ref.watch(meshtasticServiceProvider);
  final telemetryService = ref.watch(telemetryServiceProvider);
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  final cacheRepository = ref.watch(cacheRepositoryProvider);

  return ConnectionNotifier(
    meshtasticService: meshtasticService,
    telemetryService: telemetryService,
    preferencesRepository: preferencesRepository,
    cacheRepository: cacheRepository,
  );
});

/// Provides the messaging state notifier for Meshtastic text messaging.
///
/// Manages sending/receiving text messages, message history (up to 100),
/// preformatted message selection, payload size enforcement, and
/// notification tones on message receipt.
///
/// Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.9, 2.10, 2.11, 2.12
final messagingNotifierProvider =
    StateNotifierProvider<MessagingNotifier, MessagingState>((ref) {
  final meshtasticService = ref.watch(meshtasticServiceProvider);
  final audioService = ref.watch(audioServiceProvider);

  return MessagingNotifier(
    meshtasticService: meshtasticService,
    audioService: audioService,
  );
});

/// Provides the radio administration state notifier.
///
/// Manages Meshtastic radio admin operations: reboot with confirmation,
/// GPS interval configuration (read-modify-write on PositionConfig),
/// admin command encoding with ADMIN_APP port to local node number,
/// 10-second command timeout with error display, and connected radio
/// node ID display in hex format.
///
/// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.9
final radioAdminNotifierProvider =
    StateNotifierProvider<RadioAdminNotifier, RadioAdminState>((ref) {
  final meshtasticService = ref.watch(meshtasticServiceProvider);
  final audioService = ref.watch(audioServiceProvider);

  return RadioAdminNotifier(
    meshtasticService: meshtasticService,
    audioService: audioService,
  );
});
