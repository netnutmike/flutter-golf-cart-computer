import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/providers.dart';
import 'package:golf_cart_computer/main.dart';

import 'integration/test_fakes.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    final fakePreferences = FakePreferencesRepository();
    final fakeCache = FakeCacheRepository();
    final fakeMeshtastic = FakeMeshtasticService();
    final fakeTelemetry = FakeTelemetryService();
    final fakeLocation = FakeLocationService();
    final fakeBackground = FakeBackgroundService();
    final fakeAudio = FakeAudioService();

    // Suppress overflow errors in test environment (constrained 800x600 surface)
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.exceptionAsString();
      if (message.contains('overflowed')) return;
      originalOnError?.call(details);
    };

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesRepositoryProvider.overrideWithValue(fakePreferences),
          cacheRepositoryProvider.overrideWithValue(fakeCache),
          meshtasticServiceProvider.overrideWithValue(fakeMeshtastic),
          telemetryServiceProvider.overrideWithValue(fakeTelemetry),
          locationServiceProvider.overrideWithValue(fakeLocation),
          backgroundServiceProvider.overrideWithValue(fakeBackground),
          audioServiceProvider.overrideWithValue(fakeAudio),
          sleepManagerProvider.overrideWithValue(FakeSleepManager()),
        ],
        child: const GolfCartComputerApp(),
      ),
    );

    // Restore error handler
    FlutterError.onError = originalOnError;

    // The app should render the main screen without provider errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
