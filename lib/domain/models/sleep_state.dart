/// Sleep and power management domain models for the Golf Cart Computer.
///
/// Contains the three-state power management system that determines
/// display behavior based on GCI connection status.
library;

/// The three operating modes of the power management system.
enum OperatingMode {
  /// Initial state after startup; waiting for GCI to connect.
  startupGrace,

  /// GCI is connected and communicating; display stays active.
  gciMode,

  /// Operating without GCI; display dims per backlight timeout.
  standaloneMode,
}

/// Current state of the sleep/power management system.
class SleepState {
  /// Current operating mode.
  final OperatingMode mode;

  /// Whether the display is currently dimmed due to inactivity.
  final bool isDisplayDimmed;

  /// Time remaining in the startup grace period.
  final Duration gracePeriodRemaining;

  const SleepState({
    required this.mode,
    required this.isDisplayDimmed,
    required this.gracePeriodRemaining,
  });
}
