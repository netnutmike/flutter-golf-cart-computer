/// Integration tests for data flow from domain layer through application
/// layer to presentation.
///
/// Verifies that the full provider chain works correctly: data layer services
/// emit data, domain processors transform it, application notifiers update
/// state, and presentation widgets reflect the changes.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/connection_notifier.dart';
import 'package:golf_cart_computer/application/main_notifier.dart';
import 'package:golf_cart_computer/application/providers.dart';
import 'package:golf_cart_computer/data/generated/meshtastic.dart' hide Position;
import 'package:golf_cart_computer/data/repositories/cache_repository.dart';
import 'package:golf_cart_computer/domain/models/connection_state.dart' as app;
import 'package:golf_cart_computer/domain/models/telemetry_data.dart';

import '../integration/test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      sleepManagerProvider.overrideWithValue(FakeSleepManager()),
    ];
  }

  group('Telemetry Data Flow', () {
    test(
        'telemetry data flows from TelemetryService through MainNotifier to UI',
        () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Activate the main notifier to start subscriptions
      container.read(mainNotifierProvider);

      // Emit telemetry data
      fakeTelemetry.emitTelemetry(TelemetryData(
        headlightMode: 3,
        outdoorLuminosity: 800,
        airTemperature: 82.0,
        batteryVoltage: 47.8,
        fuelLevel: 65.0,
        lastUpdated: DateTime.now(),
      ));

      // Allow stream to propagate
      await Future<void>.delayed(Duration.zero);

      final state = container.read(mainNotifierProvider);
      expect(state.batteryVoltage, 47.8);
      expect(state.fuelLevel, 65.0);
      expect(state.temperature, 82);
      expect(state.headlightMode, 3);
    });

    test('temperature offset is applied to telemetry data', () async {
      final container = ProviderContainer(overrides: [
        ...buildOverrides(),
        // Override mainNotifier to use the temperature offset
        mainNotifierProvider.overrideWith((ref) {
          return MainNotifier(
            gpsProcessor: ref.watch(gpsProcessorProvider),
            odometerManager: ref.watch(odometerManagerProvider),
            serviceReminderManager: ref.watch(serviceReminderProvider),
            geofenceManager: ref.watch(geofenceManagerProvider),
            sleepManager: ref.watch(sleepManagerProvider),
            brightnessManager: ref.watch(brightnessManagerProvider),
            telemetryService: ref.watch(telemetryServiceProvider),
            meshtasticService: ref.watch(meshtasticServiceProvider),
            temperatureOffset: 5,
          );
        }),
      ]);
      addTearDown(container.dispose);

      // Activate the main notifier
      container.read(mainNotifierProvider);

      // Emit telemetry with temperature 70°F
      fakeTelemetry.emitTelemetry(TelemetryData(
        headlightMode: 0,
        outdoorLuminosity: 0,
        airTemperature: 70.0,
        batteryVoltage: 48.0,
        fuelLevel: 50.0,
        lastUpdated: DateTime.now(),
      ));

      await Future<void>.delayed(Duration.zero);

      final state = container.read(mainNotifierProvider);
      // 70 + 5 offset = 75
      expect(state.temperature, 75);
    });
  });

  group('Connection State Flow', () {
    test(
        'Meshtastic connection state flows from service to ConnectionNotifier',
        () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Activate the connection notifier
      container.read(connectionNotifierProvider);

      // Emit connection state change
      fakeMeshtastic.emitConnectionState(app.ConnectionState.connecting);
      await Future<void>.delayed(Duration.zero);

      var state = container.read(connectionNotifierProvider);
      expect(state.meshtastic, ConnectionStatus.connecting);

      // Emit ready state
      fakeMeshtastic.emitConnectionState(app.ConnectionState.ready);
      await Future<void>.delayed(Duration.zero);

      state = container.read(connectionNotifierProvider);
      expect(state.meshtastic, ConnectionStatus.connected);
    });

    test('GCI connection state flows from service to ConnectionNotifier',
        () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Activate the connection notifier
      container.read(connectionNotifierProvider);

      // Emit GCI connection state
      fakeTelemetry.emitConnectionState(app.ConnectionState.ready);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(connectionNotifierProvider);
      expect(state.gci, ConnectionStatus.connected);
    });

    test('reconnecting state is correctly mapped', () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      container.read(connectionNotifierProvider);

      fakeMeshtastic.emitConnectionState(app.ConnectionState.reconnecting);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(connectionNotifierProvider);
      expect(state.meshtastic, ConnectionStatus.reconnecting);
    });
  });

  group('Weather Data Flow', () {
    test(
        'weather HoT packet flows from MeshtasticService through parser to WeatherNotifier',
        () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Activate the weather notifier
      container.read(weatherNotifierProvider);

      // Create a valid weather HoT packet
      const weatherPacket =
          '|#01#85#10am,sunny,87,0.0#11am,cloud,88,20.0#12pm,rain,82,60.0#1pm,storm,79,80.0#';

      // Build a MeshPacket with the weather text
      final packet = MeshPacket(
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: Uint8List.fromList(utf8.encode(weatherPacket)),
        ),
      );

      // Emit the packet
      fakeMeshtastic.emitPacket(packet);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(weatherNotifierProvider);
      expect(state.weatherData, isNotNull);
      expect(state.weatherData!.currentTemp, 85);
      expect(state.weatherData!.forecasts.length, 4);
      expect(state.weatherData!.forecasts[0].hourLabel, '10am');
      expect(state.weatherData!.forecasts[0].temperature, 87);
      // Precipitation 0.0 should be cleared to empty string
      expect(state.weatherData!.forecasts[0].precipitation, '');
      expect(state.weatherData!.forecasts[1].precipitation, '20.0');
      expect(state.weatherData!.isStored, false);
    });

    test('weather data is cached after reception', () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      container.read(weatherNotifierProvider);

      const weatherPacket =
          '|#01#72#9am,clear,74,0.0#10am,cloud,76,10.0#11am,rain,73,40.0#12pm,sun,78,0.0#';

      final packet = MeshPacket(
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: Uint8List.fromList(utf8.encode(weatherPacket)),
        ),
      );

      fakeMeshtastic.emitPacket(packet);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Verify data was cached
      final cached = await fakeCache.loadCachedWeather();
      expect(cached, isNotNull);
      expect(cached!.rawPacket, weatherPacket);
    });

    test('cached weather data is restored on startup if same day', () async {
      // Set up cached weather for today
      final now = DateTime.now();
      final todayDate = now.year * 10000 + now.month * 100 + now.day;

      fakeCache.setCachedWeather(CachedWeather(
        rawPacket:
            '|#01#90#2pm,sun,92,0.0#3pm,cloud,89,15.0#4pm,rain,85,50.0#5pm,clear,88,0.0#',
        timestamp: '1:30 PM',
        dateYYYYMMDD: todayDate,
      ));

      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Activate weather notifier (triggers cache load)
      container.read(weatherNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(weatherNotifierProvider);
      expect(state.weatherData, isNotNull);
      expect(state.weatherData!.currentTemp, 90);
      expect(state.weatherData!.isStored, true);
      expect(state.weatherData!.receivedTimestamp, '1:30 PM');
    });

    test('stale cached weather data is not restored', () async {
      // Set up cached weather for yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDate =
          yesterday.year * 10000 + yesterday.month * 100 + yesterday.day;

      fakeCache.setCachedWeather(CachedWeather(
        rawPacket:
            '|#01#90#2pm,sun,92,0.0#3pm,cloud,89,15.0#4pm,rain,85,50.0#5pm,clear,88,0.0#',
        timestamp: '1:30 PM',
        dateYYYYMMDD: yesterdayDate,
      ));

      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      container.read(weatherNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(weatherNotifierProvider);
      expect(state.weatherData, isNull);
    });
  });

  group('Entertainment Data Flow', () {
    test(
        'venue/event HoT packet flows from MeshtasticService through parser to EntertainmentNotifier',
        () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      // Activate the entertainment notifier
      container.read(entertainmentNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Create a valid venue/event HoT packet
      const venuePacket =
          '|#02#Katie Belles,Live Band#Brownwood Paddock,DJ Night#';

      final packet = MeshPacket(
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: Uint8List.fromList(utf8.encode(venuePacket)),
        ),
      );

      fakeMeshtastic.emitPacket(packet);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(entertainmentNotifierProvider);
      expect(state.data, isNotNull);
      expect(state.data!.venues.length, 2);
      expect(state.data!.venues[0].venueName, 'Katie Belles');
      expect(state.data!.venues[0].eventName, 'Live Band');
      expect(state.data!.venues[1].venueName, 'Brownwood Paddock');
      expect(state.data!.venues[1].eventName, 'DJ Night');
      expect(state.data!.isStored, false);
    });

    test('venue data with commas in event name parses correctly', () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      container.read(entertainmentNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Event name contains a comma
      const venuePacket = '|#02#The Range,Rock, Blues, and Jazz#';

      final packet = MeshPacket(
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: Uint8List.fromList(utf8.encode(venuePacket)),
        ),
      );

      fakeMeshtastic.emitPacket(packet);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(entertainmentNotifierProvider);
      expect(state.data, isNotNull);
      expect(state.data!.venues.length, 1);
      expect(state.data!.venues[0].venueName, 'The Range');
      // First comma separates venue from event; rest are part of event name
      expect(state.data!.venues[0].eventName, 'Rock, Blues, and Jazz');
    });
  });

  group('Audio Feedback Flow', () {
    test('alert tone plays when new weather data is received', () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      container.read(weatherNotifierProvider);

      const weatherPacket =
          '|#01#85#10am,sunny,87,0.0#11am,cloud,88,20.0#12pm,rain,82,60.0#1pm,storm,79,80.0#';

      final packet = MeshPacket(
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: Uint8List.fromList(utf8.encode(weatherPacket)),
        ),
      );

      fakeMeshtastic.emitPacket(packet);
      await Future<void>.delayed(Duration.zero);

      expect(fakeAudio.playedTones, contains('alert'));
    });

    test('alert tone plays when new venue data is received', () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      container.read(entertainmentNotifierProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      const venuePacket = '|#02#Venue A,Event A#';

      final packet = MeshPacket(
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: Uint8List.fromList(utf8.encode(venuePacket)),
        ),
      );

      fakeMeshtastic.emitPacket(packet);
      await Future<void>.delayed(Duration.zero);

      expect(fakeAudio.playedTones, contains('alert'));
    });
  });

  group('Invalid Data Handling', () {
    test('invalid weather packet is discarded without crashing', () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      container.read(weatherNotifierProvider);

      // Invalid packet: wrong delimiter count
      const invalidPacket = '|#01#85#bad_data#';

      final packet = MeshPacket(
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: Uint8List.fromList(utf8.encode(invalidPacket)),
        ),
      );

      fakeMeshtastic.emitPacket(packet);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(weatherNotifierProvider);
      expect(state.weatherData, isNull);
    });

    test('non-HoT text messages are ignored by weather notifier', () async {
      final container = ProviderContainer(overrides: buildOverrides());
      addTearDown(container.dispose);

      container.read(weatherNotifierProvider);

      // Regular text message (not a HoT packet)
      const textMessage = 'Hello from the mesh!';

      final packet = MeshPacket(
        decoded: Data(
          portnum: PortNum.TEXT_MESSAGE_APP,
          payload: Uint8List.fromList(utf8.encode(textMessage)),
        ),
      );

      fakeMeshtastic.emitPacket(packet);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(weatherNotifierProvider);
      expect(state.weatherData, isNull);
    });
  });
}
