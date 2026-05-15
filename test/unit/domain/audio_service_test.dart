import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/domain/audio_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class FakeSource extends Fake implements Source {}

void main() {
  late MockAudioPlayer mockPlayer;
  late AudioServiceImpl audioService;

  setUpAll(() {
    registerFallbackValue(FakeSource());
  });

  setUp(() {
    mockPlayer = MockAudioPlayer();
    when(() => mockPlayer.setVolume(any())).thenAnswer((_) async {});
    when(() => mockPlayer.play(any())).thenAnswer((_) async {});
    when(() => mockPlayer.dispose()).thenAnswer((_) async {});
    audioService = AudioServiceImpl(initialVolume: 10, player: mockPlayer);
  });

  group('AudioServiceImpl', () {
    group('volume control', () {
      test('initial volume is set correctly', () {
        expect(audioService.volume, 10);
      });

      test('setVolume updates the volume level', () {
        audioService.setVolume(15);
        expect(audioService.volume, 15);
      });

      test('setVolume clamps to 0 minimum', () {
        audioService.setVolume(-5);
        expect(audioService.volume, 0);
      });

      test('setVolume clamps to 20 maximum', () {
        audioService.setVolume(25);
        expect(audioService.volume, 20);
      });

      test('initial volume is clamped to valid range', () {
        final service = AudioServiceImpl(initialVolume: 30, player: mockPlayer);
        expect(service.volume, 20);
      });

      test('initial volume below 0 is clamped', () {
        final service = AudioServiceImpl(initialVolume: -1, player: mockPlayer);
        expect(service.volume, 0);
      });
    });

    group('playback suppression at volume 0', () {
      test('playStartupTone does not play when volume is 0', () async {
        audioService.setVolume(0);
        await audioService.playStartupTone();
        verifyNever(() => mockPlayer.play(any()));
      });

      test('playMessageNotification does not play when volume is 0', () async {
        audioService.setVolume(0);
        await audioService.playMessageNotification();
        verifyNever(() => mockPlayer.play(any()));
      });

      test('playAlert does not play when volume is 0', () async {
        audioService.setVolume(0);
        await audioService.playAlert();
        verifyNever(() => mockPlayer.play(any()));
      });

      test('playConfirmation does not play when volume is 0', () async {
        audioService.setVolume(0);
        await audioService.playConfirmation();
        verifyNever(() => mockPlayer.play(any()));
      });

      test('playClick does not play when volume is 0', () async {
        audioService.setVolume(0);
        await audioService.playClick();
        verifyNever(() => mockPlayer.play(any()));
      });

      test('playError does not play when volume is 0', () async {
        audioService.setVolume(0);
        await audioService.playError();
        verifyNever(() => mockPlayer.play(any()));
      });
    });

    group('tone playback', () {
      test('playStartupTone plays startup asset', () async {
        await audioService.playStartupTone();
        final captured =
            verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource;
        expect(captured.path, 'audio/startup.mp3');
      });

      test('playMessageNotification plays message notification asset',
          () async {
        await audioService.playMessageNotification();
        final captured =
            verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource;
        expect(captured.path, 'audio/message_notification.mp3');
      });

      test('playAlert plays alert asset', () async {
        await audioService.playAlert();
        final captured =
            verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource;
        expect(captured.path, 'audio/alert.mp3');
      });

      test('playConfirmation plays confirmation asset', () async {
        await audioService.playConfirmation();
        final captured =
            verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource;
        expect(captured.path, 'audio/confirmation.mp3');
      });

      test('playClick plays click asset', () async {
        await audioService.playClick();
        final captured =
            verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource;
        expect(captured.path, 'audio/click.mp3');
      });

      test('playError plays error asset', () async {
        await audioService.playError();
        final captured =
            verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource;
        expect(captured.path, 'audio/error.mp3');
      });

      test('each tone uses a distinct asset path', () async {
        // Verify all 6 tones have unique asset paths
        final paths = <String>{};

        await audioService.playStartupTone();
        paths.add((verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource)
            .path);

        await audioService.playMessageNotification();
        paths.add((verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource)
            .path);

        await audioService.playAlert();
        paths.add((verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource)
            .path);

        await audioService.playConfirmation();
        paths.add((verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource)
            .path);

        await audioService.playClick();
        paths.add((verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource)
            .path);

        await audioService.playError();
        paths.add((verify(() => mockPlayer.play(captureAny())).captured.single
                as AssetSource)
            .path);

        expect(paths.length, 6, reason: 'All 6 tones must use distinct assets');
      });
    });

    group('volume normalization', () {
      test('volume 20 maps to 1.0', () async {
        audioService.setVolume(20);
        await audioService.playClick();
        verify(() => mockPlayer.setVolume(1.0)).called(1);
      });

      test('volume 10 maps to 0.5', () async {
        audioService.setVolume(10);
        await audioService.playClick();
        verify(() => mockPlayer.setVolume(0.5)).called(1);
      });

      test('volume 1 maps to 0.05', () async {
        audioService.setVolume(1);
        await audioService.playClick();
        verify(() => mockPlayer.setVolume(0.05)).called(1);
      });

      test('volume 5 maps to 0.25', () async {
        audioService.setVolume(5);
        await audioService.playClick();
        verify(() => mockPlayer.setVolume(0.25)).called(1);
      });
    });

    group('dispose', () {
      test('dispose calls player dispose', () {
        audioService.dispose();
        verify(() => mockPlayer.dispose()).called(1);
      });
    });
  });
}
