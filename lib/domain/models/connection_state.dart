/// Connection state models for the Golf Cart Computer.
///
/// Defines the possible states for Bluetooth connections to the
/// Meshtastic radio and GCI telemetry computer.
library;

/// Represents the current state of a Bluetooth connection.
enum ConnectionState {
  /// No active connection.
  disconnected,

  /// Actively scanning for devices.
  scanning,

  /// Connection attempt in progress.
  connecting,

  /// BLE link established but not yet operational.
  connected,

  /// Meshtastic-specific: config download/handshake in progress.
  handshaking,

  /// Fully operational and ready for data exchange.
  ready,

  /// Connection lost, attempting automatic reconnection.
  reconnecting,
}
