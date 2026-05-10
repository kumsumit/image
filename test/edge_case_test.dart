import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
  group('Edge Case Tests', () {
    test('Empty image operations', () {
      final emptyImage = Image(width: 0, height: 0);
      expect(emptyImage.width, equals(0));
      expect(emptyImage.height, equals(0));
      // Operations on empty image should not crash
      final resized = copyResize(emptyImage, width: 10, height: 10);
      expect(resized.width, equals(10));
      expect(resized.height, equals(10));
    });

    test('Single pixel image', () {
      final pixelImage = Image(width: 1, height: 1, numChannels: 4)
        ..setPixel(0, 0, ColorRgba8(255, 128, 64, 192));

      final pixel = pixelImage.getPixel(0, 0);
      expect(pixel.r, equals(255));
      expect(pixel.g, equals(128));
      expect(pixel.b, equals(64));
      expect(pixel.a, equals(192));

      // Test operations
      final resized = copyResize(pixelImage, width: 2, height: 2);
      expect(resized.width, equals(2));
      expect(resized.height, equals(2));
    });

    test('Image with alpha channel', () {
      final image = Image(width: 10, height: 10, numChannels: 4);
      fill(image, color: ColorRgba8(100, 150, 200, 0)); // Transparent

      final pixel = image.getPixel(0, 0);
      expect(pixel.a, equals(0));

      // Composite with another image
      final bg = Image(width: 10, height: 10, numChannels: 4);
      fill(bg, color: ColorRgba8(255, 0, 0, 255)); // Red background

      final composited = compositeImage(bg, image);
      final compPixel = composited.getPixel(0, 0);
      expect(compPixel.r, equals(255)); // Should show background
      expect(compPixel.g, equals(0));
      expect(compPixel.b, equals(0));
      expect(compPixel.a, equals(255));
    });

    test('Invalid crop parameters', () {
      final image = Image(width: 100, height: 100);
      // Crop with negative x/y should handle gracefully
      final cropped = copyCrop(image, x: -10, y: -10, width: 50, height: 50);
      expect(cropped.width, equals(50));
      expect(cropped.height, equals(50));
    });

    test('Large dimension resize', () {
      final smallImage = Image(width: 2, height: 2);
      fill(smallImage, color: ColorRgb8(255, 255, 255));

      // Resize to very large
      final large = copyResize(smallImage, width: 1000, height: 1000);
      expect(large.width, equals(1000));
      expect(large.height, equals(1000));
    });
  });
}
