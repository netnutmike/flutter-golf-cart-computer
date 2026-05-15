/// Reusable connection status indicator widgets for Meshtastic and GCI.
///
/// Displays visual indicators for each connection state:
/// Disconnected, Connecting, Connected, Reconnecting.
///
/// Uses Material Design 3 theming with appropriate icons and colors.
///
/// Requirements: 13.6, 17.2, 17.5
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/connection_notifier.dart';
import '../../application/providers.dart';

/// Visual configuration for a single connection status.
class _StatusVisual {
  final IconData icon;
  final Color Function(ColorScheme) color;
  final String label;

  const _StatusVisual({
    required this.icon,
    required this.color,
    required this.label,
  });
}

/// Maps [ConnectionStatus] to its visual representation.
_StatusVisual _visualForStatus(ConnectionStatus status) {
  switch (status) {
    case ConnectionStatus.disconnected:
      return _StatusVisual(
        icon: Icons.bluetooth_disabled,
        color: (cs) => cs.error,
        label: 'Disconnected',
      );
    case ConnectionStatus.connecting:
      return _StatusVisual(
        icon: Icons.bluetooth_searching,
        color: (cs) => cs.tertiary,
        label: 'Connecting',
      );
    case ConnectionStatus.connected:
      return _StatusVisual(
        icon: Icons.bluetooth_connected,
        color: (cs) => cs.primary,
        label: 'Connected',
      );
    case ConnectionStatus.reconnecting:
      return _StatusVisual(
        icon: Icons.bluetooth_searching,
        color: (cs) => cs.secondary,
        label: 'Reconnecting',
      );
  }
}

/// A single connection status indicator chip.
///
/// Displays an icon and label representing the current connection state
/// for a named device (e.g., "Meshtastic" or "GCI").
///
/// Touch target is at least 48x48 dp per Requirement 13.15.
class ConnectionStatusChip extends StatelessWidget {
  /// The display name for this connection (e.g., "Mesh" or "GCI").
  final String deviceLabel;

  /// The current connection status to display.
  final ConnectionStatus status;

  const ConnectionStatusChip({
    super.key,
    required this.deviceLabel,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visual = _visualForStatus(status);
    final statusColor = visual.color(colorScheme);

    return Semantics(
      label: '$deviceLabel: ${visual.label}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                visual.icon,
                size: 18,
                color: statusColor,
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    visual.label,
                    style: textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays both Meshtastic and GCI connection status indicators side by side.
///
/// Watches the [connectionNotifierProvider] to reactively update when
/// connection states change.
///
/// This is the primary widget to place on the main screen.
class DualConnectionStatusIndicator extends ConsumerWidget {
  const DualConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionNotifierProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConnectionStatusChip(
          deviceLabel: 'Mesh',
          status: connectionState.meshtastic,
        ),
        const SizedBox(width: 8),
        ConnectionStatusChip(
          deviceLabel: 'GCI',
          status: connectionState.gci,
        ),
      ],
    );
  }
}
