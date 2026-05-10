import 'dart:math';
import 'dart:typed_data';

import '../image/image.dart';

const _lanczosRadius = 3;

double _sinc(double x) {
  if (x == 0) {
    return 1;
  }
  final pix = pi * x;
  return sin(pix) / pix;
}

double _lanczos(double x) {
  x = x.abs();
  if (x >= _lanczosRadius) {
    return 0;
  }
  return _sinc(x) * _sinc(x / _lanczosRadius);
}

/// Resample [src] into [dst] using a separable Lanczos-3 filter.
void lanczosResize(
  Image src,
  Image dst, {
  required int dstX,
  required int dstY,
  required int width,
  required int height,
}) {
  final scaleX = src.width / width;
  final scaleY = src.height / height;
  final filterScaleX = max(1.0, scaleX);
  final filterScaleY = max(1.0, scaleY);
  final supportX = _lanczosRadius * filterScaleX;
  final supportY = _lanczosRadius * filterScaleY;

  final tmp = Float64List(width * src.height * 4);
  final srcPixel = src.getPixelSafe(0, 0);

  for (var y = 0; y < src.height; ++y) {
    for (var x = 0; x < width; ++x) {
      final center = x * scaleX;
      final start = (center - supportX).floor();
      final end = (center + supportX).ceil();
      var r = 0.0;
      var g = 0.0;
      var b = 0.0;
      var a = 0.0;
      var totalWeight = 0.0;

      for (var sx = start; sx <= end; ++sx) {
        final weight = _lanczos((center - sx) / filterScaleX);
        if (weight == 0) {
          continue;
        }
        src.getPixelClamped(sx, y, srcPixel);
        r += srcPixel.r * weight;
        g += srcPixel.g * weight;
        b += srcPixel.b * weight;
        a += srcPixel.a * weight;
        totalWeight += weight;
      }

      final ti = (y * width + x) * 4;
      if (totalWeight == 0) {
        src.getPixelClamped(center.round(), y, srcPixel);
        tmp[ti] = srcPixel.r.toDouble();
        tmp[ti + 1] = srcPixel.g.toDouble();
        tmp[ti + 2] = srcPixel.b.toDouble();
        tmp[ti + 3] = srcPixel.a.toDouble();
      } else {
        final inv = 1.0 / totalWeight;
        tmp[ti] = r * inv;
        tmp[ti + 1] = g * inv;
        tmp[ti + 2] = b * inv;
        tmp[ti + 3] = a * inv;
      }
    }
  }

  for (var y = 0; y < height; ++y) {
    final center = y * scaleY;
    final start = (center - supportY).floor();
    final end = (center + supportY).ceil();
    final dy = dstY + y;

    for (var x = 0; x < width; ++x) {
      var r = 0.0;
      var g = 0.0;
      var b = 0.0;
      var a = 0.0;
      var totalWeight = 0.0;

      for (var sy = start; sy <= end; ++sy) {
        final weight = _lanczos((center - sy) / filterScaleY);
        if (weight == 0) {
          continue;
        }
        final cy = sy.clamp(0, src.height - 1);
        final ti = (cy * width + x) * 4;
        r += tmp[ti] * weight;
        g += tmp[ti + 1] * weight;
        b += tmp[ti + 2] * weight;
        a += tmp[ti + 3] * weight;
        totalWeight += weight;
      }

      if (totalWeight == 0) {
        final sy = center.round().clamp(0, src.height - 1);
        final ti = (sy * width + x) * 4;
        dst.setPixelRgba(
          dstX + x,
          dy,
          tmp[ti],
          tmp[ti + 1],
          tmp[ti + 2],
          tmp[ti + 3],
        );
      } else {
        final inv = 1.0 / totalWeight;
        dst.setPixelRgba(dstX + x, dy, r * inv, g * inv, b * inv, a * inv);
      }
    }
  }
}
