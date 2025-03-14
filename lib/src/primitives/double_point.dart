import 'package:dartafis/src/primitives/int_point.dart';

class DoublePoint {
  final double x;
  final double y;

  DoublePoint(this.x, this.y);

  DoublePoint multiply(double factor) => DoublePoint(factor * x, factor * y);

  IntPoint round() => IntPoint(x.round(), y.round());

  @override
  String toString() => '[$x, $y]';
}
