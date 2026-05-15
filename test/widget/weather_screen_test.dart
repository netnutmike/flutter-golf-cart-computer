import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/providers.dart';
import 'package:golf_cart_computer/application/weather_notifier.dart';
import 'package:golf_cart_computer/domain/models/weather_data.dart';
import 'package:golf_cart_computer/presentation/screens/weather_screen.dart';

void main() {
  Widget buildWeatherScreen({
    WeatherState weatherState = const WeatherState(),
  }) {
    return ProviderScope(
      overrides: [
        weatherNotifierProvider.overrideWith(
          (ref) => _FakeWeatherNotifier(weatherState),
        ),
      ],
      child: const MaterialApp(
        home: WeatherScreen(),
      ),
    );
  }

  group('WeatherScreen - No Data', () {
    testWidgets('displays no data message when weather data is null',
        (tester) async {
      await tester.pumpWidget(buildWeatherScreen(
        weatherState: const WeatherState(weatherData: null),
      ));

      expect(find.text('No weather data available'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('shows informational text about Meshtastic', (tester) async {
      await tester.pumpWidget(buildWeatherScreen(
        weatherState: const WeatherState(weatherData: null),
      ));

      expect(
        find.textContaining('Weather data will appear when received'),
        findsOneWidget,
      );
    });
  });

  group('WeatherScreen - With Data', () {
    final testWeatherData = WeatherData(
      currentTemp: 85,
      forecasts: const [
        HourForecast(
          hourLabel: '10am',
          glyphCode: 'sunny',
          temperature: 87,
          precipitation: '',
        ),
        HourForecast(
          hourLabel: '11am',
          glyphCode: 'cloud',
          temperature: 88,
          precipitation: '20.0',
        ),
        HourForecast(
          hourLabel: '12pm',
          glyphCode: 'rain',
          temperature: 82,
          precipitation: '60.0',
        ),
        HourForecast(
          hourLabel: '1pm',
          glyphCode: 'storm',
          temperature: 79,
          precipitation: '80.0',
        ),
      ],
      receivedTimestamp: '2:35 PM',
      isStored: false,
    );

    testWidgets('displays current temperature prominently', (tester) async {
      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(weatherData: testWeatherData),
      ));

      expect(find.text('85°F'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
    });

    testWidgets('displays 4-hour forecast section', (tester) async {
      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(weatherData: testWeatherData),
      ));

      expect(find.text('4-Hour Forecast'), findsOneWidget);
    });

    testWidgets('displays forecast hour labels', (tester) async {
      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(weatherData: testWeatherData),
      ));

      expect(find.text('10am'), findsOneWidget);
      expect(find.text('11am'), findsOneWidget);
      expect(find.text('12pm'), findsOneWidget);
      expect(find.text('1pm'), findsOneWidget);
    });

    testWidgets('displays forecast temperatures', (tester) async {
      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(weatherData: testWeatherData),
      ));

      expect(find.text('87°F'), findsOneWidget);
      expect(find.text('88°F'), findsOneWidget);
      expect(find.text('82°F'), findsOneWidget);
      expect(find.text('79°F'), findsOneWidget);
    });

    testWidgets('displays precipitation when non-empty', (tester) async {
      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(weatherData: testWeatherData),
      ));

      expect(find.text('20.0%'), findsOneWidget);
      expect(find.text('60.0%'), findsOneWidget);
      expect(find.text('80.0%'), findsOneWidget);
    });

    testWidgets('displays received timestamp', (tester) async {
      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(weatherData: testWeatherData),
      ));

      expect(find.text('Received: 2:35 PM'), findsOneWidget);
    });

    testWidgets('does not show stored indicator for live data',
        (tester) async {
      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(weatherData: testWeatherData),
      ));

      expect(find.text('(stored)'), findsNothing);
    });

    testWidgets('shows stored indicator for cached data', (tester) async {
      final storedData = WeatherData(
        currentTemp: 85,
        forecasts: testWeatherData.forecasts,
        receivedTimestamp: '2:35 PM',
        isStored: true,
      );

      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(weatherData: storedData),
      ));

      expect(find.text('(stored)'), findsOneWidget);
    });
  });

  group('WeatherScreen - New Data Indicator', () {
    testWidgets('shows new data indicator when flag is true', (tester) async {
      final weatherData = WeatherData(
        currentTemp: 85,
        forecasts: const [
          HourForecast(
              hourLabel: '10am',
              glyphCode: 'sun',
              temperature: 87,
              precipitation: ''),
          HourForecast(
              hourLabel: '11am',
              glyphCode: 'sun',
              temperature: 88,
              precipitation: ''),
          HourForecast(
              hourLabel: '12pm',
              glyphCode: 'sun',
              temperature: 89,
              precipitation: ''),
          HourForecast(
              hourLabel: '1pm',
              glyphCode: 'sun',
              temperature: 90,
              precipitation: ''),
        ],
        receivedTimestamp: '2:35 PM',
      );

      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(
          weatherData: weatherData,
          showNewDataIndicator: true,
        ),
      ));

      expect(find.text('New data received'), findsOneWidget);
    });

    testWidgets('hides new data indicator when flag is false', (tester) async {
      final weatherData = WeatherData(
        currentTemp: 85,
        forecasts: const [
          HourForecast(
              hourLabel: '10am',
              glyphCode: 'sun',
              temperature: 87,
              precipitation: ''),
          HourForecast(
              hourLabel: '11am',
              glyphCode: 'sun',
              temperature: 88,
              precipitation: ''),
          HourForecast(
              hourLabel: '12pm',
              glyphCode: 'sun',
              temperature: 89,
              precipitation: ''),
          HourForecast(
              hourLabel: '1pm',
              glyphCode: 'sun',
              temperature: 90,
              precipitation: ''),
        ],
        receivedTimestamp: '2:35 PM',
      );

      await tester.pumpWidget(buildWeatherScreen(
        weatherState: WeatherState(
          weatherData: weatherData,
          showNewDataIndicator: false,
        ),
      ));

      expect(find.text('New data received'), findsNothing);
    });
  });

  group('WeatherScreen - Navigation', () {
    testWidgets('has app bar with title', (tester) async {
      await tester.pumpWidget(buildWeatherScreen());

      expect(find.text('Weather Forecast'), findsOneWidget);
    });

    testWidgets('has back button that pops navigation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherNotifierProvider.overrideWith(
              (ref) => _FakeWeatherNotifier(const WeatherState()),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const WeatherScreen(),
                    ),
                  ),
                  child: const Text('Go to Weather'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to weather screen
      await tester.tap(find.text('Go to Weather'));
      await tester.pumpAndSettle();

      expect(find.text('Weather Forecast'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Go to Weather'), findsOneWidget);
    });
  });
}

// =============================================================================
// Fake Notifier for Testing
// =============================================================================

class _FakeWeatherNotifier extends StateNotifier<WeatherState>
    implements WeatherNotifier {
  _FakeWeatherNotifier(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
