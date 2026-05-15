import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/config_notifier.dart';
import 'package:golf_cart_computer/application/providers.dart';
import 'package:golf_cart_computer/domain/models/user_preferences.dart';
import 'package:golf_cart_computer/presentation/screens/config_screen.dart';

void main() {
  Widget buildConfigScreen({
    ConfigState configState = const ConfigState(),
  }) {
    return ProviderScope(
      overrides: [
        configNotifierProvider.overrideWith(
          (ref) => _FakeConfigNotifier(configState),
        ),
      ],
      child: const MaterialApp(
        home: ConfigScreen(),
      ),
    );
  }

  group('ConfigScreen - App Bar', () {
    testWidgets('displays Configuration title', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      expect(find.text('Configuration'), findsOneWidget);
    });
  });

  group('ConfigScreen - Display Settings', () {
    testWidgets('shows Day Brightness slider', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(
          preferences: UserPreferences(dayBrightness: 7),
        ),
      ));

      expect(find.text('Day Brightness'), findsOneWidget);
    });

    testWidgets('shows Night Brightness slider', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(
          preferences: UserPreferences(nightBrightness: 3),
        ),
      ));

      expect(find.text('Night Brightness'), findsOneWidget);
    });

    testWidgets('shows Backlight Timeout spinner', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(
          preferences: UserPreferences(backlightTimeoutMinutes: 5),
        ),
      ));

      expect(find.text('Backlight Timeout'), findsOneWidget);
      expect(find.text('5 min'), findsOneWidget);
    });

    testWidgets('shows Flip Screen toggle', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      expect(find.text('Flip Screen'), findsOneWidget);
    });
  });

  group('ConfigScreen - Audio Settings', () {
    testWidgets('shows Speaker Volume slider', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      expect(find.text('Speaker Volume'), findsOneWidget);
    });
  });

  group('ConfigScreen - Sensor Settings', () {
    testWidgets('shows Temperature Offset spinner', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      expect(find.text('Temperature Offset'), findsOneWidget);
      expect(find.text('0 °F'), findsOneWidget);
    });
  });

  group('ConfigScreen - Service & Odometer', () {
    testWidgets('shows Service Interval spinner', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(
          preferences: UserPreferences(serviceIntervalHours: 100),
        ),
      ));

      expect(find.text('Service Interval'), findsOneWidget);
      expect(find.text('100 hrs'), findsOneWidget);
    });

    testWidgets('shows Reset Service Hours action', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      expect(find.text('Reset Service Hours'), findsOneWidget);
    });

    testWidgets('shows Reset Trip Odometer action', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      expect(find.text('Reset Trip Odometer'), findsOneWidget);
    });
  });

  group('ConfigScreen - Home Location', () {
    testWidgets('shows Geofence Radius spinner', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(
          preferences: UserPreferences(homeFenceRadiusMeters: 500),
        ),
      ));

      expect(find.text('Geofence Radius'), findsOneWidget);
      expect(find.text('500 m'), findsOneWidget);
    });

    testWidgets('shows Set Home and Clear Home buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      expect(find.text('Set Home'), findsOneWidget);
      expect(find.text('Clear Home'), findsOneWidget);
    });
  });

  group('ConfigScreen - Connections', () {
    testWidgets('shows GCI Pairing tile', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      expect(find.text('GCI Pairing'), findsOneWidget);
    });

    testWidgets('shows Meshtastic Radio toggle', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(isMeshtasticEnabled: false),
      ));

      expect(find.text('Meshtastic Radio'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('shows enabled state for Meshtastic', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(isMeshtasticEnabled: true),
      ));

      await tester.scrollUntilVisible(
        find.text('Enabled'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Enabled'), findsOneWidget);
    });

    testWidgets('shows pairing in progress state', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(isPairing: true),
      ));

      await tester.scrollUntilVisible(
        find.text('Pairing...'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Pairing...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ConfigScreen - System', () {
    testWidgets('shows Reset All Preferences action', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      await tester.scrollUntilVisible(
        find.text('Reset All Preferences'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Reset All Preferences'), findsOneWidget);
    });

    testWidgets('shows Restart App action', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      await tester.scrollUntilVisible(
        find.text('Restart App'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Restart App'), findsOneWidget);
    });
  });

  group('ConfigScreen - About', () {
    testWidgets('shows App Version', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(appVersion: '0.1.0'),
      ));

      await tester.scrollUntilVisible(
        find.text('App Version'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('0.1.0'), findsOneWidget);
    });

    testWidgets('shows Device ID', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(deviceId: 'abc123def456'),
      ));

      await tester.scrollUntilVisible(
        find.text('Device ID'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Device ID'), findsOneWidget);
      expect(find.text('abc123def456'), findsOneWidget);
    });
  });

  group('ConfigScreen - Error Display', () {
    testWidgets('shows error card when lastError is set', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(
          lastError: 'GPS is required to set home location',
        ),
      ));

      await tester.scrollUntilVisible(
        find.text('GPS is required to set home location'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(
        find.text('GPS is required to set home location'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('hides error card when lastError is null', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen(
        configState: const ConfigState(lastError: null),
      ));

      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });

  group('ConfigScreen - Confirmation Dialog', () {
    testWidgets('Reset Service Hours shows confirmation dialog',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildConfigScreen());

      await tester.tap(find.text('Reset Service Hours'));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'Are you sure you want to reset the service hour counter to zero?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });
  });
}

// =============================================================================
// Fake Notifier for Testing
// =============================================================================

class _FakeConfigNotifier extends StateNotifier<ConfigState>
    implements ConfigNotifier {
  _FakeConfigNotifier(super.initialState);

  @override
  bool get isHomeLocationSet =>
      state.preferences.homeLatitude != null &&
      state.preferences.homeLongitude != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
