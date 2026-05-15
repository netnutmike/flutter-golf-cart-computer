/// GCI communication protocol domain models for the Golf Cart Computer.
///
/// Contains the message envelope and payload types for communication
/// with the GCI ESP-32 vehicle telemetry computer via Bluetooth.
library;

import 'dart:typed_data';

/// GCI message types matching the ESP-NOW packet structure.
enum GciMessageType {
  /// Text message.
  text(0),

  /// GPS data payload (GCD → GCI, 24 bytes).
  gpsData(1),

  /// Telemetry data payload (GCI → GCD, 20 bytes).
  telemetry(2),

  /// Command payload (e.g., pairing).
  command(3),

  /// Acknowledgment response.
  ack(4),

  /// Heartbeat keep-alive.
  heartbeat(5),

  /// At-home status notification (single byte: 1=true, 0=false).
  isHome(6),

  /// Daytime status notification (single byte: 1=true, 0=false).
  isDaytime(7);

  /// Numeric code for this message type (used in the wire protocol).
  final int code;

  const GciMessageType(this.code);

  /// Look up a message type by its numeric code.
  /// Returns null if the code is not recognized.
  static GciMessageType? fromCode(int code) {
    for (final type in values) {
      if (type.code == code) return type;
    }
    return null;
  }
}

/// GCI message envelope (9-byte header + variable payload).
///
/// Wire format:
/// ```
/// | type (1 byte) | timestamp (4 bytes LE) | seq_num (2 bytes LE) | data_len (2 bytes LE) | data (variable) |
/// ```
class GciMessage {
  /// Message type.
  final GciMessageType type;

  /// Unix timestamp in seconds (uint32).
  final int timestamp;

  /// Sequence number (uint16).
  final int sequenceNumber;

  /// Message payload bytes.
  final Uint8List payload;

  const GciMessage({
    required this.type,
    required this.timestamp,
    required this.sequenceNumber,
    required this.payload,
  });
}

/// Telemetry payload received from GCI (20 bytes, little-endian).
class GciTelemetryPayload {
  /// Headlight mode indicator.
  final int modeLights;

  /// Outdoor luminosity reading.
  final int outdoorLum;

  /// Air temperature in degrees Fahrenheit.
  final double airTemp;

  /// Battery voltage.
  final double battVolts;

  /// Fuel level percentage.
  final double fuel;

  const GciTelemetryPayload({
    required this.modeLights,
    required this.outdoorLum,
    required this.airTemp,
    required this.battVolts,
    required this.fuel,
  });
}

/// GPS payload sent from GCD to GCI (24 bytes, little-endian).
class GciGpsPayload {
  /// Latitude in decimal degrees.
  final double latitude;

  /// Longitude in decimal degrees.
  final double longitude;

  /// Altitude in meters.
  final double altitude;

  /// Speed in mph.
  final double speed;

  /// Heading in degrees.
  final double heading;

  /// Number of GPS satellites in view.
  final int satelliteCount;

  const GciGpsPayload({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.satelliteCount,
  });
}

/// Command payload sent from GCD to GCI.
class GciCommandPayload {
  /// Command number (e.g., GCI_CMD_ADD_PEER = 1).
  final int cmdNumber;

  /// MAC address bytes (6 bytes).
  final Uint8List macAddress;

  const GciCommandPayload({
    required this.cmdNumber,
    required this.macAddress,
  });
}
