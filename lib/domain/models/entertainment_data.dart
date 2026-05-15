/// Entertainment domain models for the Golf Cart Computer.
///
/// Contains venue and event data parsed from HoT packets received via
/// Meshtastic mesh network.
library;

/// A single venue/event pair from the entertainment schedule.
class VenueEvent {
  /// Name of the venue.
  final String venueName;

  /// Name of the event at this venue.
  final String eventName;

  const VenueEvent({
    required this.venueName,
    required this.eventName,
  });
}

/// Parsed entertainment data from a HoT venue/event packet.
class EntertainmentData {
  /// List of venue/event pairs (up to 12).
  final List<VenueEvent> venues;

  /// Timestamp when data was received, in 12-hour format (e.g., "2:35 PM").
  final String receivedTimestamp;

  /// Whether this data was loaded from cache rather than received live.
  final bool isStored;

  const EntertainmentData({
    required this.venues,
    required this.receivedTimestamp,
    this.isStored = false,
  });
}
