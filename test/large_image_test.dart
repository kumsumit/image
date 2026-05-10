import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
  group('Large Image Tests', () {
    test('Handle large image creation and basic operations', () {
      // Create a moderately large image to test memory handling
      const width = 4096;
      const height = 4096;
      final image = Image(width: width, height: height, numChannels: 3);

      expect(image.width, equals(width));
      expect(image.height, equals(height));
      expect(image.numChannels, equals(3));

      // Test basic operation like filling
      fill(image, color: ColorRgb8(255, 0, 0));

      // Verify a pixel
      final pixel = image.getPixel(0, 0);
      expect(pixel.r, equals(255));
      expect(pixel.g, equals(0));
      expect(pixel.b, equals(0));
    });

    test('Resize large image', () {
      final largeImage = Image(width: 2048, height: 2048, numChannels: 3);
      fill(largeImage, color: ColorRgb8(100, 150, 200));

      final resized = copyResize(largeImage, width: 512, height: 512);

      expect(resized.width, equals(512));
      expect(resized.height, equals(512));
      expect(resized.numChannels, equals(3));

      // Check that resize preserved approximate color
      final pixel = resized.getPixel(0, 0);
      expect(pixel.r, closeTo(100, 10)); // Allow some tolerance due to interpolation
      expect(pixel.g, closeTo(150, 10));
      expect(pixel.b, closeTo(200, 10));
    });

    test('Encode/decode large image', () {
      final largeImage = Image(width: 1024, height: 1024, numChannels: 4);
      fill(largeImage, color: ColorRgba8(255, 128, 64, 192));

      // Encode to PNG
      final encoded = encodePng(largeImage);
      expect(encoded.length, greaterThan(0));

      // Decode back
      final decoded = decodePng(encoded);
      expect(decoded, isNotNull);
      expect(decoded!.width, equals(1024));
      expect(decoded.height, equals(1024));
      expect(decoded.numChannels, equals(4));

      // Verify a pixel
      final pixel = decoded.getPixel(0, 0);
      expect(pixel.r, equals(255));
      expect(pixel.g, equals(128));
      expect(pixel.b, equals(64));
      expect(pixel.a, equals(192));
    });
  });
}