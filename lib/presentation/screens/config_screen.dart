/// Configuration screen for the Golf Cart Computer.
///
/// Displays all configurable preferences with appropriate controls
/// (sliders, spinners, toggles), action buttons for home location,
/// GCI pairing, Meshtastic enable/disable, service hours reset,
/// trip odometer reset, reset all preferences, and manual app restart.
/// Also displays app version and device identifier.
///
/// Requirements: 13.4, 13.5, 13.7, 13.8
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';

/// Configuration screen widget using Riverpod [ConsumerWidget].
///
/// Provides controls for all user-configurable preferences and
/// system actions. Uses Material Design 3 theming with minimum
/// 48x48 dp touch targets.
class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configState = ref.watch(configNotifierProvider);
    final notifier = ref.read(configNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // --- Display Settings ---
          _SectionHeader(title: 'Display', theme: theme),
          _SliderTile(
            title: 'Day Brightness',
            value: configState.preferences.dayBrightness,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) => notifier.setDayBrightness(value),
          ),
          _SliderTile(
            title: 'Night Brightness',
            value: configState.preferences.nightBrightness,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (value) => notifier.setNightBrightness(value),
          ),
          _SpinnerTile(
            title: 'Backlight Timeout',
            value: configState.preferences.backlightTimeoutMinutes,
            min: 0,
            max: 60,
            suffix: 'min',
            onChanged: (value) => notifier.setBacklightTimeout(value),
          ),
          SwitchListTile(
            title: const Text('Flip Screen'),
            value: configState.preferences.flipScreen,
            onChanged: (value) => notifier.setFlipScreen(value),
          ),

          const Divider(),

          // --- Audio Settings ---
          _SectionHeader(title: 'Audio', theme: theme),
          _SliderTile(
            title: 'Speaker Volume',
            value: configState.preferences.speakerVolume,
            min: 0,
            max: 20,
            divisions: 20,
            onChanged: (value) => notifier.setSpeakerVolume(value),
          ),

          const Divider(),

          // --- Sensor Settings ---
          _SectionHeader(title: 'Sensors', theme: theme),
          _SpinnerTile(
            title: 'Temperature Offset',
            value: configState.preferences.temperatureOffset,
            min: -20,
            max: 20,
            suffix: '°F',
            onChanged: (value) => notifier.setTemperatureOffset(value),
          ),

          const Divider(),

          // --- Service & Odometer ---
          _SectionHeader(title: 'Service & Odometer', theme: theme),
          _SpinnerTile(
            title: 'Service Interval',
            value: configState.preferences.serviceIntervalHours,
            min: 1,
            max: 500,
            suffix: 'hrs',
            onChanged: (value) => notifier.setServiceInterval(value),
          ),
          _ActionTile(
            title: 'Reset Service Hours',
            icon: Icons.timer_off,
            onPressed: () => _showConfirmationDialog(
              context,
              title: 'Reset Service Hours',
              content:
                  'Are you sure you want to reset the service hour counter to zero?',
              onConfirm: () => notifier.confirmServiceHoursReset(),
            ),
          ),
          _ActionTile(
            title: 'Reset Trip Odometer',
            icon: Icons.restart_alt,
            onPressed: () => notifier.resetTripOdometer(),
          ),

          const Divider(),

          // --- Home Location ---
          _SectionHeader(title: 'Home Location', theme: theme),
          _SpinnerTile(
            title: 'Geofence Radius',
            value: configState.preferences.homeFenceRadiusMeters,
            min: 100,
            max: 5000,
            step: 100,
            suffix: 'm',
            onChanged: (value) => notifier.setHomeFenceRadius(value),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _MinTouchTarget(
                    child: FilledButton.icon(
                      onPressed: () => notifier.setHomeLocation(),
                      icon: const Icon(Icons.home),
                      label: const Text('Set Home'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MinTouchTarget(
                    child: OutlinedButton.icon(
                      onPressed: notifier.isHomeLocationSet
                          ? () => notifier.clearHomeLocation()
                          : null,
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Clear Home'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (notifier.isHomeLocationSet)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Home location is set',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

          const Divider(),

          // --- Connections ---
          _SectionHeader(title: 'Connections', theme: theme),
          _GciPairingTile(
            isPairing: configState.isPairing,
            isDevicePaired:
                configState.preferences.gciDeviceAddress != null,
            onPair: () => notifier.initiateGciPairing(),
          ),
          SwitchListTile(
            title: const Text('Meshtastic Radio'),
            subtitle: Text(
              configState.isMeshtasticEnabled ? 'Enabled' : 'Disabled',
            ),
            value: configState.isMeshtasticEnabled,
            onChanged: (value) => notifier.setMeshtasticEnabled(value),
          ),

          const Divider(),

          // --- System ---
          _SectionHeader(title: 'System', theme: theme),
          _ActionTile(
            title: 'Reset All Preferences',
            icon: Icons.settings_backup_restore,
            onPressed: () => _showConfirmationDialog(
              context,
              title: 'Reset All Preferences',
              content:
                  'This will reset all settings to defaults and restart the app. '
                  'Odometer and driving hours will be preserved. Continue?',
              onConfirm: () => notifier.confirmResetAllPreferences(),
            ),
          ),
          _ActionTile(
            title: 'Restart App',
            icon: Icons.refresh,
            onPressed: () => notifier.restartApp(),
          ),

          const Divider(),

          // --- App Info ---
          _SectionHeader(title: 'About', theme: theme),
          ListTile(
            title: const Text('App Version'),
            trailing: Text(
              configState.appVersion.isNotEmpty
                  ? configState.appVersion
                  : 'Unknown',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          ListTile(
            title: const Text('Device ID'),
            trailing: SizedBox(
              width: 180,
              child: Text(
                configState.deviceId.isNotEmpty
                    ? configState.deviceId
                    : 'Unknown',
                style: theme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ),

          // Error display
          if (configState.lastError != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          configState.lastError!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => notifier.clearError(),
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for destructive actions.
  void _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Private Helper Widgets
// =============================================================================

/// Section header with Material Design 3 styling.
class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Slider control tile with label and current value display.
/// Ensures minimum 48dp touch target height.
class _SliderTile extends StatelessWidget {
  final String title;
  final int value;
  final int min;
  final int max;
  final int divisions;
  final ValueChanged<int> onChanged;

  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions,
              label: '$value',
              onChanged: (v) => onChanged(v.round()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Spinner (increment/decrement) control tile with label and value display.
/// Ensures minimum 48dp touch targets for buttons.
class _SpinnerTile extends StatelessWidget {
  final String title;
  final int value;
  final int min;
  final int max;
  final int step;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _SpinnerTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MinTouchTarget(
            child: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed:
                  value > min ? () => onChanged(value - step) : null,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '$value $suffix',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          _MinTouchTarget(
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed:
                  value < max ? () => onChanged(value + step) : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button tile with icon and label.
/// Ensures minimum 48dp touch target.
class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onPressed,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 12,
    );
  }
}

/// GCI pairing tile with status indicator.
class _GciPairingTile extends StatelessWidget {
  final bool isPairing;
  final bool isDevicePaired;
  final VoidCallback onPair;

  const _GciPairingTile({
    required this.isPairing,
    required this.isDevicePaired,
    required this.onPair,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        Icons.bluetooth,
        color: isDevicePaired
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
      ),
      title: const Text('GCI Pairing'),
      subtitle: Text(
        isPairing
            ? 'Pairing...'
            : isDevicePaired
                ? 'Device paired'
                : 'No device paired',
      ),
      trailing: isPairing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : FilledButton(
              onPressed: onPair,
              child: const Text('Pair'),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minVerticalPadding: 12,
    );
  }
}

/// Wrapper ensuring minimum 48x48 dp touch target for child widget.
class _MinTouchTarget extends StatelessWidget {
  final Widget child;

  const _MinTouchTarget({required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),
      child: Center(child: child),
    );
  }
}
