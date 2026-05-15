/// Integration tests for app startup initialization flow.
///
/// Verifies that the full provider chain initializes correctly from
/// data layer services through domain logic to application state,
/// using fake implementations of data layer services.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/connection_notifier.dart';
import 'package:golf_cart_computer/application/providers.dart';
import 'package:golf_cart_computer/domain/models/telemetry_data.dart';
import 'package:golf_cart_computer/domain/models/user_preferences.dart';

import '../integration/test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the permission_handler method channel to avoid platform errors.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async {
        // Return "granted" (1) for all permission checks and requests.
        if (methodCall.method == 'checkPermissionStatus') {
          return 1; // PermissionStatus.granted
        }
        if (methodCall.method == 'requestPermissions') {
          // Return a map of permission index → status (granted = 1)
          final permissions = methodCall.arguments as List<dynamic>;
          final result = <int, int>{};
          for (final perm in permissions) {
            result[perm as int] = 1;
          }
          return result;
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      null,
    );
  });
  group('App Startup Integration', () {
    late FakeMeshtasticService fakeMeshtastic;
    late FakeTelemetryService fakeTelemetry;
    late FakeLocationService fakeLocation;
    late FakePreferencesRepository fakePreferences;
    late FakeCacheRepository fakeCache;
    late FakeBackgroundService fakeBackground;
    late FakeAudioService fakeAudio;

    setUp(() {
      fakeMeshtastic = FakeMeshtasticService();
      fakeTelemetry = FakeTelemetryService();
      fakeLocation = FakeLocationService();
      fakePreferences = FakePreferencesRepository();
      fakeCache = FakeCacheRepository();
      fakeBackground = FakeBackgroundService();
      fakeAudio = FakeAudioService();
    });

    List<Override> buildOverrides() {
      return [
        meshtasticServiceProvider.overrideWithValue(fakeMeshtastic),
        telemetryServiceProvider.overrideWithValue(fakeTelemetry),
        locationServiceProvider.overrideWithValue(fakeLocation),
        preferencesRepositoryProvider.overrideWithValue(fakePreferences),
        cacheRepositoryProvider.overrideWithValue(fakeCache),
        backgroundServiceProvider.overrideWithValue(fakeBackground),
        audioServiceProvider.overrideWithValue(fakeAudio),
      ];
    }

    test('provider chain initializes data layer providers correctly', () {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Data layer providers should resolve to our fakes
      final meshtastic = container.read(meshtasticServiceProvider);
      expect(meshtastic, isA<FakeMeshtasticService>());

      final telemetry = container.read(telemetryServiceProvider);
      expect(telemetry, isA<FakeTelemetryService>());

      final location = container.read(locationServiceProvider);
      expect(location, isA<FakeLocationService>());

      final preferences = container.read(preferencesRepositoryProvider);
      expect(preferences, isA<FakePreferencesRepository>());

      final cache = container.read(cacheRepositoryProvider);
      expect(cache, isA<FakeCacheRepository>());
    });

    test('provider chain initializes domain layer providers correctly', () {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Domain layer providers should resolve without error
      final speedFilter = container.read(speedFilterProvider);
      expect(speedFilter, isNotNull);

      final gpsProcessor = container.read(gpsProcessorProvider);
      expect(gpsProcessor, isNotNull);

      final odometerManager = container.read(odometerManagerProvider);
      expect(odometerManager, isNotNull);

      final serviceReminder = container.read(serviceReminderProvider);
      expect(serviceReminder, isNotNull);

      final hotPacketParser = container.read(hotPacketParserProvider);
      expect(hotPacketParser, isNotNull);

      final sleepManager = container.read(sleepManagerProvider);
      expect(sleepManager, isNotNull);

      final brightnessManager = container.read(brightnessManagerProvider);
      expect(brightnessManager, isNotNull);

      final geofenceManager = container.read(geofenceManagerProvider);
      expect(geofenceManager, isNotNull);
    });

    test('application layer notifiers initialize with default state', () {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // MainNotifier should have default state
      final mainState = container.read(mainNotifierProvider);
      expect(mainState.speedMph, 0);
      expect(mainState.cardinalDirection, 'N');
      expect(mainState.dateString, 'NO GPS');
      expect(mainState.timeString, '--:-- --');
      expect(mainState.totalMiles, 0.0);
      expect(mainState.tripMiles, 0.0);
      expect(mainState.hoursSinceService, 0.0);
      expect(mainState.batteryVoltage, 0.0);
      expect(mainState.fuelLevel, 0.0);
      expect(mainState.temperature, 0);
      expect(mainState.headlightMode, 0);
      expect(mainState.isAtHome, false);
      expect(mainState.isDimmed, false);

      // ConnectionNotifier should start disconnected
      final connectionState = container.read(connectionNotifierProvider);
      expect(connectionState.meshtastic, ConnectionStatus.disconnected);
      expect(connectionState.gci, ConnectionStatus.disconnected);
    });

    test('preferences load correctly into config notifier', () async {
      // Set up preferences with custom values
      fakePreferences.storedPreferences = const UserPreferences(
        dayBrightness: 9,
        nightBrightness: 2,
        speakerVolume: 15,
        serviceIntervalHours: 200,
        temperatureOffset: -3,
        homeFenceRadiusMeters: 1000,
      );

      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // ConfigNotifier initializes asynchronously
      final configNotifier = container.read(configNotifierProvider.notifier);
      await configNotifier.initialize();

      final configState = container.read(configNotifierProvider);
      expect(configState.preferences.dayBrightness, 9);
      expect(configState.preferences.nightBrightness, 2);
      expect(configState.preferences.speakerVolume, 15);
      expect(configState.preferences.serviceIntervalHours, 200);
      expect(configState.preferences.temperatureOffset, -3);
      expect(configState.preferences.homeFenceRadiusMeters, 1000);
    });

    test('telemetry data flows from service through to main state', () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Read the main notifier to activate subscriptions
      container.read(mainNotifierProvider);

      // Emit telemetry data from the fake service
      fakeTelemetry.emitTelemetry(TelemetryData(
        headlightMode: 2,
        outdoorLuminosity: 500,
        airTemperature: 75.0,
        batteryVoltage: 48.5,
        fuelLevel: 80.0,
        lastUpdated: DateTime.now(),
      ));

      // Allow stream to propagate
      await Future<void>.delayed(Duration.zero);

      final mainState = container.read(mainNotifierProvider);
      expect(mainState.batteryVoltage, 48.5);
      expect(mainState.fuelLevel, 80.0);
      expect(mainState.temperature, 75);
      expect(mainState.headlightMode, 2);
    });

    test('connection notifier initializes with persisted device IDs',
        () async {
      // Set up preferences with persisted device IDs
      fakePreferences.storedPreferences = const UserPreferences(
        meshtasticEnabled: true,
        meshtasticDeviceId: 'test-device-123',
        gciDeviceAddress: 'AA:BB:CC:DD:EE:FF',
      );

      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Initialize the connection notifier (simulates app startup)
      final connectionNotifier =
          container.read(connectionNotifierProvider.notifier);
      await connectionNotifier.initialize();

      // Verify connection attempts were made
      expect(fakeMeshtastic.connectCalled, true);
      expect(fakeTelemetry.connectCalled, true);
    });

    test(
        'connection notifier does not connect when meshtastic is disabled',
        () async {
      fakePreferences.storedPreferences = const UserPreferences(
        meshtasticEnabled: false,
        meshtasticDeviceId: 'test-device-123',
        gciDeviceAddress: null,
      );

      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      final connectionNotifier =
          container.read(connectionNotifierProvider.notifier);
      await connectionNotifier.initialize();

      // Meshtastic should not connect when disabled
      expect(fakeMeshtastic.connectCalled, false);
      // GCI should not connect when no address is persisted
      expect(fakeTelemetry.connectCalled, false);
    });

    test('weather notifier initializes and subscribes to packets', () {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Weather notifier should initialize without error
      final weatherState = container.read(weatherNotifierProvider);
      expect(weatherState.weatherData, isNull);
      expect(weatherState.showNewDataIndicator, false);
    });

    test('entertainment notifier initializes and subscribes to packets',
        () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Entertainment notifier should initialize without error
      container.read(entertainmentNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(entertainmentNotifierProvider);
      expect(state.data, isNull);
      expect(state.isLoading, false);
    });
  });
}
