/// Integration tests for navigation between all screens.
///
/// Verifies that the app correctly navigates between main, weather,
/// entertainment, and config screens using the full provider chain
/// with fake data layer services.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/providers.dart';
import 'package:golf_cart_computer/main.dart';
import 'package:golf_cart_computer/presentation/screens/config_screen.dart';
import 'package:golf_cart_computer/presentation/screens/entertainment_screen.dart';
import 'package:golf_cart_computer/presentation/screens/main_screen.dart';
import 'package:golf_cart_computer/presentation/screens/weather_screen.dart';

import '../integration/test_fakes.dart';

void main() {
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

  /// Builds the app with proper Material wrapping for navigation tests.
  ///
  /// Uses named routes matching [AppRoutes] with each screen wrapped
  /// in a Scaffold to provide the required Material ancestor.
  Widget buildTestApp(List<Override> overrides) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        initialRoute: AppRoutes.main,
        routes: {
          AppRoutes.main: (_) => const Scaffold(body: MainScreen()),
          AppRoutes.weather: (_) => const WeatherScreen(),
          AppRoutes.entertainment: (_) => const EntertainmentScreen(),
          AppRoutes.config: (_) => const ConfigScreen(),
        },
      ),
    );
  }

  group('Screen Navigation Integration', () {
    testWidgets('main screen renders with navigation buttons',
        (tester) async {
      await tester.pumpWidget(buildTestApp(buildOverrides()));
      await tester.pumpAndSettle();

      // Verify main screen content
      expect(find.text('MPH'), findsOneWidget);
      expect(find.text('HDG'), findsOneWidget);

      // Verify navigation buttons are present
      expect(find.text('Weather'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Config'), findsOneWidget);
    });

    testWidgets('navigates from main to weather screen and back',
        (tester) async {
      await tester.pumpWidget(buildTestApp(buildOverrides()));
      await tester.pumpAndSettle();

      // Navigate to weather screen
      await tester.tap(find.text('Weather'));
      await tester.pumpAndSettle();

      // Verify we're on the weather screen
      expect(find.text('Weather Forecast'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on the main screen
      expect(find.text('MPH'), findsOneWidget);
    });

    testWidgets('navigates from main to entertainment screen and back',
        (tester) async {
      await tester.pumpWidget(buildTestApp(buildOverrides()));
      await tester.pumpAndSettle();

      // Navigate to entertainment screen
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Verify we're on the entertainment screen
      expect(find.text('Entertainment'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on the main screen
      expect(find.text('MPH'), findsOneWidget);
    });

    testWidgets('navigates from main to config screen and back',
        (tester) async {
      await tester.pumpWidget(buildTestApp(buildOverrides()));
      await tester.pumpAndSettle();

      // Navigate to config screen
      await tester.tap(find.text('Config'));
      await tester.pumpAndSettle();

      // Verify we're on the config screen
      expect(find.text('Configuration'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on the main screen
      expect(find.text('MPH'), findsOneWidget);
    });

    testWidgets('all screens are reachable within single tap from main',
        (tester) async {
      await tester.pumpWidget(buildTestApp(buildOverrides()));
      await tester.pumpAndSettle();

      // All navigation buttons should be visible on the main screen
      // (reachable within 1 tap per Requirement 13.14)
      expect(find.text('Weather'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Config'), findsOneWidget);
    });

    testWidgets('sequential navigation between all screens works correctly',
        (tester) async {
      await tester.pumpWidget(buildTestApp(buildOverrides()));
      await tester.pumpAndSettle();

      // Main → Weather → Main
      await tester.tap(find.text('Weather'));
      await tester.pumpAndSettle();
      expect(find.text('Weather Forecast'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('MPH'), findsOneWidget);

      // Main → Entertainment → Main
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.text('Entertainment'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('MPH'), findsOneWidget);

      // Main → Config → Main
      await tester.tap(find.text('Config'));
      await tester.pumpAndSettle();
      expect(find.text('Configuration'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('MPH'), findsOneWidget);
    });
  });
}
