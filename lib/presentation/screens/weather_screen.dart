import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../application/weather_notifier.dart';
import '../../domain/models/weather_data.dart';

/// Weather forecast screen displaying current temperature and 4-hour forecast.
///
/// Uses Riverpod [ConsumerWidget] to watch [weatherNotifierProvider] for
/// reactive state updates. Displays:
/// - Current temperature prominently
/// - 4-hour forecast with hour label, weather glyph icon, temperature,
///   and precipitation probability
/// - Received timestamp in 12-hour format
/// - "(stored)" indicator for cached data
/// - "new data received" indicator with auto-clear
/// - Navigation back to main screen
///
/// Requirements: 3.4, 3.5, 3.6, 13.2, 13.10, 13.11
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
        child: weatherState.weatherData == null
            ? _buildNoDataView(theme)
            : _buildWeatherContent(context, theme, weatherState),
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
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Weather data will appear when received\nvia Meshtastic',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main weather content with current temp, forecast, and metadata.
  Widget _buildWeatherContent(
    BuildContext context,
    ThemeData theme,
    WeatherState weatherState,
  ) {
    final weatherData = weatherState.weatherData!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // New data received indicator (Requirement 13.10, 13.11)
          if (weatherState.showNewDataIndicator)
            _buildNewDataIndicator(theme),

          // Current temperature display (Requirement 3.4)
          _buildCurrentTemperature(theme, weatherData),

          const SizedBox(height: 24),

          // 4-hour forecast (Requirement 3.4)
          Expanded(
            child: _buildForecastList(theme, weatherData),
          ),

          const SizedBox(height: 16),

          // Timestamp and stored indicator (Requirements 3.5, 3.6)
          _buildTimestampRow(theme, weatherData),
        ],
      ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the prominent current temperature display.
  /// Requirement 3.4: display current temperature prominently.
  Widget _buildCurrentTemperature(ThemeData theme, WeatherData weatherData) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              'Current',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${weatherData.currentTemp}°F',
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
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
  Widget _buildForecastList(ThemeData theme, WeatherData weatherData) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '4-Hour Forecast',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: weatherData.forecasts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _buildForecastRow(
                    theme,
                    weatherData.forecasts[index],
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
  Widget _buildForecastRow(ThemeData theme, HourForecast forecast) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Hour label
          SizedBox(
            width: 56,
            child: Text(
              forecast.hourLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
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
            width: 56,
            child: Text(
              '${forecast.temperature}°F',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
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
          ),
        ),
        if (weatherData.isStored) ...[
          const SizedBox(width: 8),
          Text(
            '(stored)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.tertiary,
              fontStyle: FontStyle.italic,
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
    } else if (code.contains('fog') || code.contains('mist') || code.contains('haze')) {
      return Icons.foggy;
    } else if (code.contains('wind')) {
      return Icons.air;
    } else if (code.contains('part')) {
      return Icons.cloud_queue;
    }
    return Icons.cloud;
  }
}
