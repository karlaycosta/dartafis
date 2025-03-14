import 'dart:math' as math;
import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/primitives/double_point.dart';
import 'package:dartafis/src/primitives/int_point.dart';

DoublePoint toVector(double angle) {
  return DoublePoint(math.cos(angle), math.sin(angle));
}

double atan(DoublePoint vector) {
  final angle = math.atan2(vector.y, vector.x);
  return angle >= 0 ? angle : angle + pi2;
}

double atanDouble(IntPoint center, IntPoint point) {
  return atan(point.minus(center).toDouble());
}

double add(double start, double delta) {
  final angle = start + delta;
  return angle < pi2 ? angle : angle - pi2;
}

int quantize(double angle, int resolution) {
  final result = (angle * 0.15915494309189535 * resolution).toInt();
  if (result < 0) {
    return 0;
  } else if (result >= resolution) {
    return resolution - 1;
  } else {
    return result;
  }
}
