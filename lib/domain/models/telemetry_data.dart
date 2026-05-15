/// Telemetry domain models for the Golf Cart Computer.
///
/// Contains vehicle telemetry data received from the GCI ESP-32 computer
/// via Bluetooth.
library;

/// Vehicle telemetry data received from the GCI.
class TelemetryData {
  /// Headlight mode indicator (integer value from GCI).
  final int headlightMode;

  /// Outdoor luminosity reading.
  final int outdoorLuminosity;

  /// Air temperature in degrees Fahrenheit.
  final double airTemperature;

  /// Battery voltage (e.g., 48.2).
  final double batteryVoltage;

  /// Fuel level as a percentage (0.0 to 100.0).
  final double fuelLevel;

  /// Timestamp of the last telemetry update.
  final DateTime lastUpdated;

  const TelemetryData({
    required this.headlightMode,
    required this.outdoorLuminosity,
    required this.airTemperature,
    required this.batteryVoltage,
    required this.fuelLevel,
    required this.lastUpdated,
  });
}
