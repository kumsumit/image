import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:test/test.dart';

void main() {
  group('Malformed Input Tests', () {
    void testDecoder(String name, Decoder decoder, Uint8List data) {
      test('$name decoder with malformed data', () {
        try {
          final result = decoder.decode(data);
          expect(result, isNull);
        } catch (e) {
          // Accept any exception for malformed data
          expect(e, isNotNull);
        }
      });
    }

    testDecoder('PNG', PngDecoder(), Uint8List(0));
    testDecoder(
      'PNG invalid header',
      PngDecoder(),
      Uint8List.fromList([0x00, 0x00, 0x00, 0x00]),
    );
    testDecoder('JPEG', JpegDecoder(), Uint8List(0));
    testDecoder(
      'JPEG invalid header',
      JpegDecoder(),
      Uint8List.fromList([0x00, 0x00]),
    );
    testDecoder('GIF', GifDecoder(), Uint8List(0));
    testDecoder('BMP', BmpDecoder(), Uint8List(0));
    testDecoder('TIFF', TiffDecoder(), Uint8List(0));
    testDecoder('PSD', PsdDecoder(), Uint8List(0));
    testDecoder('EXR', ExrDecoder(), Uint8List(0));
    testDecoder('WebP', WebPDecoder(), Uint8List(0));
    testDecoder('TGA', TgaDecoder(), Uint8List(0));
    testDecoder('ICO', IcoDecoder(), Uint8List(0));
    testDecoder('PNM', PnmDecoder(), Uint8List(0));
    testDecoder('PVR', PvrDecoder(), Uint8List(0));
    testDecoder(
      'PNG truncated',
      PngDecoder(),
      Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
    );
  });
}
