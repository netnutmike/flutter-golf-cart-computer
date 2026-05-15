/// Odometer domain models for the Golf Cart Computer.
///
/// Contains distance tracking state for total and trip odometers,
/// plus driving hours for service reminders.
library;

/// Current state of the odometer and service tracking.
class OdometerState {
  /// Total distance traveled in miles (1 decimal place, rolls at 100,000).
  final double totalMiles;

  /// Trip distance in miles (1 decimal place, rolls at 10,000).
  final double tripMiles;

  /// Driving hours since last service in tenths of hours.
  final double hoursSinceService;

  const OdometerState({
    required this.totalMiles,
    required this.tripMiles,
    required this.hoursSinceService,
  });
}
