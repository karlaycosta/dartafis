import 'dart:math' as math;

import '../primitives/double_angle.dart';
import '../primitives/double_point.dart';
import '../primitives/float_angle.dart';
import '../primitives/integers.dart';
import 'search_minutia.dart';

class EdgeShape {
  static bool _isLoad = false;
  static const polarCacheBits = 8;
  static const polarCacheRadius = 1 << polarCacheBits;
  static final polarDistanceCache =
      List.filled(Integers.sq(polarCacheRadius), 0);
  static final polarAngleCache =
      List.filled(Integers.sq(polarCacheRadius), 0.0);

  late final int length;
  late final double referenceAngle;
  late final double neighborAngle;

  static _load() {
    if (_isLoad) return;

    for (int y = 0; y < polarCacheRadius; y++) {
      for (int x = 0; x < polarCacheRadius; x++) {
        polarDistanceCache[y * polarCacheRadius + x] =
            math.sqrt(Integers.sq(x) + Integers.sq(y)).round();
        if (y > 0 || x > 0) {
          polarAngleCache[y * polarCacheRadius + x] =
              DoubleAngle.atan(DoublePoint(x.toDouble(), y.toDouble()));
        } else {
          polarAngleCache[y * polarCacheRadius + x] = 0;
        }
      }
    }

    _isLoad = true;
  }

  EdgeShape(SearchMinutia reference, SearchMinutia neighbor) {
    _load();
    double quadrant = 0;
    int x = neighbor.x - reference.x;
    int y = neighbor.y - reference.y;
    if (y < 0) {
      x = -x;
      y = -y;
      quadrant = FloatAngle.pi;
    }
    if (x < 0) {
      int tmp = -x;
      x = y;
      y = tmp;
      quadrant += FloatAngle.halfPi;
    }
    final shift =
        32 - Integers.numberOfLeadingZeros((x | y) >>> polarCacheBits);
    final offset = (y >> shift) * polarCacheRadius + (x >> shift);
    length = (polarDistanceCache[offset] << shift);
    final angle = polarAngleCache[offset] + quadrant;
    referenceAngle = FloatAngle.difference(reference.direction, angle);
    neighborAngle = FloatAngle.difference(
      neighbor.direction,
      FloatAngle.opposite(angle),
    );
  }
}
