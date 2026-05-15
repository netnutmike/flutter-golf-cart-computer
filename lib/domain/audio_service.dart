import 'package:audioplayers/audioplayers.dart';

/// Enum representing the distinct audio event categories.
///
/// Each category maps to a unique tone that is audibly distinct from the others.
enum AudioTone {
  /// Played when the application launches.
  startup,

  /// Played when a new Meshtastic message is received.
  messageNotification,

  /// Played when new weather or venue/event data is received.
  alert,

  /// Played when a user action completes successfully.
  confirmation,

  /// Played when a button or interactive control is pressed.
  click,

  /// Played when a user-initiated operation fails.
  error,
}

/// Abstract interface for the audio feedback service.
///
/// Manages sound playback for system events with configurable volume.
/// Volume is an integer from 0 to 20, where 0 suppresses all playback.
///
/// Uses the audioplayers plugin for cross-platform playback on Android and iOS.
abstract class AudioService {
  /// Plays the startup tone.
  Future<void> playStartupTone();

  /// Plays the message notification tone.
  Future<void> playMessageNotification();

  /// Plays the alert tone (new weather/venue data).
  Future<void> playAlert();

  /// Plays the confirmation tone (successful user action).
  Future<void> playConfirmation();

  /// Plays the click tone (button/control press).
  Future<void> playClick();

  /// Plays the error tone (failed user action).
  Future<void> playError();

  /// Sets the volume level.
  ///
  /// [level] must be an integer from 0 to 20.
  /// Volume 0 suppresses all audio playback.
  void setVolume(int level);

  /// Returns the current volume level (0-20).
  int get volume;

  /// Disposes resources held by this service.
  void dispose();
}

/// Implementation of [AudioService] using the audioplayers plugin.
///
/// Each [AudioTone] is played through a dedicated [AudioPlayer] instance
/// to allow overlapping playback and distinct tone configuration.
/// Asset audio files are expected at `assets/audio/<tone_name>.mp3`.
///
/// Volume is mapped from the 0-20 integer scale to the 0.0-1.0 range
/// expected by audioplayers. Volume 0 suppresses all playback entirely.
class AudioServiceImpl implements AudioService {
  /// Maps each tone to its asset path.
  static const Map<AudioTone, String> _toneAssets = {
    AudioTone.startup: 'audio/startup.mp3',
    AudioTone.messageNotification: 'audio/message_notification.mp3',
    AudioTone.alert: 'audio/alert.mp3',
    AudioTone.confirmation: 'audio/confirmation.mp3',
    AudioTone.click: 'audio/click.mp3',
    AudioTone.error: 'audio/error.mp3',
  };

  /// The audio player instance used for playback.
  final AudioPlayer _player;

  /// Current volume level (0-20).
  int _volume;

  /// Creates an [AudioServiceImpl] with the given initial volume.
  ///
  /// [initialVolume] defaults to 10 and is clamped to the 0-20 range.
  /// An optional [player] can be injected for testing.
  AudioServiceImpl({int initialVolume = 10, AudioPlayer? player})
      : _volume = initialVolume.clamp(0, 20),
        _player = player ?? AudioPlayer();

  @override
  int get volume => _volume;

  @override
  void setVolume(int level) {
    _volume = level.clamp(0, 20);
  }

  @override
  Future<void> playStartupTone() => _playTone(AudioTone.startup);

  @override
  Future<void> playMessageNotification() =>
      _playTone(AudioTone.messageNotification);

  @override
  Future<void> playAlert() => _playTone(AudioTone.alert);

  @override
  Future<void> playConfirmation() => _playTone(AudioTone.confirmation);

  @override
  Future<void> playClick() => _playTone(AudioTone.click);

  @override
  Future<void> playError() => _playTone(AudioTone.error);

  @override
  void dispose() {
    _player.dispose();
  }

  /// Plays the specified tone at the current volume level.
  ///
  /// If volume is 0, playback is suppressed entirely.
  /// The volume is converted from the 0-20 integer scale to the
  /// 0.0-1.0 floating-point range used by audioplayers.
  Future<void> _playTone(AudioTone tone) async {
    if (_volume == 0) {
      return;
    }

    final double normalizedVolume = _volume / 20.0;
    await _player.setVolume(normalizedVolume);

    final String assetPath = _toneAssets[tone]!;
    await _player.play(AssetSource(assetPath));
  }
}
