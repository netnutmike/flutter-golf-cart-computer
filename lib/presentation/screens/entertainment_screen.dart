import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/entertainment_notifier.dart';
import '../../application/providers.dart';

/// Entertainment screen displaying today's venue/event schedule.
///
/// Shows a scrollable two-column table of venue names and event names,
/// received timestamp in 12-hour format, "(stored)" indicator for cached
/// data, and a "new data received" indicator that auto-clears after 5 seconds.
///
/// Requirements: 4.5, 4.6, 4.7, 13.3, 13.10, 13.11
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
      body: _buildBody(context, entertainmentState, colorScheme),
    );
  }

  Widget _buildBody(
    BuildContext context,
    EntertainmentState state,
    ColorScheme colorScheme,
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
        _buildStatusBar(context, state, colorScheme),
        const Divider(height: 1),
        Expanded(
          child: _buildVenueTable(context, state, colorScheme),
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
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for venue/event data...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  /// Builds the status bar showing timestamp, stored indicator, and new data
  /// indicator.
  Widget _buildStatusBar(
    BuildContext context,
    EntertainmentState state,
    ColorScheme colorScheme,
  ) {
    final data = state.data!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Timestamp in 12-hour format
          Text(
            'Received: ${data.receivedTimestamp}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
                  ),
            ),
          ],
          const Spacer(),
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
                    ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the scrollable two-column table of venue/event entries.
  ///
  /// Displays up to 12 venue/event entries with venue names in column 1
  /// and event names in column 2.
  ///
  /// Requirements: 4.5, 4.6
  Widget _buildVenueTable(
    BuildContext context,
    EntertainmentState state,
    ColorScheme colorScheme,
  ) {
    final venues = state.data!.venues;
    // Display up to 12 entries
    final displayVenues = venues.length > 12 ? venues.sublist(0, 12) : venues;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
        },
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
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Venue',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Event',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
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
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    displayVenues[i].venueName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    displayVenues[i].eventName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
