import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/entertainment_notifier.dart';
import '../../application/providers.dart';
import '../widgets/responsive_layout.dart';

/// Entertainment screen displaying today's venue/event schedule.
///
/// Shows a scrollable two-column table of venue names and event names,
/// received timestamp in 12-hour format, "(stored)" indicator for cached
/// data, and a "new data received" indicator that auto-clears after 5 seconds.
///
/// Adapts the scrollable table layout for available space using
/// [ResponsiveScaffold] to handle portrait/landscape and screen size
/// breakpoints.
///
/// Requirements: 4.5, 4.6, 4.7, 13.3, 13.10, 13.11, 23.1, 23.2, 23.3, 23.6, 23.7
class EntertainmentScreen extends ConsumerWidget {
  const EntertainmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entertainmentState = ref.watch(entertainmentNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entertainment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to main screen',
        ),
      ),
      body: SafeArea(
        child: ResponsiveScaffold(
          builder: (context, layoutData) {
            return _buildBody(
              context,
              entertainmentState,
              colorScheme,
              layoutData,
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    EntertainmentState state,
    ColorScheme colorScheme,
    ResponsiveLayoutData layoutData,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.data == null) {
      return _buildEmptyState(context, colorScheme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusBar(context, state, colorScheme, layoutData),
        const Divider(height: 1),
        Expanded(
          child: _buildVenueTable(context, state, colorScheme, layoutData),
        ),
      ],
    );
  }

  /// Builds the empty state when no venue/event data is available.
  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No entertainment data available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  // Requirement 23.6: minimum 12sp for informational text
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for venue/event data...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  // Requirement 23.6: minimum 12sp
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }

  /// Builds the status bar showing timestamp, stored indicator, and new data
  /// indicator.
  ///
  /// Adapts layout for compact screens by wrapping content.
  Widget _buildStatusBar(
    BuildContext context,
    EntertainmentState state,
    ColorScheme colorScheme,
    ResponsiveLayoutData layoutData,
  ) {
    final data = state.data!;
    final padding = layoutData.isCompact ? 12.0 : 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          // Timestamp in 12-hour format
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Received: ${data.receivedTimestamp}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      // Requirement 23.6: minimum 12sp
                      fontSize: 13,
                    ),
              ),
              // "(stored)" indicator for cached data
              if (data.isStored) ...[
                const SizedBox(width: 8),
                Text(
                  '(stored)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.tertiary,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                ),
              ],
            ],
          ),
          // "new data received" indicator with auto-clear
          if (state.showNewDataIndicator)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'new data received',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the scrollable two-column table of venue/event entries.
  ///
  /// Adapts column widths and cell padding based on available space.
  /// Uses [LayoutBuilder] to ensure the table fills available space
  /// and scrolls properly at all screen sizes.
  ///
  /// Requirements: 4.5, 4.6, 23.1, 23.2
  Widget _buildVenueTable(
    BuildContext context,
    EntertainmentState state,
    ColorScheme colorScheme,
    ResponsiveLayoutData layoutData,
  ) {
    final venues = state.data!.venues;
    // Display up to 12 entries
    final displayVenues = venues.length > 12 ? venues.sublist(0, 12) : venues;

    // Adapt cell padding based on breakpoint
    final cellPadding = layoutData.isCompact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 10)
        : const EdgeInsets.all(12);

    // Adapt column widths for available space
    final columnWidths = layoutData.isCompact
        ? const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          }
        : const <int, TableColumnWidth>{
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          };

    // Requirement 23.6: minimum font sizes
    final headerStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          fontSize: 14,
        );
    final cellStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 14,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: layoutData.isCompact ? 8 : 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth -
                  (layoutData.isCompact ? 16 : 32),
            ),
            child: Table(
              columnWidths: columnWidths,
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                  ),
                  children: [
                    Padding(
                      padding: cellPadding,
                      child: Text('Venue', style: headerStyle),
                    ),
                    Padding(
                      padding: cellPadding,
                      child: Text('Event', style: headerStyle),
                    ),
                  ],
                ),
                // Data rows
                for (var i = 0; i < displayVenues.length; i++)
                  TableRow(
                    decoration: i.isEven
                        ? null
                        : BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                          ),
                    children: [
                      Padding(
                        padding: cellPadding,
                        child: Text(
                          displayVenues[i].venueName,
                          style: cellStyle,
                        ),
                      ),
                      Padding(
                        padding: cellPadding,
                        child: Text(
                          displayVenues[i].eventName,
                          style: cellStyle,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
