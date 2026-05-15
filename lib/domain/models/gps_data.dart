/// GPS domain models for the Golf Cart Computer.
///
/// Contains processed GPS state, navigation data, and raw position input.
library;

/// GPS position data received from a Meshtastic radio.
class MeshtasticPosition {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speedMph;
  final double headingDegrees;
  final int satelliteCount;
  final DateTime timestamp;

  const MeshtasticPosition({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speedMph,
    required this.headingDegrees,
    required this.satelliteCount,
    required this.timestamp,
  });
}

/// Raw GPS position input from device sensor or Meshtastic radio.
class RawPosition {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speedMph;
  final double headingDegrees;
  final int satelliteCount;
  final double? hdop;
  final DateTime timestamp;
  final bool isValid;

  const RawPosition({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speedMph,
    required this.headingDegrees,
    required this.satelliteCount,
    this.hdop,
    required this.timestamp,
    required this.isValid,
  });
}

/// Processed GPS data after speed filtering and validation.
class ProcessedGpsData {
  final double latitude;
  final double longitude;
  final double altitude;
  final int speedMph;
  final double rawSpeedMph;
  final double headingDegrees;
  final String cardinalDirection;
  final int satelliteCount;
  final double hdop;
  final DateTime timestamp;
  final bool isValid;

  const ProcessedGpsData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speedMph,
    required this.rawSpeedMph,
    required this.headingDegrees,
    required this.cardinalDirection,
    required this.satelliteCount,
    required this.hdop,
    required this.timestamp,
    required this.isValid,
  });
}

/// Navigation display data derived from GPS state.
class NavigationData {
  final String dateString;
  final String timeString;
  final String sunriseTime;
  final String sunsetTime;
  final bool isDaytime;

  const NavigationData({
    required this.dateString,
    required this.timeString,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.isDaytime,
  });
}
