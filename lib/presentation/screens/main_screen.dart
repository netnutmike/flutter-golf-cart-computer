/// Main display screen for the Golf Cart Computer.
///
/// Displays speed, heading, time, date, temperature, satellite/HDOP,
/// connection status, battery voltage, fuel level, headlight mode,
/// odometer, trip odometer, driving hours, sunrise/sunset times,
/// and service-due indicator.
///
/// Uses [ResponsiveLayout] to adapt between compact, medium, and expanded
/// breakpoints, and between portrait and landscape orientations.
///
/// Requirements: 13.1, 13.6, 13.9, 13.12, 13.13, 13.14, 13.15,
///   5.3, 5.8, 5.9, 5.10, 5.13, 5.14, 5.17, 5.18, 6.3, 7.6, 7.10,
///   8.3, 8.4, 8.5, 8.6,
///   23.1, 23.2, 23.3, 23.5, 23.6, 23.7, 23.8, 23.9
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/connection_notifier.dart';
import '../../application/config_notifier.dart';
import '../../application/main_notifier.dart';
import '../../application/providers.dart';
import '../../domain/models/user_preferences.dart';
import '../widgets/responsive_layout.dart';

/// Minimum font size for primary data displays (speed, temperature, time).
/// Requirement 23.6: 16sp minimum for primary data.
const double _kPrimaryFontSize = 16.0;

/// Minimum font size for labels and status text.
/// Requirement 23.6: 12sp minimum for informational text.
const double _kLabelFontSize = 12.0;

/// Minimum touch target size in density-independent pixels.
/// Requirement 23.7: 44x44dp minimum touch targets.
const double _kMinTouchTarget = 44.0;

/// Main screen widget displaying all primary dashboard information.
///
/// Uses Riverpod [ConsumerWidget] to reactively rebuild when
/// [MainScreenState], [DualConnectionState], or [ConfigState] changes.
///
/// Requirement 23.2: Responsive layout system that dynamically adjusts
/// widget sizes, spacing, and arrangement based on available screen dimensions.
/// Requirement 23.3: Supports both portrait and landscape orientations.
class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainNotifierProvider);
    final connectionState = ref.watch(connectionNotifierProvider);
    final configState = ref.watch(configNotifierProvider);
    final preferences = configState.preferences;

    // Requirement 13.9: Support screen rotation (flip) configuration.
    final flipScreen = preferences.flipScreen;

    final body = SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _ResponsiveMainContent(
          state: state,
          connectionState: connectionState,
          preferences: preferences,
        ),
      ),
    );

    // Requirement 13.9: Apply screen flip via rotation.
    return RotatedBox(
      quarterTurns: flipScreen ? 2 : 0,
      child: body,
    );
  }
}

/// Responsive main content that adapts layout based on breakpoint and
/// orientation using [ResponsiveLayout].
///
/// Requirement 23.2: Dynamically adjusts widget sizes, spacing, and
/// arrangement based on available screen dimensions.
/// Requirement 23.9: Adapts between single-column (portrait/narrow) and
/// multi-column (landscape/wider) arrangements.
class _ResponsiveMainContent extends StatelessWidget {
  const _ResponsiveMainContent({
    required this.state,
    required this.connectionState,
    required this.preferences,
  });

  final MainScreenState state;
  final DualConnectionState connectionState;
  final UserPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout.oriented(
      // Portrait fallback: single-column stack
      portraitBuilder: _buildCompactPortrait,
      // Landscape fallback: side-by-side
      landscapeBuilder: _buildCompactLandscape,
      // Compact breakpoint (< 800px)
      compactPortraitBuilder: _buildCompactPortrait,
      compactLandscapeBuilder: _buildCompactLandscape,
      // Medium breakpoint (800-1024px)
      mediumPortraitBuilder: _buildMediumPortrait,
      mediumLandscapeBuilder: _buildMediumLandscape,
      // Expanded breakpoint (> 1024px)
      expandedPortraitBuilder: _buildExpanded,
      expandedLandscapeBuilder: _buildExpanded,
    );
  }

  /// Compact portrait: single-column stack with speed/heading at top,
  /// secondary info scrollable below.
  ///
  /// Requirement 23.8: Prioritize speed, heading, time, connection status.
  /// Requirement 23.9: Single-column arrangement for narrow/portrait screens.
  Widget _buildCompactPortrait(
    BuildContext context,
    ResponsiveLayoutData layoutData,
  ) {
    return CompactDashboardLayout(
      primaryContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopBar(
            connectionState: connectionState,
            isServiceDue: state.isServiceDue,
          ),
          const SizedBox(height: 8),
          _SpeedHeadingRow(state: state),
          const SizedBox(height: 8),
          _TimeDateRow(state: state),
        ],
      ),
      secondaryContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _TelemetryGrid(state: state),
          const SizedBox(height: 12),
          _OdometerRow(state: state),
          const SizedBox(height: 12),
          _SunTimesRow(state: state),
        ],
      ),
      bottomNavigation: const _BottomNavBar(),
    );
  }

  /// Compact landscape: side-by-side with speed/heading on one side,
  /// telemetry/status on the other.
  ///
  /// Requirement 23.3: Landscape orientation adaptation.
  /// Requirement 23.8: Prioritize essential dashboard information.
  Widget _buildCompactLandscape(
    BuildContext context,
    ResponsiveLayoutData layoutData,
  ) {
    return Column(
      children: [
        _TopBar(
          connectionState: connectionState,
          isServiceDue: state.isServiceDue,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: speed, heading, time
              Expanded(
                flex: 50,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      _SpeedHeadingRow(state: state),
                      const SizedBox(height: 8),
                      _TimeDateRow(state: state),
                      const SizedBox(height: 8),
                      _SunTimesRow(state: state),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Right side: telemetry, odometer
              Expanded(
                flex: 50,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      _TelemetryGrid(state: state),
                      const SizedBox(height: 12),
                      _OdometerRow(state: state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const _BottomNavBar(),
      ],
    );
  }

  /// Medium portrait: two-column dashboard with essential info visible.
  ///
  /// Requirement 23.9: Multi-column arrangement for wider screens.
  Widget _buildMediumPortrait(
    BuildContext context,
    ResponsiveLayoutData layoutData,
  ) {
    return MediumDashboardLayout(
      leftColumn: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TopBar(
              connectionState: connectionState,
              isServiceDue: state.isServiceDue,
            ),
            const SizedBox(height: 8),
            _SpeedHeadingRow(state: state),
            const SizedBox(height: 12),
            _TimeDateRow(state: state),
            const SizedBox(height: 12),
            _SunTimesRow(state: state),
          ],
        ),
      ),
      rightColumn: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _TelemetryGrid(state: state),
            const SizedBox(height: 12),
            _OdometerRow(state: state),
          ],
        ),
      ),
      bottomNavigation: const _BottomNavBar(),
    );
  }

  /// Medium landscape: two-column with speed/heading on left,
  /// telemetry/status on right.
  ///
  /// Requirement 23.3: Landscape orientation adaptation.
  Widget _buildMediumLandscape(
    BuildContext context,
    ResponsiveLayoutData layoutData,
  ) {
    return MediumDashboardLayout(
      leftColumn: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TopBar(
              connectionState: connectionState,
              isServiceDue: state.isServiceDue,
            ),
            const SizedBox(height: 8),
            _SpeedHeadingRow(state: state),
            const SizedBox(height: 12),
            _TimeDateRow(state: state),
          ],
        ),
      ),
      rightColumn: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _TelemetryGrid(state: state),
            const SizedBox(height: 12),
            _OdometerRow(state: state),
            const SizedBox(height: 12),
            _SunTimesRow(state: state),
          ],
        ),
      ),
      bottomNavigation: const _BottomNavBar(),
    );
  }

  /// Expanded: all widgets visible simultaneously in multi-column arrangement.
  ///
  /// Requirement 23.9: Multi-column arrangement for wider/landscape screens.
  Widget _buildExpanded(
    BuildContext context,
    ResponsiveLayoutData layoutData,
  ) {
    return ExpandedDashboardLayout(
      leftColumn: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TopBar(
              connectionState: connectionState,
              isServiceDue: state.isServiceDue,
            ),
            const SizedBox(height: 8),
            _SpeedHeadingRow(state: state),
            const SizedBox(height: 12),
            _TimeDateRow(state: state),
          ],
        ),
      ),
      centerColumn: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _TelemetryGrid(state: state),
          ],
        ),
      ),
      rightColumn: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _OdometerRow(state: state),
            const SizedBox(height: 12),
            _SunTimesRow(state: state),
          ],
        ),
      ),
      bottomNavigation: const _BottomNavBar(),
    );
  }
}

/// Top bar showing connection status indicators and service-due warning.
///
/// Requirement 13.6: Display connection status indicators for both
/// Meshtastic and GCI connections with distinct visual states.
/// Requirement 7.10: Display service-due indicator.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.connectionState,
    required this.isServiceDue,
  });

  final DualConnectionState connectionState;
  final bool isServiceDue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Meshtastic connection indicator
        _ConnectionIndicator(
          label: 'Mesh',
          status: connectionState.meshtastic,
        ),
        const SizedBox(width: 12),
        // GCI connection indicator
        _ConnectionIndicator(
          label: 'GCI',
          status: connectionState.gci,
        ),
        const Spacer(),
        // Requirement 7.10: Service-due indicator
        if (isServiceDue)
          Tooltip(
            message: 'Service due',
            child: Icon(
              Icons.build_circle,
              color: theme.colorScheme.error,
              size: 28,
            ),
          ),
      ],
    );
  }
}

/// Connection status indicator with colored icon.
///
/// Requirement 13.6: Three distinct visual states.
/// Requirement 23.7: Touch targets minimum 44x44dp.
class _ConnectionIndicator extends StatelessWidget {
  const _ConnectionIndicator({
    required this.label,
    required this.status,
  });

  final String label;
  final ConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (Color color, IconData icon) = switch (status) {
      ConnectionStatus.connected => (Colors.green, Icons.bluetooth_connected),
      ConnectionStatus.connecting => (Colors.orange, Icons.bluetooth_searching),
      ConnectionStatus.reconnecting =>
        (Colors.orange, Icons.bluetooth_searching),
      ConnectionStatus.disconnected => (
        theme.colorScheme.onSurfaceVariant,
        Icons.bluetooth_disabled,
      ),
    };

    // Requirement 23.7: Touch targets minimum 44x44dp.
    return Tooltip(
      message: '$label: ${status.name}',
      child: SizedBox(
        width: _kMinTouchTarget,
        height: _kMinTouchTarget,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: _kLabelFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Speed and heading display row.
///
/// Requirement 5.3: Display speed as integer mph.
/// Requirement 5.8: Display heading as 16-point cardinal direction.
/// Requirement 23.6: Minimum 16sp for speed display.
/// Requirement 23.5: Uses relative sizing via FittedBox.
class _SpeedHeadingRow extends StatelessWidget {
  const _SpeedHeadingRow({required this.state});

  final MainScreenState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Speed display
        // Requirement 23.7: Touch targets minimum 44x44dp.
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _kMinTouchTarget,
            minHeight: _kMinTouchTarget,
          ),
          child: SizedBox(
            width: 120,
            height: 80,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${state.speedMph}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: _kPrimaryFontSize * 3,
                    ),
                  ),
                  Text(
                    'MPH',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: _kLabelFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Heading display
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _kMinTouchTarget,
            minHeight: _kMinTouchTarget,
          ),
          child: SizedBox(
            width: 80,
            height: 80,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.cardinalDirection,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: _kPrimaryFontSize * 2,
                    ),
                  ),
                  Text(
                    'HDG',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: _kLabelFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Time and date display row.
///
/// Requirement 5.13: Display date in "Mon, Jan 15" format.
/// Requirement 5.14: Display time in 12-hour AM/PM format.
/// Requirement 23.6: Minimum 16sp for time display.
/// Displays "NO GPS" when applicable (Requirement 5.16).
class _TimeDateRow extends StatelessWidget {
  const _TimeDateRow({required this.state});

  final MainScreenState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Time
        // Requirement 23.7: Touch targets minimum 44x44dp.
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _kMinTouchTarget,
          ),
          child: Center(
            child: Text(
              state.timeString,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: _kPrimaryFontSize,
              ),
            ),
          ),
        ),
        // Date (shows "NO GPS" when no GPS fix)
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: _kMinTouchTarget,
          ),
          child: Center(
            child: Text(
              state.dateString,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: _kPrimaryFontSize,
                color: state.dateString == 'NO GPS'
                    ? theme.colorScheme.error
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Telemetry data grid showing temperature, satellite/HDOP, battery,
/// fuel, and headlight mode.
///
/// Requirement 8.3: Battery voltage "48.2V".
/// Requirement 8.4: Fuel level "75%".
/// Requirement 8.5: Temperature integer °F with offset.
/// Requirement 8.6: Headlight mode numeric indicator.
/// Requirement 5.10: Satellite/HDOP "8/1.50".
class _TelemetryGrid extends StatelessWidget {
  const _TelemetryGrid({required this.state});

  final MainScreenState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        // Temperature (integer °F with offset applied)
        _DataWidget(
          icon: Icons.thermostat,
          value: '${state.temperature}°F',
          label: 'Temp',
        ),
        // Satellite/HDOP in "sats/hdop" format
        _DataWidget(
          icon: Icons.satellite_alt,
          value: '${state.satelliteCount}/${state.hdop.toStringAsFixed(2)}',
          label: 'Sats/HDOP',
        ),
        // Battery voltage
        _DataWidget(
          icon: Icons.battery_std,
          value: '${state.batteryVoltage.toStringAsFixed(1)}V',
          label: 'Battery',
        ),
        // Fuel level
        _DataWidget(
          icon: Icons.local_gas_station,
          value: '${state.fuelLevel.round()}%',
          label: 'Fuel',
        ),
        // Headlight mode
        _DataWidget(
          icon: Icons.lightbulb_outline,
          value: '${state.headlightMode}',
          label: 'Lights',
        ),
      ],
    );
  }
}

/// Odometer, trip odometer, and driving hours row.
///
/// Requirement 6.3: Display odometer and trip with 1 decimal place.
/// Requirement 7.6: Display hours since last service.
class _OdometerRow extends StatelessWidget {
  const _OdometerRow({required this.state});

  final MainScreenState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _DataWidget(
          icon: Icons.speed,
          value: '${state.totalMiles.toStringAsFixed(1)} mi',
          label: 'Odometer',
        ),
        _DataWidget(
          icon: Icons.route,
          value: '${state.tripMiles.toStringAsFixed(1)} mi',
          label: 'Trip',
        ),
        _DataWidget(
          icon: Icons.timer,
          value: '${state.hoursSinceService.toStringAsFixed(1)} hrs',
          label: 'Hours',
        ),
      ],
    );
  }
}

/// Sunrise and sunset times display.
///
/// Requirement 5.17: Calculate sunrise/sunset from GPS location.
/// Requirement 5.18: Display in 12-hour format.
class _SunTimesRow extends StatelessWidget {
  const _SunTimesRow({required this.state});

  final MainScreenState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _DataWidget(
          icon: Icons.wb_sunny,
          value: state.sunriseTime,
          label: 'Sunrise',
        ),
        _DataWidget(
          icon: Icons.nightlight_round,
          value: state.sunsetTime,
          label: 'Sunset',
        ),
      ],
    );
  }
}

/// Bottom navigation bar for accessing weather, entertainment, and config.
///
/// Requirement 13.14: All screens reachable within 2 taps from main display.
/// Requirement 23.7: Touch targets minimum 44x44dp.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Weather screen navigation
        _NavButton(
          icon: Icons.cloud,
          label: 'Weather',
          onTap: () => _navigateToWeather(context),
        ),
        // Entertainment screen navigation
        _NavButton(
          icon: Icons.event,
          label: 'Events',
          onTap: () => _navigateToEntertainment(context),
        ),
        // Config screen navigation
        _NavButton(
          icon: Icons.settings,
          label: 'Config',
          onTap: () => _navigateToConfig(context),
        ),
      ],
    );
  }

  void _navigateToWeather(BuildContext context) {
    Navigator.of(context).pushNamed('/weather');
  }

  void _navigateToEntertainment(BuildContext context) {
    Navigator.of(context).pushNamed('/entertainment');
  }

  void _navigateToConfig(BuildContext context) {
    Navigator.of(context).pushNamed('/config');
  }
}

/// Navigation button with icon and label.
///
/// Requirement 23.7: Touch targets minimum 44x44dp.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // Requirement 23.7: Touch targets minimum 44x44dp.
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 80,
            minHeight: _kMinTouchTarget + 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: _kLabelFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable data widget for displaying a value with icon and label.
///
/// Requirement 23.7: Touch targets minimum 44x44dp.
/// Requirement 23.6: Minimum 16sp for primary data, 12sp for labels.
class _DataWidget extends StatelessWidget {
  const _DataWidget({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Requirement 23.7: Minimum 44x44dp touch targets.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: _kMinTouchTarget,
        minHeight: _kMinTouchTarget,
      ),
      child: SizedBox(
        width: 96,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value,
                    // Requirement 23.6: 16sp minimum for primary data.
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: _kPrimaryFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              label,
              // Requirement 23.6: 12sp minimum for labels.
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: _kLabelFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
