import 'dart:math' as math;

import '../configuration/parameters.dart';

typedef DoublePoint = ({double x, double y});
const polarCacheBits = 8;
const polarCacheRadius = 1 << polarCacheBits;
const polarCacheLength = polarCacheRadius * polarCacheRadius;

double atan(DoublePoint vector) {
  final angle = math.atan2(vector.y, vector.x);
  return angle >= 0 ? angle : angle + pi2;
}

class EdgeShape {
  static bool _isLoad = false;
  static final List<int> polarDistanceCache =
      List<int>.filled(polarCacheLength, 0);
  static final List<double> polarAngleCache =
      List<double>.filled(polarCacheLength, 0.0);

  late final int length;
  late final double referenceAngle;
  late final double neighborAngle;

  static _load() {
    if (_isLoad) return;
    for (int y = 0; y < polarCacheRadius; y++) {
      for (int x = 0; x < polarCacheRadius; x++) {
        final index = y * polarCacheRadius + x;
        polarDistanceCache[index] = math.sqrt(x * x + y * y).round();
        polarAngleCache[index] =
            (y > 0 || x > 0) ? atan((x: x.toDouble(), y: y.toDouble())) : 0.0;
      }
    }
    _isLoad = true;
  }

  EdgeShape(FeatureMinutia reference, FeatureMinutia neighbor) {
    _load();
    double quadrant = 0;
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
