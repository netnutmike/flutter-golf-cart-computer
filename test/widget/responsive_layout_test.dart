/// Widget tests for the responsive layout system.
///
/// Tests breakpoint detection, orientation handling, and layout variant
/// selection across different screen sizes.
///
/// Requirements: 23.1, 23.2, 23.3, 23.4, 23.5, 23.9, 23.10
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:golf_cart_computer/presentation/widgets/responsive_layout.dart';

void main() {
  group('breakpointFromWidth', () {
    test('returns compact for width < 800', () {
      expect(breakpointFromWidth(799), ScreenBreakpoint.compact);
      expect(breakpointFromWidth(600), ScreenBreakpoint.compact);
      expect(breakpointFromWidth(320), ScreenBreakpoint.compact);
    });

    test('returns medium for width 800-1024', () {
      expect(breakpointFromWidth(800), ScreenBreakpoint.medium);
      expect(breakpointFromWidth(900), ScreenBreakpoint.medium);
      expect(breakpointFromWidth(1024), ScreenBreakpoint.medium);
    });

    test('returns expanded for width > 1024', () {
      expect(breakpointFromWidth(1025), ScreenBreakpoint.expanded);
      expect(breakpointFromWidth(1920), ScreenBreakpoint.expanded);
    });
  });

  group('orientationFromSize', () {
    test('returns landscape when width >= height', () {
      expect(orientationFromSize(1024, 768), LayoutOrientation.landscape);
      expect(orientationFromSize(800, 800), LayoutOrientation.landscape);
    });

    test('returns portrait when width < height', () {
      expect(orientationFromSize(600, 800), LayoutOrientation.portrait);
      expect(orientationFromSize(768, 1024), LayoutOrientation.portrait);
    });
  });

  group('ResponsiveLayoutData', () {
    test('convenience getters work correctly', () {
      final compact = ResponsiveLayoutData(
        breakpoint: ScreenBreakpoint.compact,
        orientation: LayoutOrientation.portrait,
        availableWidth: 600,
        availableHeight: 800,
      );
      expect(compact.isCompact, isTrue);
      expect(compact.isMedium, isFalse);
      expect(compact.isExpanded, isFalse);
      expect(compact.isPortrait, isTrue);
      expect(compact.isLandscape, isFalse);

      final expanded = ResponsiveLayoutData(
        breakpoint: ScreenBreakpoint.expanded,
        orientation: LayoutOrientation.landscape,
        availableWidth: 1920,
        availableHeight: 1080,
      );
      expect(expanded.isCompact, isFalse);
      expect(expanded.isMedium, isFalse);
      expect(expanded.isExpanded, isTrue);
      expect(expanded.isPortrait, isFalse);
      expect(expanded.isLandscape, isTrue);
    });
  });

  group('ResponsiveLayout widget', () {
    testWidgets('selects compact builder for narrow screens', (tester) async {
      // Set test surface to 600x800 (compact portrait).
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              builder: (_, __) => const Text('default'),
              compactBuilder: (_, __) => const Text('compact'),
              mediumBuilder: (_, __) => const Text('medium'),
              expandedBuilder: (_, __) => const Text('expanded'),
            ),
          ),
        ),
      );

      expect(find.text('compact'), findsOneWidget);
      expect(find.text('medium'), findsNothing);
      expect(find.text('expanded'), findsNothing);
    });

    testWidgets('selects medium builder for mid-size screens', (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              builder: (_, __) => const Text('default'),
              compactBuilder: (_, __) => const Text('compact'),
              mediumBuilder: (_, __) => const Text('medium'),
              expandedBuilder: (_, __) => const Text('expanded'),
            ),
          ),
        ),
      );

      expect(find.text('medium'), findsOneWidget);
      expect(find.text('compact'), findsNothing);
      expect(find.text('expanded'), findsNothing);
    });

    testWidgets('selects expanded builder for wide screens', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              builder: (_, __) => const Text('default'),
              compactBuilder: (_, __) => const Text('compact'),
              mediumBuilder: (_, __) => const Text('medium'),
              expandedBuilder: (_, __) => const Text('expanded'),
            ),
          ),
        ),
      );

      expect(find.text('expanded'), findsOneWidget);
      expect(find.text('compact'), findsNothing);
      expect(find.text('medium'), findsNothing);
    });

    testWidgets('falls back to default builder when specific is null',
        (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              builder: (_, __) => const Text('default'),
              // No compactBuilder provided
            ),
          ),
        ),
      );

      expect(find.text('default'), findsOneWidget);
    });

    testWidgets('provides correct layout data to builder', (tester) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      ResponsiveLayoutData? capturedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              builder: (_, layoutData) {
                capturedData = layoutData;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(capturedData, isNotNull);
      expect(capturedData!.breakpoint, ScreenBreakpoint.medium);
      expect(capturedData!.orientation, LayoutOrientation.landscape);
    });
  });

  group('ResponsiveLayout.oriented', () {
    testWidgets('selects portrait builder for portrait orientation',
        (tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout.oriented(
              portraitBuilder: (_, __) => const Text('portrait'),
              landscapeBuilder: (_, __) => const Text('landscape'),
            ),
          ),
        ),
      );

      expect(find.text('portrait'), findsOneWidget);
      expect(find.text('landscape'), findsNothing);
    });

    testWidgets('selects landscape builder for landscape orientation',
        (tester) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout.oriented(
              portraitBuilder: (_, __) => const Text('portrait'),
              landscapeBuilder: (_, __) => const Text('landscape'),
            ),
          ),
        ),
      );

      expect(find.text('landscape'), findsOneWidget);
      expect(find.text('portrait'), findsNothing);
    });

    testWidgets(
        'selects specific breakpoint+orientation builder when provided',
        (tester) async {
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout.oriented(
              portraitBuilder: (_, __) => const Text('portrait-default'),
              landscapeBuilder: (_, __) => const Text('landscape-default'),
              compactPortraitBuilder: (_, __) =>
                  const Text('compact-portrait'),
            ),
          ),
        ),
      );

      expect(find.text('compact-portrait'), findsOneWidget);
      expect(find.text('portrait-default'), findsNothing);
    });
  });

  group('CompactDashboardLayout', () {
    testWidgets('renders primary and secondary content', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactDashboardLayout(
              primaryContent: const Text('primary'),
              secondaryContent: const Text('secondary'),
              bottomNavigation: const Text('nav'),
            ),
          ),
        ),
      );

      expect(find.text('primary'), findsOneWidget);
      expect(find.text('secondary'), findsOneWidget);
      expect(find.text('nav'), findsOneWidget);
    });

    testWidgets('uses flex factors for relative sizing', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactDashboardLayout(
              primaryContent: const SizedBox(),
              secondaryContent: const SizedBox(),
            ),
          ),
        ),
      );

      // Verify Flexible widgets are present with correct flex values.
      final flexibles = tester.widgetList<Flexible>(find.byType(Flexible));
      final flexValues = flexibles.map((f) => f.flex).toList();
      expect(flexValues, contains(2));
      expect(flexValues, contains(3));
    });
  });

  group('MediumDashboardLayout', () {
    testWidgets('renders two columns', (tester) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediumDashboardLayout(
              leftColumn: const Text('left'),
              rightColumn: const Text('right'),
              bottomNavigation: const Text('nav'),
            ),
          ),
        ),
      );

      expect(find.text('left'), findsOneWidget);
      expect(find.text('right'), findsOneWidget);
      expect(find.text('nav'), findsOneWidget);
    });

    testWidgets('uses flex factors for column proportions', (tester) async {
      tester.view.physicalSize = const Size(900, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediumDashboardLayout(
              leftColumn: const SizedBox(),
              rightColumn: const SizedBox(),
            ),
          ),
        ),
      );

      // Verify Expanded widgets have correct flex values (55/45 split).
      final expandedWidgets =
          tester.widgetList<Expanded>(find.byType(Expanded));
      final flexValues = expandedWidgets.map((e) => e.flex).toList();
      expect(flexValues, contains(55));
      expect(flexValues, contains(45));
    });
  });

  group('ExpandedDashboardLayout', () {
    testWidgets('renders three columns', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandedDashboardLayout(
              leftColumn: const Text('left'),
              centerColumn: const Text('center'),
              rightColumn: const Text('right'),
              bottomNavigation: const Text('nav'),
            ),
          ),
        ),
      );

      expect(find.text('left'), findsOneWidget);
      expect(find.text('center'), findsOneWidget);
      expect(find.text('right'), findsOneWidget);
      expect(find.text('nav'), findsOneWidget);
    });

    testWidgets('uses flex factors for three-column proportions',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpandedDashboardLayout(
              leftColumn: const SizedBox(),
              centerColumn: const SizedBox(),
              rightColumn: const SizedBox(),
            ),
          ),
        ),
      );

      // Verify Expanded widgets have correct flex values (30/40/30 split).
      final expandedWidgets =
          tester.widgetList<Expanded>(find.byType(Expanded));
      final flexValues = expandedWidgets.map((e) => e.flex).toList();
      expect(flexValues.where((v) => v == 30).length, 2);
      expect(flexValues, contains(40));
    });
  });

  group('ResponsiveLayoutScope', () {
    testWidgets('provides layout data to descendants', (tester) async {
      ResponsiveLayoutData? retrievedData;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveLayoutScope(
            layoutData: const ResponsiveLayoutData(
              breakpoint: ScreenBreakpoint.medium,
              orientation: LayoutOrientation.landscape,
              availableWidth: 900,
              availableHeight: 600,
            ),
            child: Builder(
              builder: (context) {
                retrievedData = ResponsiveLayoutScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedData, isNotNull);
      expect(retrievedData!.breakpoint, ScreenBreakpoint.medium);
      expect(retrievedData!.orientation, LayoutOrientation.landscape);
    });

    testWidgets('maybeOf returns null when no scope in tree', (tester) async {
      ResponsiveLayoutData? retrievedData;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              retrievedData = ResponsiveLayoutScope.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedData, isNull);
    });
  });

  group('ResponsiveScaffold', () {
    testWidgets('provides layout data via scope to children', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      ResponsiveLayoutData? scopeData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveScaffold(
              builder: (context, layoutData) {
                return Builder(
                  builder: (innerContext) {
                    scopeData = ResponsiveLayoutScope.maybeOf(innerContext);
                    return const SizedBox();
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(scopeData, isNotNull);
      expect(scopeData!.breakpoint, ScreenBreakpoint.expanded);
      expect(scopeData!.orientation, LayoutOrientation.landscape);
    });
  });

  group('Orientation change state preservation (Requirement 23.4)', () {
    testWidgets('state is preserved across size changes', (tester) async {
      // Start with a compact portrait size.
      tester.view.physicalSize = const Size(600, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      final key = GlobalKey<_CounterWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              builder: (_, layoutData) {
                return _CounterWidget(key: key);
              },
            ),
          ),
        ),
      );

      // Increment counter to establish state.
      expect(key.currentState!.count, 0);
      key.currentState!.increment();
      await tester.pump();
      expect(key.currentState!.count, 1);

      // Simulate orientation change by resizing the view.
      tester.view.physicalSize = const Size(900, 600); // landscape
      await tester.pump();

      // State should be preserved — the widget was not disposed.
      expect(key.currentState!.count, 1);
    });
  });
}

/// A stateful counter widget used to verify state preservation.
class _CounterWidget extends StatefulWidget {
  const _CounterWidget({super.key});

  @override
  State<_CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<_CounterWidget> {
  int count = 0;

  void increment() {
    setState(() => count++);
  }

  @override
  Widget build(BuildContext context) {
    return Text('Count: $count');
  }
}
