import 'dart:io';
import 'package:image/image.dart';
import 'package:test/test.dart';

import '../_test_util.dart';

void main() {
  group('Format', () {
    group('exr', () {
      test('grid', () {
        final bytes = File('test/_data/exr/grid.exr').readAsBytesSync();

        final dec = ExrDecoder()..startDecode(bytes);
        final img = dec.decodeFrame(0)!;
        expect(img.width, equals(512));
        expect(img.height, equals(512));
        expect(img.format, equals(Format.float16));
        expect(img.numChannels, equals(3));
        expect(hashImage(img), equals(2513588955));

        final png = PngEncoder().encode(img);
        File('$testOutputPath/exr/grid.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(png);
      });

      test('ocean', () {
        final bytes = File('test/_data/exr/ocean.exr').readAsBytesSync();

        final dec = ExrDecoder()..startDecode(bytes);
        final img = dec.decodeFrame(0)!;
        expect(img.width, equals(300));
        expect(img.height, equals(209));
        expect(img.format, equals(Format.float16));
        expect(img.numChannels, equals(3));
        expect(hashImage(img), equals(4127337651));

        final png = PngEncoder().encode(img);
        File('$testOutputPath/exr/ocean.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(png);
      });
    });
  });
}
