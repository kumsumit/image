import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
  group('Property-Based Tests', () {
    test('Resize maintains aspect ratio when keeping aspect', () {
      final image = Image(width: 100, height: 200, numChannels: 3);
      fill(image, color: ColorRgb8(255, 255, 255));

      final resized = copyResize(image, width: 50);
      expect(resized.height, equals(100)); // Half height for aspect
    });

    test('Crop does not exceed image bounds', () {
      final image = Image(width: 100, height: 100, numChannels: 3);
      final cropped = copyCrop(image, x: 10, y: 10, width: 50, height: 50);
      expect(cropped.width, equals(50));
      expect(cropped.height, equals(50));
    });

    test('Rotate 90 degrees changes dimensions appropriately', () {
      final image = Image(width: 100, height: 200, numChannels: 3);
      final rotated = copyRotate(image, angle: 90);
      expect(rotated.width, equals(200));
      expect(rotated.height, equals(100));
    });

    test('Grayscale preserves dimensions', () {
      final image = Image(width: 10, height: 10, numChannels: 3);
      final gray = grayscale(image);
      expect(gray.width, equals(10));
      expect(gray.height, equals(10));
      // Grayscale may keep channels as 1 or 3 depending on implementation
      expect(gray.numChannels, anyOf(equals(1), equals(3)));
    });

    test('Invert preserves dimensions and channels', () {
      final image = Image(width: 20, height: 20, numChannels: 4);
      final inverted = invert(image);
      expect(inverted.width, equals(20));
      expect(inverted.height, equals(20));
      expect(inverted.numChannels, equals(4));
    });

    test('Blur preserves dimensions', () {
      final image = Image(width: 32, height: 32, numChannels: 3);
      final blurred = gaussianBlur(image, radius: 2);
      expect(blurred.width, equals(32));
      expect(blurred.height, equals(32));
      expect(blurred.numChannels, equals(3));
    });
  });
}