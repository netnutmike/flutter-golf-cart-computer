import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/connection_notifier.dart';
import 'package:golf_cart_computer/application/config_notifier.dart';
import 'package:golf_cart_computer/application/main_notifier.dart';
import 'package:golf_cart_computer/application/providers.dart';
import 'package:golf_cart_computer/domain/models/user_preferences.dart';
import 'package:golf_cart_computer/presentation/screens/main_screen.dart';

void main() {
  Widget buildMainScreen({
    MainScreenState mainState = const MainScreenState(),
    DualConnectionState connectionState = const DualConnectionState(),
    ConfigState configState = const ConfigState(),
  }) {
    return ProviderScope(
      overrides: [
        mainNotifierProvider.overrideWith(
          (ref) => _FakeMainNotifier(mainState),
        ),
        connectionNotifierProvider.overrideWith(
          (ref) => _FakeConnectionNotifier(connectionState),
        ),
        configNotifierProvider.overrideWith(
          (ref) => _FakeConfigNotifier(configState),
        ),
      ],
      child: MaterialApp(
        home: const Scaffold(body: MainScreen()),
        routes: {
          '/weather': (_) => const Scaffold(
                body: Center(child: Text('Weather Screen')),
              ),
          '/entertainment': (_) => const Scaffold(
                body: Center(child: Text('Entertainment Screen')),
              ),
          '/config': (_) => const Scaffold(
                body: Center(child: Text('Configuration Screen')),
              ),
        },
      ),
    );
  }

  group('MainScreen - Speed and Heading', () {
    testWidgets('displays speed in mph', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(speedMph: 25),
      ));

      expect(find.text('25'), findsOneWidget);
      expect(find.text('MPH'), findsOneWidget);
    });

    testWidgets('displays cardinal direction heading', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(cardinalDirection: 'NNE'),
      ));

      expect(find.text('NNE'), findsOneWidget);
      expect(find.text('HDG'), findsOneWidget);
    });

    testWidgets('displays zero speed when stationary', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(speedMph: 0, headlightMode: 1),
      ));

      // Speed "0" and "MPH" label should be present
      expect(find.text('MPH'), findsOneWidget);
      // Find the speed text widget specifically (displayLarge style)
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.text('MPH'),
            matching: find.byType(Column),
          ).first,
          matching: find.text('0'),
        ),
        findsOneWidget,
      );
    });
  });

  group('MainScreen - Time and Date', () {
    testWidgets('displays time in 12-hour format', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(timeString: '2:30 PM'),
      ));

      expect(find.text('2:30 PM'), findsOneWidget);
    });

    testWidgets('displays date string', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(dateString: 'Mon, Jan 15'),
      ));

      expect(find.text('Mon, Jan 15'), findsOneWidget);
    });

    testWidgets('displays NO GPS when no GPS fix', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(dateString: 'NO GPS'),
      ));

      expect(find.text('NO GPS'), findsOneWidget);
    });
  });

  group('MainScreen - Telemetry Data', () {
    testWidgets('displays temperature with degree symbol', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(temperature: 72),
      ));

      expect(find.text('72°F'), findsOneWidget);
    });

    testWidgets('displays satellite count and HDOP', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(satelliteCount: 8, hdop: 1.5),
      ));

      expect(find.text('8/1.50'), findsOneWidget);
    });

    testWidgets('displays battery voltage', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(batteryVoltage: 48.2),
      ));

      expect(find.text('48.2V'), findsOneWidget);
    });

    testWidgets('displays fuel level as percentage', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(fuelLevel: 75.0),
      ));

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('displays headlight mode', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(headlightMode: 3),
      ));

      expect(find.text('3'), findsOneWidget);
    });
  });

  group('MainScreen - Odometer and Hours', () {
    testWidgets('displays total odometer with 1 decimal', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(totalMiles: 1234.5),
      ));

      expect(find.text('1234.5 mi'), findsOneWidget);
    });

    testWidgets('displays trip odometer with 1 decimal', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(tripMiles: 45.3),
      ));

      expect(find.text('45.3 mi'), findsOneWidget);
    });

    testWidgets('displays driving hours', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(hoursSinceService: 45.3),
      ));

      expect(find.text('45.3 hrs'), findsOneWidget);
    });
  });

  group('MainScreen - Sunrise/Sunset', () {
    testWidgets('displays sunrise time', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(sunriseTime: '6:45 AM'),
      ));

      expect(find.text('6:45 AM'), findsOneWidget);
    });

    testWidgets('displays sunset time', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(sunsetTime: '7:30 PM'),
      ));

      expect(find.text('7:30 PM'), findsOneWidget);
    });
  });

  group('MainScreen - Connection Status', () {
    testWidgets('shows connection indicators', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        connectionState: const DualConnectionState(
          meshtastic: ConnectionStatus.connected,
          gci: ConnectionStatus.disconnected,
        ),
      ));

      expect(find.text('Mesh'), findsOneWidget);
      expect(find.text('GCI'), findsOneWidget);
    });

    testWidgets('shows service-due indicator when service is due',
        (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(isServiceDue: true),
      ));

      expect(find.byIcon(Icons.build_circle), findsOneWidget);
    });

    testWidgets('hides service-due indicator when not due', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        mainState: const MainScreenState(isServiceDue: false),
      ));

      expect(find.byIcon(Icons.build_circle), findsNothing);
    });
  });

  group('MainScreen - Navigation', () {
    testWidgets('shows navigation buttons for Weather, Events, Config',
        (tester) async {
      await tester.pumpWidget(buildMainScreen());

      expect(find.text('Weather'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Config'), findsOneWidget);
    });

    testWidgets('tapping Weather navigates to weather screen', (tester) async {
      await tester.pumpWidget(buildMainScreen());

      await tester.tap(find.text('Weather'));
      await tester.pumpAndSettle();

      expect(find.text('Weather Screen'), findsOneWidget);
    });

    testWidgets('tapping Events navigates to entertainment screen',
        (tester) async {
      await tester.pumpWidget(buildMainScreen());

      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      expect(find.text('Entertainment Screen'), findsOneWidget);
    });

    testWidgets('tapping Config navigates to config screen', (tester) async {
      await tester.pumpWidget(buildMainScreen());

      await tester.tap(find.text('Config'));
      await tester.pumpAndSettle();

      expect(find.text('Configuration Screen'), findsOneWidget);
    });
  });

  group('MainScreen - Screen Flip', () {
    testWidgets('applies rotation when flipScreen is true', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        configState: const ConfigState(
          preferences: UserPreferences(flipScreen: true),
        ),
      ));

      final rotatedBox = tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 2);
    });

    testWidgets('no rotation when flipScreen is false', (tester) async {
      await tester.pumpWidget(buildMainScreen(
        configState: const ConfigState(
          preferences: UserPreferences(flipScreen: false),
        ),
      ));

      final rotatedBox = tester.widget<RotatedBox>(find.byType(RotatedBox));
      expect(rotatedBox.quarterTurns, 0);
    });
  });
}

// =============================================================================
// Fake Notifiers for Testing
// =============================================================================

class _FakeMainNotifier extends StateNotifier<MainScreenState>
    implements MainNotifier {
  _FakeMainNotifier(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeConnectionNotifier extends StateNotifier<DualConnectionState>
    implements ConnectionNotifier {
  _FakeConnectionNotifier(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeConfigNotifier extends StateNotifier<ConfigState>
    implements ConfigNotifier {
  _FakeConfigNotifier(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
