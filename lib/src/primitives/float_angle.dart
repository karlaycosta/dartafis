import 'dart:math' as math;

import 'double_angle.dart';

final class FloatAngle {
  static const double pi2 = DoubleAngle.pi2;
  static const double pi = math.pi;
  static const double halfPi = DoubleAngle.halfPi;

  static double add(double start, double delta) {
    final double angle = start + delta;
    return angle < pi2 ? angle : angle - pi2;
  }

  static double difference(double first, double second) {
    final double angle = first - second;
    return angle >= 0 ? angle : angle + pi2;
  }

  static double distance(double first, double second) {
    final double delta = (first - second).abs();
    return delta <= pi ? delta : pi2 - delta;
  }

  static double opposite(double angle) {
    return angle < pi ? angle + pi : angle - pi;
  }

  static double complementary(double angle) {
    final double complement = pi2 - angle;
    return complement < pi2 ? complement : complement - pi2;
  }
}
