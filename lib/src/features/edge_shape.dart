import 'dart:math' as math;

import '../configuration/parameters.dart';

double atan(int x, int y) {
  final angle = math.atan2(y, x);
  return angle >= 0 ? angle : angle + pi2;
}

double opposite(double angle) {
  return angle < pi ? angle + pi : angle - pi;
}

/// Retorna o número de zero bits que precedem o bit de ordem mais alta ("mais à esquerda")
/// na representação binária de complemento de dois do valor [int] especificado. Retorna 32
/// se o valor especificado não tiver um bit em sua representação em complemento de dois,
/// ou seja, se for igual a zero.
int numberOfLeadingZeros(int i) {
  if (i <= 0) return i < 0 ? 0 : 32;
  int n = 1;
  if (i >> 16 == 0) {
    n += 16;
    i <<= 16;
  }
  if (i >> 24 == 0) {
    n += 8;
    i <<= 8;
  }
  if (i >> 28 == 0) {
    n += 4;
    i <<= 4;
  }
  if (i >> 30 == 0) {
    n += 2;
    i <<= 2;
  }
  n -= i >> 31;
  return n;
}

const double halfPi = 0.5 * math.pi;

class EdgeShape {
  static bool _isLoad = false;
  static final polarCacheBits = 8;
  static final polarCacheRadius = 1 << polarCacheBits;
  static final polarCacheLength = polarCacheRadius * polarCacheRadius;
  static final List<int> polarDistanceCache = List<int>.generate(
    polarCacheLength,
    (_) => 0,
    growable: false,
  );
  static final List<double> polarAngleCache = List<double>.generate(
    polarCacheLength,
    (_) => 0.0,
    growable: false,
  );

  late final int length;
  late final double referenceAngle;
  late final double neighborAngle;

  static _load() {
    if (_isLoad) return;
    for (int y = 0; y < polarCacheRadius; y++) {
      for (int x = 0; x < polarCacheRadius; x++) {
        final index = y * polarCacheRadius + x;
        polarDistanceCache[index] = math.sqrt(x * x + y * y).round();
        polarAngleCache[index] = (y > 0 || x > 0) ? atan(x, y) : 0.0;
      }
    }
    _isLoad = true;
  }

  EdgeShape(FeatureMinutia reference, FeatureMinutia neighbor) {
    _load();
    double quadrant = 0.0;
    int x = neighbor.x - reference.x;
    int y = neighbor.y - reference.y;
    if (y < 0) {
      x = -x;
      y = -y;
      quadrant = pi;
    }
    if (x < 0) {
      final int tmp = x;
      x = y;
      y = -tmp;
      quadrant += halfPi;
    }
    final int shift = 32 - numberOfLeadingZeros((x | y) >>> polarCacheBits);
    final int offset = (y >> shift) * polarCacheRadius + (x >> shift);
    length = polarDistanceCache[offset] << shift;
    final double angle = polarAngleCache[offset] + quadrant;
    referenceAngle = difference(reference.direction, angle);
    neighborAngle = difference(neighbor.direction, opposite(angle));
  }
}
