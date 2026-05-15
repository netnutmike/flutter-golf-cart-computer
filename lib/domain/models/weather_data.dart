/// Weather domain models for the Golf Cart Computer.
///
/// Contains weather forecast data parsed from HoT packets received via
/// Meshtastic mesh network.
library;

/// A single hour's weather forecast entry.
class HourForecast {
  /// Hour label, e.g., "10am" (≤6 characters).
  final String hourLabel;

  /// Weather icon/glyph identifier (≤10 characters).
  final String glyphCode;

  /// Forecast temperature in degrees Fahrenheit.
  final int temperature;

  /// Precipitation probability as a string.
  /// Empty string if the original value was "0.0".
  final String precipitation;

  const HourForecast({
    required this.hourLabel,
    required this.glyphCode,
    required this.temperature,
    required this.precipitation,
  });
}

/// Parsed weather data from a HoT weather packet.
class WeatherData {
  /// Current temperature in degrees Fahrenheit.
  final int currentTemp;

  /// Exactly 4 hourly forecast entries.
  final List<HourForecast> forecasts;

  /// Timestamp when data was received, in 12-hour format (e.g., "2:35 PM").
  final String receivedTimestamp;

  /// Whether this data was loaded from cache rather than received live.
  final bool isStored;

  const WeatherData({
    required this.currentTemp,
    required this.forecasts,
    required this.receivedTimestamp,
    this.isStored = false,
  });
}
