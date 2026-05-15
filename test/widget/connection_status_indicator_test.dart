import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/connection_notifier.dart';
import 'package:golf_cart_computer/application/providers.dart';
import 'package:golf_cart_computer/presentation/widgets/connection_status_indicator.dart';

void main() {
  Widget buildTestWidget({
    required DualConnectionState connectionState,
  }) {
    return ProviderScope(
      overrides: [
        connectionNotifierProvider.overrideWith(
          (ref) => _FakeConnectionNotifier(connectionState),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: DualConnectionStatusIndicator(),
        ),
      ),
    );
  }

  group('ConnectionStatusChip', () {
    testWidgets('displays device label and status text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusChip(
              deviceLabel: 'Mesh',
              status: ConnectionStatus.connected,
            ),
          ),
        ),
      );

      expect(find.text('Mesh'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
    });

    testWidgets('shows disconnected state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusChip(
              deviceLabel: 'GCI',
              status: ConnectionStatus.disconnected,
            ),
          ),
        ),
      );

      expect(find.text('GCI'), findsOneWidget);
      expect(find.text('Disconnected'), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_disabled), findsOneWidget);
    });

    testWidgets('shows connecting state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusChip(
              deviceLabel: 'Mesh',
              status: ConnectionStatus.connecting,
            ),
          ),
        ),
      );

      expect(find.text('Connecting'), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_searching), findsOneWidget);
    });

    testWidgets('shows reconnecting state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusChip(
              deviceLabel: 'GCI',
              status: ConnectionStatus.reconnecting,
            ),
          ),
        ),
      );

      expect(find.text('Reconnecting'), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_searching), findsOneWidget);
    });

    testWidgets('has minimum 48x48 touch target', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusChip(
              deviceLabel: 'Mesh',
              status: ConnectionStatus.connected,
            ),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(ConnectionStatusChip),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrainedBox.constraints.minHeight, 48);
      expect(constrainedBox.constraints.minWidth, 48);
    });

    testWidgets('provides semantic label for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatusChip(
              deviceLabel: 'Mesh',
              status: ConnectionStatus.connected,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ConnectionStatusChip));
      expect(semantics.label, contains('Mesh: Connected'));
    });
  });

  group('DualConnectionStatusIndicator', () {
    testWidgets('displays both Mesh and GCI indicators', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          connectionState: const DualConnectionState(
            meshtastic: ConnectionStatus.connected,
            gci: ConnectionStatus.disconnected,
          ),
        ),
      );

      expect(find.text('Mesh'), findsOneWidget);
      expect(find.text('GCI'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.text('Disconnected'), findsOneWidget);
    });

    testWidgets('shows independent states for each connection', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          connectionState: const DualConnectionState(
            meshtastic: ConnectionStatus.reconnecting,
            gci: ConnectionStatus.connecting,
          ),
        ),
      );

      expect(find.text('Reconnecting'), findsOneWidget);
      expect(find.text('Connecting'), findsOneWidget);
    });

    testWidgets('both disconnected by default', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          connectionState: const DualConnectionState(),
        ),
      );

      expect(find.text('Disconnected'), findsNWidgets(2));
    });
  });
}

/// A fake [ConnectionNotifier] that exposes a fixed state for testing.
class _FakeConnectionNotifier extends StateNotifier<DualConnectionState>
    implements ConnectionNotifier {
  _FakeConnectionNotifier(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
