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
        final alpha = srcPixel.a.toDouble();
        r += srcPixel.r * alpha * weight;
        g += srcPixel.g * alpha * weight;
        b += srcPixel.b * alpha * weight;
        a += alpha * weight;
        totalWeight += weight;
      }

      final ti = (y * width + x) * 4;
      if (totalWeight == 0) {
        src.getPixelClamped(center.round(), y, srcPixel);
        final alpha = srcPixel.a.toDouble();
        tmp[ti] = srcPixel.r * alpha;
        tmp[ti + 1] = srcPixel.g * alpha;
        tmp[ti + 2] = srcPixel.b * alpha;
        tmp[ti + 3] = alpha;
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
        final alpha = tmp[ti + 3];
        final invAlpha = alpha == 0 ? 0 : 1.0 / alpha;
        dst.setPixelRgba(
          dstX + x,
          dy,
          tmp[ti] * invAlpha,
          tmp[ti + 1] * invAlpha,
          tmp[ti + 2] * invAlpha,
          alpha,
        );
      } else {
        final inv = 1.0 / totalWeight;
        final alpha = a * inv;
        final invAlpha = alpha == 0 ? 0 : 1.0 / alpha;
        dst.setPixelRgba(
          dstX + x,
          dy,
          r * inv * invAlpha,
          g * inv * invAlpha,
          b * inv * invAlpha,
          alpha,
        );
      }
    }
  }
}
