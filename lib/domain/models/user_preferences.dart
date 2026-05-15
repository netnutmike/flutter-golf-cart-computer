/// User preferences domain models for the Golf Cart Computer.
///
/// Contains all configurable user settings with their default values.
library;

/// All user-configurable preferences with defaults.
class UserPreferences {
  /// Day brightness level (0-10 scale, default 7).
  final int dayBrightness;

  /// Night brightness level (0-10 scale, default 3).
  final int nightBrightness;

  /// Speaker volume (0-20, default 10). Volume 0 suppresses all playback.
  final int speakerVolume;

  /// Whether the screen display is flipped/rotated (default false).
  final bool flipScreen;

  /// Inactivity timeout before screen dims, in minutes (0-60, default 5).
  /// A value of 0 disables auto-dimming.
  final int backlightTimeoutMinutes;

  /// Temperature display offset in degrees Fahrenheit (-20 to +20, default 0).
  final int temperatureOffset;

  /// Service reminder interval in hours (1-500, default 100).
  final int serviceIntervalHours;

  /// Paired GCI device Bluetooth address, or null if not paired.
  final String? gciDeviceAddress;

  /// Home location latitude, or null if not set.
  final double? homeLatitude;

  /// Home location longitude, or null if not set.
  final double? homeLongitude;

  /// Geofence radius in meters (100-5000, default 500).
  final int homeFenceRadiusMeters;

  /// Whether Meshtastic radio connection is enabled (default false).
  final bool meshtasticEnabled;

  /// Persisted Meshtastic device identifier for auto-reconnection.
  final String? meshtasticDeviceId;

  const UserPreferences({
    this.dayBrightness = 7,
    this.nightBrightness = 3,
    this.speakerVolume = 10,
    this.flipScreen = false,
    this.backlightTimeoutMinutes = 5,
    this.temperatureOffset = 0,
    this.serviceIntervalHours = 100,
    this.gciDeviceAddress,
    this.homeLatitude,
    this.homeLongitude,
    this.homeFenceRadiusMeters = 500,
    this.meshtasticEnabled = false,
    this.meshtasticDeviceId,
  });

  /// Default preferences instance with all values at their defaults.
  static const UserPreferences defaults = UserPreferences();
}
