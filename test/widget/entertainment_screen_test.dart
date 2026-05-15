import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/application/entertainment_notifier.dart';
import 'package:golf_cart_computer/application/providers.dart';
import 'package:golf_cart_computer/domain/models/entertainment_data.dart';
import 'package:golf_cart_computer/presentation/screens/entertainment_screen.dart';

void main() {
  Widget buildEntertainmentScreen({
    EntertainmentState entertainmentState = const EntertainmentState(),
  }) {
    return ProviderScope(
      overrides: [
        entertainmentNotifierProvider.overrideWith(
          (ref) => _FakeEntertainmentNotifier(entertainmentState),
        ),
      ],
      child: const MaterialApp(
        home: EntertainmentScreen(),
      ),
    );
  }

  group('EntertainmentScreen - Empty State', () {
    testWidgets('displays empty state when no data available', (tester) async {
      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: const EntertainmentState(data: null),
      ));

      expect(find.text('No entertainment data available'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy), findsOneWidget);
    });

    testWidgets('shows waiting message', (tester) async {
      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: const EntertainmentState(data: null),
      ));

      expect(
        find.text('Waiting for venue/event data...'),
        findsOneWidget,
      );
    });
  });

  group('EntertainmentScreen - Loading State', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: const EntertainmentState(isLoading: true),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('EntertainmentScreen - With Data', () {
    final testEntertainmentData = EntertainmentData(
      venues: const [
        VenueEvent(venueName: 'Spanish Springs', eventName: 'Jazz Night'),
        VenueEvent(venueName: 'Lake Sumter', eventName: 'Rock Band'),
        VenueEvent(venueName: 'Brownwood', eventName: 'Country Music'),
      ],
      receivedTimestamp: '5:30 PM',
      isStored: false,
    );

    testWidgets('displays venue names in table', (tester) async {
      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: EntertainmentState(data: testEntertainmentData),
      ));

      expect(find.text('Spanish Springs'), findsOneWidget);
      expect(find.text('Lake Sumter'), findsOneWidget);
      expect(find.text('Brownwood'), findsOneWidget);
    });

    testWidgets('displays event names in table', (tester) async {
      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: EntertainmentState(data: testEntertainmentData),
      ));

      expect(find.text('Jazz Night'), findsOneWidget);
      expect(find.text('Rock Band'), findsOneWidget);
      expect(find.text('Country Music'), findsOneWidget);
    });

    testWidgets('displays table headers', (tester) async {
      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: EntertainmentState(data: testEntertainmentData),
      ));

      expect(find.text('Venue'), findsOneWidget);
      expect(find.text('Event'), findsOneWidget);
    });

    testWidgets('displays received timestamp', (tester) async {
      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: EntertainmentState(data: testEntertainmentData),
      ));

      expect(find.text('Received: 5:30 PM'), findsOneWidget);
    });

    testWidgets('does not show stored indicator for live data',
        (tester) async {
      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: EntertainmentState(data: testEntertainmentData),
      ));

      expect(find.text('(stored)'), findsNothing);
    });

    testWidgets('shows stored indicator for cached data', (tester) async {
      final storedData = EntertainmentData(
        venues: testEntertainmentData.venues,
        receivedTimestamp: '5:30 PM',
        isStored: true,
      );

      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: EntertainmentState(data: storedData),
      ));

      expect(find.text('(stored)'), findsOneWidget);
    });
  });

  group('EntertainmentScreen - New Data Indicator', () {
    testWidgets('shows new data indicator when flag is true', (tester) async {
      final data = EntertainmentData(
        venues: const [
          VenueEvent(venueName: 'Test Venue', eventName: 'Test Event'),
        ],
        receivedTimestamp: '5:30 PM',
        isStored: false,
      );

      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: EntertainmentState(
          data: data,
          showNewDataIndicator: true,
        ),
      ));

      expect(find.text('new data received'), findsOneWidget);
    });

    testWidgets('hides new data indicator when flag is false', (tester) async {
      final data = EntertainmentData(
        venues: const [
          VenueEvent(venueName: 'Test Venue', eventName: 'Test Event'),
        ],
        receivedTimestamp: '5:30 PM',
        isStored: false,
      );

      await tester.pumpWidget(buildEntertainmentScreen(
        entertainmentState: EntertainmentState(
          data: data,
          showNewDataIndicator: false,
        ),
      ));

      expect(find.text('new data received'), findsNothing);
    });
  });

  group('EntertainmentScreen - Navigation', () {
    testWidgets('has app bar with title', (tester) async {
      await tester.pumpWidget(buildEntertainmentScreen());

      expect(find.text('Entertainment'), findsOneWidget);
    });

    testWidgets('has back button that pops navigation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            entertainmentNotifierProvider.overrideWith(
              (ref) => _FakeEntertainmentNotifier(
                const EntertainmentState(),
              ),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EntertainmentScreen(),
                    ),
                  ),
                  child: const Text('Go to Entertainment'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to entertainment screen
      await tester.tap(find.text('Go to Entertainment'));
      await tester.pumpAndSettle();

      expect(find.text('Entertainment'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Go to Entertainment'), findsOneWidget);
    });
  });
}

// =============================================================================
// Fake Notifier for Testing
// =============================================================================

class _FakeEntertainmentNotifier extends StateNotifier<EntertainmentState>
    implements EntertainmentNotifier {
  _FakeEntertainmentNotifier(super.initialState);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
