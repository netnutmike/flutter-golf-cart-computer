import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart' hide expect, group, test, setUp, tearDown;
import 'package:glados/glados.dart';
import 'package:golf_cart_computer/domain/brightness_manager.dart';

/// Custom generators for brightness property tests.
extension BrightnessGenerators on Any {
  /// Generates a brightness level in the valid range (0-10).
  Generator<int> get brightnessLevel => intInRange(0, 10);

  /// Generates an hour of day (0-23).
  Generator<int> get hourOfDay => intInRange(0, 23);

  /// Generates a minute (0-59).
  Generator<int> get minute => intInRange(0, 59);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the platform channel to prevent MissingPluginException
  const channel = MethodChannel('com.golfcart/brightness');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // =================================================================
  // Property 19: Brightness level selection
  // =================================================================
  group('Property 19: Brightness level selection', () {
    /// **Validates: Requirements 10.1, 10.2**
    ///
    /// For any current time between sunrise and sunset, the brightness
    /// level should be the configured day brightness value.
    Glados3(any.brightnessLevel, any.brightnessLevel, any.minute).test(
      'day brightness is selected when current time is between sunrise and sunset',
      (dayBrightness, nightBrightness, minuteOffset) {
        final manager = DefaultBrightnessManager(
          dayBrightness: dayBrightness,
          nightBrightness: nightBrightness,
          inactivityTimeoutMinutes: 0, // Disable auto-dimming
          methodChannel: channel,
        );

        // Sunrise at 6:00, sunset at 20:00
        final baseDate = DateTime(2024, 6, 15);
        final sunrise = baseDate.add(const Duration(hours: 6));
        final sunset = baseDate.add(const Duration(hours: 20));

        // Current time is between sunrise and sunset (e.g., 10:00 + minuteOffset)
        // Use minuteOffset to vary the time within the daytime window
        final now = sunrise.add(Duration(minutes: minuteOffset));

        // Only test if now is still before sunset
        if (now.isBefore(sunset)) {
          manager.updateTimeContext(now, sunrise, sunset);

          expect(manager.currentState.currentLevel, equals(dayBrightness),
              reason:
                  'At $now (between sunrise $sunrise and sunset $sunset), '
                  'brightness should be day=$dayBrightness but got ${manager.currentState.currentLevel}');
          expect(manager.currentState.isDaytime, isTrue);
        }

        manager.dispose();
      },
    );

    /// **Validates: Requirements 10.1, 10.2**
    ///
    /// For any current time before sunrise, the brightness level should
    /// be the configured night brightness value.
    Glados3(any.brightnessLevel, any.brightnessLevel, any.minute).test(
      'night brightness is selected when current time is before sunrise',
      (dayBrightness, nightBrightness, minuteOffset) {
        final manager = DefaultBrightnessManager(
          dayBrightness: dayBrightness,
          nightBrightness: nightBrightness,
          inactivityTimeoutMinutes: 0, // Disable auto-dimming
          methodChannel: channel,
        );

        // Sunrise at 6:00, sunset at 20:00
        final baseDate = DateTime(2024, 6, 15);
        final sunrise = baseDate.add(const Duration(hours: 6));
        final sunset = baseDate.add(const Duration(hours: 20));

        // Current time is before sunrise (e.g., 5:00 minus minuteOffset minutes)
        final now = sunrise.subtract(Duration(minutes: minuteOffset + 1));

        manager.updateTimeContext(now, sunrise, sunset);

        expect(manager.currentState.currentLevel, equals(nightBrightness),
            reason:
                'At $now (before sunrise $sunrise), '
                'brightness should be night=$nightBrightness but got ${manager.currentState.currentLevel}');
        expect(manager.currentState.isDaytime, isFalse);

        manager.dispose();
      },
    );

    /// **Validates: Requirements 10.1, 10.2**
    ///
    /// For any current time at or after sunset, the brightness level should
    /// be the configured night brightness value.
    Glados3(any.brightnessLevel, any.brightnessLevel, any.minute).test(
      'night brightness is selected when current time is at or after sunset',
      (dayBrightness, nightBrightness, minuteOffset) {
        final manager = DefaultBrightnessManager(
          dayBrightness: dayBrightness,
          nightBrightness: nightBrightness,
          inactivityTimeoutMinutes: 0, // Disable auto-dimming
          methodChannel: channel,
        );

        // Sunrise at 6:00, sunset at 20:00
        final baseDate = DateTime(2024, 6, 15);
        final sunrise = baseDate.add(const Duration(hours: 6));
        final sunset = baseDate.add(const Duration(hours: 20));

        // Current time is at or after sunset
        final now = sunset.add(Duration(minutes: minuteOffset));

        manager.updateTimeContext(now, sunrise, sunset);

        expect(manager.currentState.currentLevel, equals(nightBrightness),
            reason:
                'At $now (at/after sunset $sunset), '
                'brightness should be night=$nightBrightness but got ${manager.currentState.currentLevel}');
        expect(manager.currentState.isDaytime, isFalse);

        manager.dispose();
      },
    );

    /// **Validates: Requirements 10.1, 10.2**
    ///
    /// The brightness level at exactly sunrise should be day brightness
    /// (sunrise is inclusive in the daytime range).
    Glados2(any.brightnessLevel, any.brightnessLevel).test(
      'day brightness is selected at exactly sunrise time (inclusive boundary)',
      (dayBrightness, nightBrightness) {
        final manager = DefaultBrightnessManager(
          dayBrightness: dayBrightness,
          nightBrightness: nightBrightness,
          inactivityTimeoutMinutes: 0,
          methodChannel: channel,
        );

        final baseDate = DateTime(2024, 6, 15);
        final sunrise = baseDate.add(const Duration(hours: 6));
        final sunset = baseDate.add(const Duration(hours: 20));

        // Current time is exactly at sunrise
        manager.updateTimeContext(sunrise, sunrise, sunset);

        expect(manager.currentState.currentLevel, equals(dayBrightness),
            reason:
                'At exactly sunrise, brightness should be day=$dayBrightness');
        expect(manager.currentState.isDaytime, isTrue);

        manager.dispose();
      },
    );

    /// **Validates: Requirements 10.1, 10.2**
    ///
    /// The brightness level at exactly sunset should be night brightness
    /// (sunset is exclusive from the daytime range).
    Glados2(any.brightnessLevel, any.brightnessLevel).test(
      'night brightness is selected at exactly sunset time (exclusive boundary)',
      (dayBrightness, nightBrightness) {
        final manager = DefaultBrightnessManager(
          dayBrightness: dayBrightness,
          nightBrightness: nightBrightness,
          inactivityTimeoutMinutes: 0,
          methodChannel: channel,
        );

        final baseDate = DateTime(2024, 6, 15);
        final sunrise = baseDate.add(const Duration(hours: 6));
        final sunset = baseDate.add(const Duration(hours: 20));

        // Current time is exactly at sunset
        manager.updateTimeContext(sunset, sunrise, sunset);

        expect(manager.currentState.currentLevel, equals(nightBrightness),
            reason:
                'At exactly sunset, brightness should be night=$nightBrightness');
        expect(manager.currentState.isDaytime, isFalse);

        manager.dispose();
      },
    );

    /// **Validates: Requirements 10.1, 10.2**
    ///
    /// Brightness selection is consistent: calling updateTimeContext
    /// multiple times with the same parameters produces the same result.
    Glados2(any.brightnessLevel, any.brightnessLevel).test(
      'brightness selection is deterministic (same inputs → same output)',
      (dayBrightness, nightBrightness) {
        final manager = DefaultBrightnessManager(
          dayBrightness: dayBrightness,
          nightBrightness: nightBrightness,
          inactivityTimeoutMinutes: 0,
          methodChannel: channel,
        );

        final baseDate = DateTime(2024, 6, 15);
        final sunrise = baseDate.add(const Duration(hours: 6));
        final sunset = baseDate.add(const Duration(hours: 20));
        final now = baseDate.add(const Duration(hours: 12));

        manager.updateTimeContext(now, sunrise, sunset);
        final firstLevel = manager.currentState.currentLevel;
        final firstIsDaytime = manager.currentState.isDaytime;

        manager.updateTimeContext(now, sunrise, sunset);
        final secondLevel = manager.currentState.currentLevel;
        final secondIsDaytime = manager.currentState.isDaytime;

        expect(firstLevel, equals(secondLevel));
        expect(firstIsDaytime, equals(secondIsDaytime));

        manager.dispose();
      },
    );
  });
}
