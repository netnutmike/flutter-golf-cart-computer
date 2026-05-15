/// Brightness domain models for the Golf Cart Computer.
///
/// Contains display brightness state managed by the BrightnessManager
/// based on time of day and user activity.
library;

/// Current state of the display brightness system.
class BrightnessState {
  /// Current brightness level (0-10 scale).
  final int currentLevel;

  /// Whether the display is currently dimmed due to inactivity timeout.
  final bool isDimmed;

  /// Whether it is currently daytime (between sunrise and sunset).
  final bool isDaytime;

  const BrightnessState({
    required this.currentLevel,
    required this.isDimmed,
    required this.isDaytime,
  });
}
