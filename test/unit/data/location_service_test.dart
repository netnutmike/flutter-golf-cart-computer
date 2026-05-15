import 'package:flutter_test/flutter_test.dart';
import 'package:golf_cart_computer/data/services/location_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocationService abstract interface', () {
    test('GeolocatorLocationService implements LocationService', () {
      final service = GeolocatorLocationService();
      expect(service, isA<LocationService>());
    });

    test('positionStream returns a Stream', () {
      final service = GeolocatorLocationService();
      expect(service.positionStream, isA<Stream>());
    });

    test('positionStream returns same instance on repeated access', () {
      final service = GeolocatorLocationService();
      final stream1 = service.positionStream;
      final stream2 = service.positionStream;
      expect(identical(stream1, stream2), isTrue);
    });
  });
}
