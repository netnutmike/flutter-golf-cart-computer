import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/data/services/background_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackgroundService abstract interface', () {
    test('PlatformBackgroundService implements BackgroundService', () {
      // Verify the implementation satisfies the abstract contract.
      // We use a mock method channel handler to avoid platform exceptions.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(
            'com.golfcart.golf_cart_computer/background_service'),
        (MethodCall methodCall) async => null,
      );

      final service = PlatformBackgroundService();
      expect(service, isA<BackgroundService>());
      service.dispose();

      // Clean up mock handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(
            'com.golfcart.golf_cart_computer/background_service'),
        null,
      );
    });
  });

  group('PlatformBackgroundService', () {
    late PlatformBackgroundService service;
    final List<MethodCall> methodCalls = [];

    setUp(() {
      methodCalls.clear();

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(
            'com.golfcart.golf_cart_computer/background_service'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          return null;
        },
      );

      service = PlatformBackgroundService();
    });

    tearDown(() {
      service.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(
            'com.golfcart.golf_cart_computer/background_service'),
        null,
      );
    });

    test('isRunningInBackground returns a broadcast stream', () {
      final stream = service.isRunningInBackground;
      expect(stream.isBroadcast, isTrue);
    });

    test('dispose closes the stream controller', () async {
      service.dispose();
      // After dispose, the stream should be done.
      expect(
        service.isRunningInBackground.isEmpty,
        completion(isTrue),
      );
    });

    test(
        'startForegroundService is a no-op on non-Android platforms',
        () async {
      // On macOS (test environment), this should not invoke the method channel
      // because Platform.isAndroid is false.
      await service.startForegroundService();
      // No method calls should be made on non-Android platforms
      expect(methodCalls, isEmpty);
    },
        skip: 'Platform.isAndroid cannot be mocked in unit tests; '
            'tested via integration tests on device');

    test(
        'stopForegroundService is a no-op on non-Android platforms',
        () async {
      await service.stopForegroundService();
      expect(methodCalls, isEmpty);
    },
        skip: 'Platform.isAndroid cannot be mocked in unit tests; '
            'tested via integration tests on device');
  });

  group('PlatformBackgroundService - method channel behavior', () {
    test(
        'startForegroundService handles MissingPluginException gracefully',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(
            'com.golfcart.golf_cart_computer/background_service'),
        (MethodCall methodCall) async {
          throw MissingPluginException('Not implemented');
        },
      );

      final service = PlatformBackgroundService();
      // Should not throw
      await service.startForegroundService();
      service.dispose();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(
            'com.golfcart.golf_cart_computer/background_service'),
        null,
      );
    });

    test(
        'stopForegroundService handles MissingPluginException gracefully',
        () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(
            'com.golfcart.golf_cart_computer/background_service'),
        (MethodCall methodCall) async {
          throw MissingPluginException('Not implemented');
        },
      );

      final service = PlatformBackgroundService();
      // Should not throw
      await service.stopForegroundService();
      service.dispose();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(
            'com.golfcart.golf_cart_computer/background_service'),
        null,
      );
    });
  });
}
