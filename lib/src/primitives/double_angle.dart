import 'dart:math' as math;

import 'double_point.dart';

final class DoubleAngle {
  static const double pi2 = 2 * math.pi;
  static const double halfPi = 0.5 * math.pi;


  static double atan(DoublePoint vector) {
    final angle = math.atan2(vector.y, vector.x);
    return angle >= 0 ? angle : angle + pi2;
  }
}
