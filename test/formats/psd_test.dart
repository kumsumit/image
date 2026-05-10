import 'dart:io';

import 'package:image/image.dart';
import 'package:test/test.dart';

import '../_test_util.dart';

void main() {
  group('Format', () {
    final dir = Directory('test/_data/psd');
    final files = dir.listSync()..sort((a, b) => a.path.compareTo(b.path));
    final expected = {
      'Unsupported compression.psd': (1280, 1680, Format.uint8, 3, 4282134492),
      'index should be less than.psd': (512, 672, Format.uint8, 4, 3518023280),
      'index should be less than_2.psd': (
        1280,
        1680,
        Format.uint8,
        3,
        3489854366,
      ),
      'psd1.psd': (32, 32, Format.uint8, 3, 1553051458),
      'psd2.psd': (32, 32, Format.uint8, 3, 2173642123),
      'psd3.psd': (32, 32, Format.uint8, 3, 1553051458),
      'psd4.psd': (32, 32, Format.uint8, 4, 4193452815),
      'psd5.psd': (32, 32, Format.uint8, 4, 2286879579),
      'psd6.psd': (200, 100, Format.uint8, 3, 881149464),
      'rectangles.psd': (375, 478, Format.uint8, 3, 2991210332),
      'rle_crash.psd': (619, 568, Format.uint8, 3, 163579131),
    };

    group('psd', () {
      for (final f in files.whereType<File>()) {
        if (!f.path.endsWith('.psd')) {
          continue;
        }

        final name = f.uri.pathSegments.last;
        test(name, () {
          final decoder = PsdDecoder();
          final psd = decoder.decode(f.readAsBytesSync());
          expect(psd, isNotNull);
          final info = expected[name]!;
          expect(psd!.width, equals(info.$1));
          expect(psd.height, equals(info.$2));
          expect(psd.format, equals(info.$3));
          expect(psd.numChannels, equals(info.$4));
          expect(hashImage(psd), equals(info.$5));
          File('$testOutputPath/psd/$name.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(encodePng(psd));

          var li = 0;
          for (final layer in decoder.info!.layers) {
            final layerImg = layer.layerImage;
            if (layerImg != null) {
              File('$testOutputPath/psd/${name}_${li}_${layer.name}.png')
                ..createSync(recursive: true)
                ..writeAsBytesSync(encodePng(layerImg));
            }
            ++li;
          }
        });
      }
    });

    test('psd palette support', () {
      // Test that palette is set for indexed color mode if present
      final decoder = PsdDecoder();
      final psd = decoder.decode(
        File('test/_data/psd/psd1.psd').readAsBytesSync(),
      );
      expect(psd, isNotNull);
      // Assuming psd1.psd is RGB, palette should be null
      expect(decoder.info!.palette, isNull);
    });
  });
}
