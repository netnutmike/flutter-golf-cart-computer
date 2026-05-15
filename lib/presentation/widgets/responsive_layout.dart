/// Responsive layout system for the Golf Cart Computer.
///
/// Provides breakpoint detection, orientation-aware layout switching,
/// and layout variant widgets for Compact, Medium, and Expanded screen sizes.
///
/// Breakpoints:
/// - Compact: width < 800px (small phones, minimum supported resolution)
/// - Medium: 800px <= width <= 1024px (tablets in portrait, large phones landscape)
/// - Expanded: width > 1024px (tablets landscape, desktop)
///
/// All primary layout containers use relative sizing (flex factors,
/// percentage-based constraints) rather than fixed pixel dimensions.
///
/// Requirements: 23.1, 23.2, 23.3, 23.4, 23.5, 23.9, 23.10
library;

import 'package:flutter/material.dart';

/// Screen size breakpoint categories.
///
/// Requirement 23.2: Responsive layout system that dynamically adjusts
/// widget sizes, spacing, and arrangement based on available screen dimensions.
enum ScreenBreakpoint {
  /// Width < 800px. Single-column layout, prioritized content.
  compact,

  /// 800px <= width <= 1024px. Two-column layout with essential info visible.
  medium,

  /// Width > 1024px. Multi-column layout with all widgets visible.
  expanded,
}

/// Device orientation categories for layout adaptation.
///
/// Requirement 23.3: Support both portrait and landscape orientations.
enum LayoutOrientation {
  /// Vertical/portrait orientation.
  portrait,

  /// Horizontal/landscape orientation.
  landscape,
}

/// Layout context information passed to child builders.
///
/// Contains the detected breakpoint, orientation, and available dimensions
/// for use by layout variant widgets.
class ResponsiveLayoutData {
  /// The detected screen size breakpoint.
  final ScreenBreakpoint breakpoint;

  /// The detected device orientation.
  final LayoutOrientation orientation;

  /// Available width in logical pixels.
  final double availableWidth;

  /// Available height in logical pixels.
  final double availableHeight;

  const ResponsiveLayoutData({
    required this.breakpoint,
    required this.orientation,
    required this.availableWidth,
    required this.availableHeight,
  });

  /// Whether the layout is in compact breakpoint.
  bool get isCompact => breakpoint == ScreenBreakpoint.compact;

  /// Whether the layout is in medium breakpoint.
  bool get isMedium => breakpoint == ScreenBreakpoint.medium;

  /// Whether the layout is in expanded breakpoint.
  bool get isExpanded => breakpoint == ScreenBreakpoint.expanded;

  /// Whether the device is in portrait orientation.
  bool get isPortrait => orientation == LayoutOrientation.portrait;

  /// Whether the device is in landscape orientation.
  bool get isLandscape => orientation == LayoutOrientation.landscape;
}

/// Determines the [ScreenBreakpoint] from a given width.
///
/// Requirement 23.10: Uses breakpoint utilities to implement adaptive layouts.
ScreenBreakpoint breakpointFromWidth(double width) {
  if (width < 800) {
    return ScreenBreakpoint.compact;
  } else if (width <= 1024) {
    return ScreenBreakpoint.medium;
  } else {
    return ScreenBreakpoint.expanded;
  }
}

/// Determines the [LayoutOrientation] from available dimensions.
///
/// Requirement 23.3: Detect portrait vs landscape.
LayoutOrientation orientationFromSize(double width, double height) {
  return width >= height
      ? LayoutOrientation.landscape
      : LayoutOrientation.portrait;
}

/// Builder function type for responsive layout variants.
typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  ResponsiveLayoutData layoutData,
);

/// A responsive layout widget that detects breakpoints and orientation,
/// then delegates to the appropriate builder.
///
/// Uses [LayoutBuilder] to respond to the actual rendered area and
/// [MediaQuery] for orientation detection, as specified in Requirement 23.10.
///
/// Requirement 23.4: Orientation changes reflow within 500ms without
/// losing application state or interrupting Bluetooth connections.
/// This is achieved by using Flutter's built-in layout system which
/// rebuilds widgets in-place without disposing state.
///
/// Requirement 23.5: Uses relative sizing rather than fixed pixel dimensions.
class ResponsiveLayout extends StatelessWidget {
  /// Builder for compact breakpoint (width < 800px).
  final ResponsiveWidgetBuilder? compactBuilder;

  /// Builder for medium breakpoint (800px <= width <= 1024px).
  final ResponsiveWidgetBuilder? mediumBuilder;

  /// Builder for expanded breakpoint (width > 1024px).
  final ResponsiveWidgetBuilder? expandedBuilder;

  /// Fallback builder used when a specific breakpoint builder is not provided.
  final ResponsiveWidgetBuilder builder;

  const ResponsiveLayout({
    super.key,
    required this.builder,
    this.compactBuilder,
    this.mediumBuilder,
    this.expandedBuilder,
  });

  /// Convenience constructor that takes separate portrait and landscape
  /// builders for each breakpoint.
  ///
  /// Requirement 23.9: Adapt between single-column (portrait/narrow)
  /// and multi-column (landscape/wider) arrangements.
  const factory ResponsiveLayout.oriented({
    Key? key,
    required ResponsiveWidgetBuilder portraitBuilder,
    required ResponsiveWidgetBuilder landscapeBuilder,
    ResponsiveWidgetBuilder? compactPortraitBuilder,
    ResponsiveWidgetBuilder? compactLandscapeBuilder,
    ResponsiveWidgetBuilder? mediumPortraitBuilder,
    ResponsiveWidgetBuilder? mediumLandscapeBuilder,
    ResponsiveWidgetBuilder? expandedPortraitBuilder,
    ResponsiveWidgetBuilder? expandedLandscapeBuilder,
  }) = _OrientedResponsiveLayout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Use MediaQuery orientation as a secondary signal when
        // LayoutBuilder constraints are unbounded.
        final mediaOrientation = MediaQuery.orientationOf(context);

        final breakpoint = breakpointFromWidth(width);
        final orientation = height.isFinite
            ? orientationFromSize(width, height)
            : (mediaOrientation == Orientation.landscape
                ? LayoutOrientation.landscape
                : LayoutOrientation.portrait);

        final layoutData = ResponsiveLayoutData(
          breakpoint: breakpoint,
          orientation: orientation,
          availableWidth: width,
          availableHeight: height.isFinite ? height : 0,
        );

        // Select the appropriate builder based on breakpoint.
        final selectedBuilder = switch (breakpoint) {
          ScreenBreakpoint.compact => compactBuilder ?? builder,
          ScreenBreakpoint.medium => mediumBuilder ?? builder,
          ScreenBreakpoint.expanded => expandedBuilder ?? builder,
        };

        return selectedBuilder(context, layoutData);
      },
    );
  }
}

/// Internal implementation of orientation-aware responsive layout.
class _OrientedResponsiveLayout extends ResponsiveLayout {
  final ResponsiveWidgetBuilder portraitBuilder;
  final ResponsiveWidgetBuilder landscapeBuilder;
  final ResponsiveWidgetBuilder? compactPortraitBuilder;
  final ResponsiveWidgetBuilder? compactLandscapeBuilder;
  final ResponsiveWidgetBuilder? mediumPortraitBuilder;
  final ResponsiveWidgetBuilder? mediumLandscapeBuilder;
  final ResponsiveWidgetBuilder? expandedPortraitBuilder;
  final ResponsiveWidgetBuilder? expandedLandscapeBuilder;

  const _OrientedResponsiveLayout({
    super.key,
    required this.portraitBuilder,
    required this.landscapeBuilder,
    this.compactPortraitBuilder,
    this.compactLandscapeBuilder,
    this.mediumPortraitBuilder,
    this.mediumLandscapeBuilder,
    this.expandedPortraitBuilder,
    this.expandedLandscapeBuilder,
  }) : super(builder: portraitBuilder);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final mediaOrientation = MediaQuery.orientationOf(context);

        final breakpoint = breakpointFromWidth(width);
        final orientation = height.isFinite
            ? orientationFromSize(width, height)
            : (mediaOrientation == Orientation.landscape
                ? LayoutOrientation.landscape
                : LayoutOrientation.portrait);

        final layoutData = ResponsiveLayoutData(
          breakpoint: breakpoint,
          orientation: orientation,
          availableWidth: width,
          availableHeight: height.isFinite ? height : 0,
        );

        // Select builder based on breakpoint + orientation combination.
        final selectedBuilder = switch ((breakpoint, orientation)) {
          (ScreenBreakpoint.compact, LayoutOrientation.portrait) =>
            compactPortraitBuilder ?? portraitBuilder,
          (ScreenBreakpoint.compact, LayoutOrientation.landscape) =>
            compactLandscapeBuilder ?? landscapeBuilder,
          (ScreenBreakpoint.medium, LayoutOrientation.portrait) =>
            mediumPortraitBuilder ?? portraitBuilder,
          (ScreenBreakpoint.medium, LayoutOrientation.landscape) =>
            mediumLandscapeBuilder ?? landscapeBuilder,
          (ScreenBreakpoint.expanded, LayoutOrientation.portrait) =>
            expandedPortraitBuilder ?? portraitBuilder,
          (ScreenBreakpoint.expanded, LayoutOrientation.landscape) =>
            expandedLandscapeBuilder ?? landscapeBuilder,
        };

        return selectedBuilder(context, layoutData);
      },
    );
  }
}

/// Compact dashboard layout for screens < 800px wide.
///
/// Single-column arrangement prioritizing essential information:
/// speed, heading, time, and connection status. Secondary information
/// is scrollable below.
///
/// Requirement 23.8: Prioritize essential dashboard information on
/// screens smaller than 1024x768.
/// Requirement 23.9: Single-column arrangement for narrow/portrait screens.
/// Requirement 23.5: Uses flex factors for relative sizing.
class CompactDashboardLayout extends StatelessWidget {
  /// Primary content widget (speed, heading, time, connection status).
  final Widget primaryContent;

  /// Secondary content widget (telemetry, odometer, etc.) — scrollable.
  final Widget secondaryContent;

  /// Optional bottom navigation widget.
  final Widget? bottomNavigation;

  const CompactDashboardLayout({
    super.key,
    required this.primaryContent,
    required this.secondaryContent,
    this.bottomNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary content takes proportional space (not fixed pixels).
        Flexible(
          flex: 2,
          child: primaryContent,
        ),
        // Secondary content scrolls in remaining space.
        Flexible(
          flex: 3,
          child: SingleChildScrollView(
            child: secondaryContent,
          ),
        ),
        // Bottom navigation pinned at bottom.
        if (bottomNavigation != null) bottomNavigation!,
      ],
    );
  }
}

/// Medium dashboard layout for screens 800-1024px wide.
///
/// Two-column layout with essential info visible. Uses flex factors
/// for proportional column sizing.
///
/// Requirement 23.5: Uses relative sizing (flex factors).
/// Requirement 23.9: Multi-column arrangement for wider screens.
class MediumDashboardLayout extends StatelessWidget {
  /// Left column content (primary data: speed, heading, time).
  final Widget leftColumn;

  /// Right column content (secondary data: telemetry, status).
  final Widget rightColumn;

  /// Optional bottom navigation widget spanning full width.
  final Widget? bottomNavigation;

  const MediumDashboardLayout({
    super.key,
    required this.leftColumn,
    required this.rightColumn,
    this.bottomNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: 55% of width via flex.
              Expanded(
                flex: 55,
                child: leftColumn,
              ),
              const SizedBox(width: 8),
              // Right column: 45% of width via flex.
              Expanded(
                flex: 45,
                child: rightColumn,
              ),
            ],
          ),
        ),
        if (bottomNavigation != null) bottomNavigation!,
      ],
    );
  }
}

/// Expanded dashboard layout for screens > 1024px wide.
///
/// Multi-column layout with all widgets visible simultaneously.
/// Three-column arrangement using flex factors for proportional sizing.
///
/// Requirement 23.5: Uses relative sizing (flex factors).
/// Requirement 23.9: Multi-column arrangement for wider/landscape screens.
class ExpandedDashboardLayout extends StatelessWidget {
  /// Left column content (primary navigation data).
  final Widget leftColumn;

  /// Center column content (main dashboard data).
  final Widget centerColumn;

  /// Right column content (telemetry and status).
  final Widget rightColumn;

  /// Optional bottom navigation widget spanning full width.
  final Widget? bottomNavigation;

  const ExpandedDashboardLayout({
    super.key,
    required this.leftColumn,
    required this.centerColumn,
    required this.rightColumn,
    this.bottomNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: 30% of width.
              Expanded(
                flex: 30,
                child: leftColumn,
              ),
              const SizedBox(width: 8),
              // Center column: 40% of width.
              Expanded(
                flex: 40,
                child: centerColumn,
              ),
              const SizedBox(width: 8),
              // Right column: 30% of width.
              Expanded(
                flex: 30,
                child: rightColumn,
              ),
            ],
          ),
        ),
        if (bottomNavigation != null) bottomNavigation!,
      ],
    );
  }
}

/// An [InheritedWidget] that provides [ResponsiveLayoutData] to descendants.
///
/// Allows child widgets to access the current breakpoint and orientation
/// without needing to recalculate or pass data through constructors.
class ResponsiveLayoutScope extends InheritedWidget {
  /// The current responsive layout data.
  final ResponsiveLayoutData layoutData;

  const ResponsiveLayoutScope({
    super.key,
    required this.layoutData,
    required super.child,
  });

  /// Retrieves the nearest [ResponsiveLayoutData] from the widget tree.
  ///
  /// Returns null if no [ResponsiveLayoutScope] is found above this widget.
  static ResponsiveLayoutData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ResponsiveLayoutScope>()
        ?.layoutData;
  }

  /// Retrieves the nearest [ResponsiveLayoutData] from the widget tree.
  ///
  /// Throws if no [ResponsiveLayoutScope] is found above this widget.
  static ResponsiveLayoutData of(BuildContext context) {
    final data = maybeOf(context);
    assert(data != null, 'No ResponsiveLayoutScope found in widget tree');
    return data!;
  }

  @override
  bool updateShouldNotify(ResponsiveLayoutScope oldWidget) {
    return layoutData.breakpoint != oldWidget.layoutData.breakpoint ||
        layoutData.orientation != oldWidget.layoutData.orientation ||
        layoutData.availableWidth != oldWidget.layoutData.availableWidth ||
        layoutData.availableHeight != oldWidget.layoutData.availableHeight;
  }
}

/// A convenience widget that combines [ResponsiveLayout] with
/// [ResponsiveLayoutScope] to provide layout data to all descendants.
///
/// This is the recommended top-level responsive wrapper for screens.
///
/// Requirement 23.10: Uses LayoutBuilder, MediaQuery, and responsive
/// breakpoint utilities to implement adaptive layouts.
class ResponsiveScaffold extends StatelessWidget {
  /// Builder that receives the layout data and returns the screen content.
  final ResponsiveWidgetBuilder builder;

  const ResponsiveScaffold({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, layoutData) {
        return ResponsiveLayoutScope(
          layoutData: layoutData,
          child: builder(context, layoutData),
        );
      },
    );
  }
}
