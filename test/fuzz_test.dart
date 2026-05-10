import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
  group('Fuzz Tests', () {
    final random = Random(42); // Seeded for reproducibility

    Uint8List generateRandomBytes(int length) {
      final bytes = Uint8List(length);
      for (var i = 0; i < length; i++) {
        bytes[i] = random.nextInt(256);
      }
      return bytes;
    }

    test('PNG decoder fuzz test', () {
      for (var i = 0; i < 10; i++) {
        final randomData = generateRandomBytes(100 + random.nextInt(1000));
        // Should not crash, may return null or throw exception
        try {
          PngDecoder().decode(randomData);
        } catch (e) {
          // Expected for invalid data
          expect(e, isA<ImageException>());
        }
      }
    });

    test('JPEG decoder fuzz test', () {
      for (var i = 0; i < 10; i++) {
        final randomData = generateRandomBytes(100 + random.nextInt(1000));
        try {
          JpegDecoder().decode(randomData);
        } catch (e) {
          expect(e, isA<ImageException>());
        }
      }
    });

    test('BMP decoder fuzz test', () {
      for (var i = 0; i < 10; i++) {
        final randomData = generateRandomBytes(50 + random.nextInt(500));
        try {
          BmpDecoder().decode(randomData);
        } catch (e) {
          expect(e, isA<ImageException>());
        }
      }
    });

    test('GIF decoder fuzz test', () {
      for (var i = 0; i < 10; i++) {
        final randomData = generateRandomBytes(50 + random.nextInt(500));
        try {
          GifDecoder().decode(randomData);
        } catch (e) {
          expect(e, isA<ImageException>());
        }
      }
    });
  });
}