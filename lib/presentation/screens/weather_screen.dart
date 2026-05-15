import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../application/weather_notifier.dart';
import '../../domain/models/weather_data.dart';
import '../widgets/responsive_layout.dart';

/// Weather forecast screen displaying current temperature and 4-hour forecast.
///
/// Uses Riverpod [ConsumerWidget] to watch [weatherNotifierProvider] for
/// reactive state updates. Adapts layout for portrait/landscape and screen
/// size breakpoints using [ResponsiveScaffold].
///
/// Displays:
/// - Current temperature prominently
/// - 4-hour forecast with hour label, weather glyph icon, temperature,
///   and precipitation probability
/// - Received timestamp in 12-hour format
/// - "(stored)" indicator for cached data
/// - "new data received" indicator with auto-clear
/// - Navigation back to main screen
///
/// Requirements: 3.4, 3.5, 3.6, 13.2, 13.10, 13.11, 23.1, 23.2, 23.3, 23.6, 23.7
class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to main screen',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveScaffold(
          builder: (context, layoutData) {
            if (weatherState.weatherData == null) {
              return _buildNoDataView(theme);
            }
            return _buildWeatherContent(
              context,
              theme,
              weatherState,
              layoutData,
            );
          },
        ),
      ),
    );
  }

  /// Builds the view shown when no weather data is available.
  Widget _buildNoDataView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No weather data available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              // Requirement 23.6: minimum 12sp for informational text
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Weather data will appear when received\nvia Meshtastic',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              // Requirement 23.6: minimum 12sp for informational text
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main weather content with responsive layout adaptation.
  ///
  /// In landscape or wider screens, uses a side-by-side layout with
  /// current temperature on the left and forecast on the right.
  /// In portrait or compact screens, uses a vertical stacked layout.
  ///
  /// Requirements: 23.1, 23.2, 23.3
  Widget _buildWeatherContent(
    BuildContext context,
    ThemeData theme,
    WeatherState weatherState,
    ResponsiveLayoutData layoutData,
  ) {
    final weatherData = weatherState.weatherData!;
    final isLandscapeOrWide =
        layoutData.isLandscape || layoutData.isExpanded;

    return Padding(
      padding: EdgeInsets.all(layoutData.isCompact ? 12.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // New data received indicator (Requirement 13.10, 13.11)
          if (weatherState.showNewDataIndicator)
            _buildNewDataIndicator(theme),

          // Main content area adapts based on orientation/breakpoint
          Expanded(
            child: isLandscapeOrWide
                ? _buildLandscapeLayout(theme, weatherData, layoutData)
                : _buildPortraitLayout(theme, weatherData, layoutData),
          ),

          SizedBox(height: layoutData.isCompact ? 8 : 16),

          // Timestamp and stored indicator (Requirements 3.5, 3.6)
          _buildTimestampRow(theme, weatherData),
        ],
      ),
    );
  }

  /// Portrait/compact layout: vertical stack with current temp on top,
  /// forecast below.
  Widget _buildPortraitLayout(
    ThemeData theme,
    WeatherData weatherData,
    ResponsiveLayoutData layoutData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCurrentTemperature(theme, weatherData, layoutData),
        SizedBox(height: layoutData.isCompact ? 12 : 24),
        Expanded(
          child: _buildForecastList(theme, weatherData, layoutData),
        ),
      ],
    );
  }

  /// Landscape/expanded layout: side-by-side with current temp on left,
  /// forecast on right.
  ///
  /// Requirement 23.3: Adapt layout for landscape orientation.
  Widget _buildLandscapeLayout(
    ThemeData theme,
    WeatherData weatherData,
    ResponsiveLayoutData layoutData,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Current temperature takes proportional space
        Expanded(
          flex: 2,
          child: _buildCurrentTemperature(theme, weatherData, layoutData),
        ),
        const SizedBox(width: 16),
        // Forecast list takes remaining space
        Expanded(
          flex: 3,
          child: _buildForecastList(theme, weatherData, layoutData),
        ),
      ],
    );
  }

  /// Builds the "new data received" indicator banner.
  /// Requirement 13.10: visual indicator distinguishable from static UI.
  /// Requirement 13.11: auto-clears after 5 seconds (handled by notifier).
  Widget _buildNewDataIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fiber_new,
              size: 20,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              'New data received',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                // Requirement 23.6: minimum 12sp
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the prominent current temperature display.
  /// Requirement 3.4: display current temperature prominently.
  /// Requirement 23.6: minimum 16sp for primary data displays.
  Widget _buildCurrentTemperature(
    ThemeData theme,
    WeatherData weatherData,
    ResponsiveLayoutData layoutData,
  ) {
    // Scale temperature font size based on available space
    final tempFontSize = layoutData.isCompact ? 48.0 : 64.0;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: layoutData.isCompact ? 16 : 24,
          horizontal: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                // Requirement 23.6: minimum 12sp for informational text
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${weatherData.currentTemp}°F',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  // Requirement 23.6: primary data display minimum 16sp
                  fontSize: tempFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the 4-hour forecast list.
  /// Requirement 3.4: hour label, weather glyph icon, temperature,
  /// and precipitation probability for each hour.
  Widget _buildForecastList(
    ThemeData theme,
    WeatherData weatherData,
    ResponsiveLayoutData layoutData,
  ) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.all(layoutData.isCompact ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '4-Hour Forecast',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                // Requirement 23.6: minimum 12sp
                fontSize: 14,
              ),
            ),
            SizedBox(height: layoutData.isCompact ? 8 : 12),
            Expanded(
              child: ListView.separated(
                itemCount: weatherData.forecasts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _buildForecastRow(
                    theme,
                    weatherData.forecasts[index],
                    layoutData,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single forecast row with hour, glyph icon, temp, and precip.
  /// Requirement 23.7: minimum 44x44 dp touch targets for interactive elements.
  Widget _buildForecastRow(
    ThemeData theme,
    HourForecast forecast,
    ResponsiveLayoutData layoutData,
  ) {
    final verticalPadding = layoutData.isCompact ? 8.0 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          // Hour label
          SizedBox(
            width: layoutData.isCompact ? 48 : 56,
            child: Text(
              forecast.hourLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                // Requirement 23.6: minimum 12sp
                fontSize: 14,
              ),
            ),
          ),

          // Weather glyph icon
          SizedBox(
            width: 40,
            child: Icon(
              _weatherIconForGlyph(forecast.glyphCode),
              size: 24,
              color: theme.colorScheme.primary,
              semanticLabel: forecast.glyphCode,
            ),
          ),

          // Temperature
          SizedBox(
            width: layoutData.isCompact ? 48 : 56,
            child: Text(
              '${forecast.temperature}°F',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                // Requirement 23.6: minimum 16sp for primary data
                fontSize: 16,
              ),
            ),
          ),

          // Precipitation probability
          Expanded(
            child: Text(
              forecast.precipitation.isEmpty
                  ? ''
                  : '${forecast.precipitation}%',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                // Requirement 23.6: minimum 12sp
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the timestamp row with received time and stored indicator.
  /// Requirement 3.5: timestamp in 12-hour format.
  /// Requirement 3.6: persist weather data (shown via "(stored)" indicator).
  Widget _buildTimestampRow(ThemeData theme, WeatherData weatherData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Received: ${weatherData.receivedTimestamp}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            // Requirement 23.6: minimum 12sp
            fontSize: 12,
          ),
        ),
        if (weatherData.isStored) ...[
          const SizedBox(width: 8),
          Text(
            '(stored)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.tertiary,
              fontStyle: FontStyle.italic,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Maps a weather glyph code string to a Material icon.
  ///
  /// The glyph codes come from HoT packets and represent weather conditions.
  /// Falls back to [Icons.cloud] for unrecognized codes.
  IconData _weatherIconForGlyph(String glyphCode) {
    final code = glyphCode.toLowerCase();
    if (code.contains('sun') || code.contains('clear')) {
      return Icons.wb_sunny;
    } else if (code.contains('cloud') || code.contains('overcast')) {
      return Icons.cloud;
    } else if (code.contains('rain') || code.contains('shower')) {
      return Icons.water_drop;
    } else if (code.contains('storm') || code.contains('thunder')) {
      return Icons.thunderstorm;
    } else if (code.contains('snow') || code.contains('flurr')) {
      return Icons.ac_unit;
    } else if (code.contains('fog') ||
        code.contains('mist') ||
        code.contains('haze')) {
      return Icons.foggy;
    } else if (code.contains('wind')) {
      return Icons.air;
    } else if (code.contains('part')) {
      return Icons.cloud_queue;
    }
    return Icons.cloud;
  }
}
