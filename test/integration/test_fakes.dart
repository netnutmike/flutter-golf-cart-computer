/// Fake implementations of data layer services for integration testing.
///
/// These fakes provide controllable behavior without real Bluetooth,
/// GPS, or persistence dependencies, enabling end-to-end testing of
/// the full provider chain from domain through application to presentation.
library;

import 'dart:async';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:golf_cart_computer/data/generated/meshtastic.dart'
    hide Position;
import 'package:golf_cart_computer/data/repositories/cache_repository.dart';
import 'package:golf_cart_computer/data/repositories/preferences_repository.dart';
import 'package:golf_cart_computer/data/services/background_service.dart';
import 'package:golf_cart_computer/data/services/location_service.dart';
import 'package:golf_cart_computer/data/services/meshtastic_service.dart';
import 'package:golf_cart_computer/data/services/telemetry_service.dart';
import 'package:golf_cart_computer/domain/audio_service.dart';
import 'package:golf_cart_computer/domain/models/connection_state.dart' as app;
import 'package:golf_cart_computer/domain/models/gci_message.dart';
import 'package:golf_cart_computer/domain/models/odometer_state.dart';
import 'package:golf_cart_computer/domain/models/sleep_state.dart';
import 'package:golf_cart_computer/domain/models/telemetry_data.dart';
import 'package:golf_cart_computer/domain/models/user_preferences.dart';
import 'package:golf_cart_computer/domain/sleep_manager.dart';

// =============================================================================
// Fake MeshtasticService
// =============================================================================

/// Fake implementation of [MeshtasticService] for integration testing.
///
/// Provides controllable streams and records method calls for verification.
class FakeMeshtasticService implements MeshtasticService {
  final StreamController<app.ConnectionState> _connectionStateController =
      StreamController<app.ConnectionState>.broadcast();
  final StreamController<String> _nodeIdController =
      StreamController<String>.broadcast();
  final StreamController<MeshPacket> _incomingPacketsController =
      StreamController<MeshPacket>.broadcast();

  /// Messages sent via [sendTextMessage].
  final List<SentTextMessage> sentTextMessages = [];

  /// Admin messages sent via [sendAdminMessage].
  final List<AdminMessage> sentAdminMessages = [];

  /// Position configs sent via [setPositionConfig].
  final List<Config_PositionConfig> sentPositionConfigs = [];

  /// Whether [connect] was called.
  bool connectCalled = false;

  /// Whether [disconnect] was called.
  bool disconnectCalled = false;

  /// Number of reboot calls.
  int rebootCallCount = 0;

  /// Stored position config (simulates handshake result).
  Config_PositionConfig? storedPositionConfig;

  @override
  Stream<app.ConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<String> get nodeId => _nodeIdController.stream;

  @override
  Stream<MeshPacket> get incomingPackets => _incomingPacketsController.stream;

  @override
  Future<void> connect(String deviceId) async {
    connectCalled = true;
    _connectionStateController.add(app.ConnectionState.connecting);
    _connectionStateController.add(app.ConnectionState.ready);
  }

  @override
  Future<void> disconnect() async {
    disconnectCalled = true;
    _connectionStateController.add(app.ConnectionState.disconnected);
  }

  @override
  Future<List<MeshtasticScanResult>> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    return [];
  }

  @override
  Future<void> sendTextMessage(String text, int destination, int channel) async {
    sentTextMessages.add(SentTextMessage(
      text: text,
      destination: destination,
      channel: channel,
    ));
  }

  @override
  Future<void> sendAdminMessage(AdminMessage message) async {
    sentAdminMessages.add(message);
  }

  @override
  Future<void> setPositionConfig(Config_PositionConfig config) async {
    sentPositionConfigs.add(config);
    storedPositionConfig = config;
  }

  @override
  Future<void> rebootRadio({int delaySeconds = 5}) async {
    rebootCallCount++;
  }

  // --- Test helpers ---

  /// Emits a connection state change.
  void emitConnectionState(app.ConnectionState state) {
    _connectionStateController.add(state);
  }

  /// Emits a node ID.
  void emitNodeId(String id) {
    _nodeIdController.add(id);
  }

  /// Emits an incoming mesh packet.
  void emitPacket(MeshPacket packet) {
    _incomingPacketsController.add(packet);
  }

  void dispose() {
    _connectionStateController.close();
    _nodeIdController.close();
    _incomingPacketsController.close();
  }
}

/// Record of a text message sent via [FakeMeshtasticService].
class SentTextMessage {
  final String text;
  final int destination;
  final int channel;

  const SentTextMessage({
    required this.text,
    required this.destination,
    required this.channel,
  });
}

// =============================================================================
// Fake TelemetryService
// =============================================================================

/// Fake implementation of [TelemetryService] for integration testing.
class FakeTelemetryService implements TelemetryService {
  final StreamController<app.ConnectionState> _connectionStateController =
      StreamController<app.ConnectionState>.broadcast();
  final StreamController<TelemetryData> _telemetryDataController =
      StreamController<TelemetryData>.broadcast();

  /// Whether [connect] was called.
  bool connectCalled = false;

  /// Whether [disconnect] was called.
  bool disconnectCalled = false;

  /// Heartbeat send count.
  int heartbeatCount = 0;

  /// GPS data payloads sent.
  final List<GciGpsPayload> sentGpsData = [];

  /// isHome values sent.
  final List<bool> sentIsHome = [];

  /// isDaytime values sent.
  final List<bool> sentIsDaytime = [];

  /// Whether pairing was initiated.
  bool pairCalled = false;

  @override
  Stream<app.ConnectionState> get connectionState =>
      _connectionStateController.stream;

  @override
  Stream<TelemetryData> get telemetryData => _telemetryDataController.stream;

  @override
  Future<void> connect(String deviceAddress) async {
    connectCalled = true;
    _connectionStateController.add(app.ConnectionState.ready);
  }

  @override
  Future<void> disconnect() async {
    disconnectCalled = true;
    _connectionStateController.add(app.ConnectionState.disconnected);
  }

  @override
  Future<void> sendHeartbeat() async {
    heartbeatCount++;
  }

  @override
  Future<void> sendGpsData(GciGpsPayload gpsData) async {
    sentGpsData.add(gpsData);
  }

  @override
  Future<void> sendIsHome(bool isHome) async {
    sentIsHome.add(isHome);
  }

  @override
  Future<void> sendIsDaytime(bool isDaytime) async {
    sentIsDaytime.add(isDaytime);
  }

  @override
  Future<void> pairNewDevice({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    pairCalled = true;
  }

  @override
  void dispose() {
    _connectionStateController.close();
    _telemetryDataController.close();
  }

  // --- Test helpers ---

  /// Emits a connection state change.
  void emitConnectionState(app.ConnectionState state) {
    _connectionStateController.add(state);
  }

  /// Emits telemetry data.
  void emitTelemetry(TelemetryData data) {
    _telemetryDataController.add(data);
  }
}

// =============================================================================
// Fake LocationService
// =============================================================================

/// Fake implementation of [LocationService] for integration testing.
class FakeLocationService implements LocationService {
  final StreamController<geo.Position> _positionController =
      StreamController<geo.Position>.broadcast();

  geo.Position? _currentPosition;

  @override
  Stream<geo.Position> get positionStream => _positionController.stream;

  @override
  Future<geo.Position?> get currentPosition async => _currentPosition;

  @override
  Future<geo.LocationPermission> requestPermission() async {
    return geo.LocationPermission.whileInUse;
  }

  @override
  Future<bool> get isServiceEnabled async => true;

  // --- Test helpers ---

  /// Sets the current position returned by [currentPosition].
  void setCurrentPosition(geo.Position position) {
    _currentPosition = position;
  }

  /// Emits a position update on the stream.
  void emitPosition(geo.Position position) {
    _currentPosition = position;
    _positionController.add(position);
  }

  void dispose() {
    _positionController.close();
  }
}

// =============================================================================
// Fake PreferencesRepository
// =============================================================================

/// Fake implementation of [PreferencesRepository] for integration testing.
class FakePreferencesRepository implements PreferencesRepository {
  /// The preferences to return from [loadPreferences].
  UserPreferences storedPreferences = const UserPreferences();

  /// Saved preference values (key → value).
  final Map<String, dynamic> savedValues = {};

  /// Persisted odometer values.
  double persistedTotalMiles = 0.0;
  double persistedTripMiles = 0.0;
  double persistedDrivingHours = 0.0;

  /// Whether [resetAllPreferences] was called.
  bool resetCalled = false;

  @override
  Future<UserPreferences> loadPreferences() async {
    return storedPreferences;
  }

  @override
  Future<void> savePreference(String key, dynamic value) async {
    savedValues[key] = value;
  }

  @override
  Future<void> resetAllPreferences() async {
    resetCalled = true;
    storedPreferences = const UserPreferences();
    savedValues.clear();
  }

  @override
  Future<void> persistOdometer(double totalMiles, double tripMiles) async {
    persistedTotalMiles = totalMiles;
    persistedTripMiles = tripMiles;
  }

  @override
  Future<OdometerState> loadOdometer() async {
    return OdometerState(
      totalMiles: persistedTotalMiles,
      tripMiles: persistedTripMiles,
      hoursSinceService: persistedDrivingHours,
    );
  }

  @override
  Future<void> persistDrivingHours(double tenthsOfHours) async {
    persistedDrivingHours = tenthsOfHours;
  }

  @override
  Future<double> loadDrivingHours() async {
    return persistedDrivingHours;
  }
}

// =============================================================================
// Fake CacheRepository
// =============================================================================

/// Fake implementation of [CacheRepository] for integration testing.
class FakeCacheRepository implements CacheRepository {
  CachedWeather? _cachedWeather;
  CachedVenue? _cachedVenue;

  /// Whether [clearStaleCache] was called.
  bool staleCacheCleared = false;

  @override
  Future<void> cacheWeatherData(
    String rawPacket,
    String timestamp,
    int dateYYYYMMDD,
  ) async {
    _cachedWeather = CachedWeather(
      rawPacket: rawPacket,
      timestamp: timestamp,
      dateYYYYMMDD: dateYYYYMMDD,
    );
  }

  @override
  Future<void> cacheVenueData(
    String rawPacket,
    String timestamp,
    int dateYYYYMMDD,
  ) async {
    _cachedVenue = CachedVenue(
      rawPacket: rawPacket,
      timestamp: timestamp,
      dateYYYYMMDD: dateYYYYMMDD,
    );
  }

  @override
  Future<CachedWeather?> loadCachedWeather() async {
    return _cachedWeather;
  }

  @override
  Future<CachedVenue?> loadCachedVenue() async {
    return _cachedVenue;
  }

  @override
  Future<void> clearStaleCache(int currentDateYYYYMMDD) async {
    staleCacheCleared = true;
    if (_cachedWeather != null &&
        _cachedWeather!.dateYYYYMMDD != currentDateYYYYMMDD) {
      _cachedWeather = null;
    }
    if (_cachedVenue != null &&
        _cachedVenue!.dateYYYYMMDD != currentDateYYYYMMDD) {
      _cachedVenue = null;
    }
  }

  // --- Test helpers ---

  /// Sets cached weather data for testing.
  void setCachedWeather(CachedWeather weather) {
    _cachedWeather = weather;
  }

  /// Sets cached venue data for testing.
  void setCachedVenue(CachedVenue venue) {
    _cachedVenue = venue;
  }
}

// =============================================================================
// Fake BackgroundService
// =============================================================================

/// Fake implementation of [BackgroundService] for integration testing.
class FakeBackgroundService implements BackgroundService {
  final StreamController<bool> _backgroundStateController =
      StreamController<bool>.broadcast();

  bool foregroundServiceStarted = false;
  bool foregroundServiceStopped = false;

  @override
  Future<void> startForegroundService() async {
    foregroundServiceStarted = true;
  }

  @override
  Future<void> stopForegroundService() async {
    foregroundServiceStopped = true;
  }

  @override
  Stream<bool> get isRunningInBackground => _backgroundStateController.stream;

  @override
  void dispose() {
    _backgroundStateController.close();
  }

  // --- Test helpers ---

  /// Emits a background state change.
  void emitBackgroundState(bool isBackground) {
    _backgroundStateController.add(isBackground);
  }
}

// =============================================================================
// Fake AudioService
// =============================================================================

/// Fake implementation of [AudioService] for integration testing.
///
/// Records all tone playback calls for verification.
class FakeAudioService implements AudioService {
  final List<String> playedTones = [];
  int _volume = 10;

  @override
  Future<void> playStartupTone() async {
    playedTones.add('startup');
  }

  @override
  Future<void> playMessageNotification() async {
    playedTones.add('messageNotification');
  }

  @override
  Future<void> playAlert() async {
    playedTones.add('alert');
  }

  @override
  Future<void> playConfirmation() async {
    playedTones.add('confirmation');
  }

  @override
  Future<void> playClick() async {
    playedTones.add('click');
  }

  @override
  Future<void> playError() async {
    playedTones.add('error');
  }

  @override
  void setVolume(int level) {
    _volume = level.clamp(0, 20);
  }

  @override
  int get volume => _volume;

  @override
  void dispose() {}
}


// =============================================================================
// Fake SleepManager
// =============================================================================

/// Fake implementation of [SleepManager] for integration testing.
///
/// Does not start any timers, avoiding pending timer issues in tests.
class FakeSleepManager implements SleepManager {
  final StreamController<OperatingMode> _modeController =
      StreamController<OperatingMode>.broadcast();

  OperatingMode _currentMode = OperatingMode.startupGrace;

  @override
  Stream<OperatingMode> get operatingMode => _modeController.stream;

  @override
  OperatingMode get currentMode => _currentMode;

  @override
  void onGciConnected() {
    _currentMode = OperatingMode.gciMode;
    _modeController.add(_currentMode);
  }

  @override
  void onGciDisconnected() {
    _currentMode = OperatingMode.standaloneMode;
    _modeController.add(_currentMode);
  }

  @override
  void onGracePeriodExpired() {
    _currentMode = OperatingMode.standaloneMode;
    _modeController.add(_currentMode);
  }

  @override
  void dispose() {
    _modeController.close();
  }
}
