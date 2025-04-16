import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/primitives/double_point.dart';

final class IntPoint implements Comparable<IntPoint> {
  final int x;
  final int y;

  IntPoint(this.x, this.y);

  factory IntPoint.zero() => IntPoint(0, 0);

  int getArea() => x * y;

  DoublePoint toDouble() => DoublePoint(x.toDouble(), y.toDouble());

  IntPoint negate() => IntPoint(-x, -y);

  int lengthSq() => sq(x) + sq(y);

  static final List<IntPoint> cornerNeighbors = <IntPoint>[
    IntPoint(-1, -1),
    IntPoint(0, -1),
    IntPoint(1, -1),
    IntPoint(-1, 0),
    IntPoint(1, 0),
    IntPoint(-1, 1),
    IntPoint(0, 1),
    IntPoint(1, 1),
  ];

  IntPoint plus(IntPoint other) => IntPoint(x + other.x, y + other.y);

  IntPoint minus(IntPoint other) => IntPoint(x - other.x, y - other.y);

  List<IntPoint> lineTo(IntPoint to) {
    var result = <IntPoint>[];
    final relative = to.minus(this);
    final rx = relative.x;
    final ry = relative.y;
    if (rx.abs() >= ry.abs()) {
      result = List<IntPoint>.filled(rx.abs() + 1, IntPoint.zero());
      if (rx > 0) {
        final slope = ry / rx;
        for (var i = 0; i <= rx; i++) {
          result[i] = IntPoint(x + i, y + (i * slope).round());
        }
      } else if (rx < 0) {
        final slope = ry / rx;
        for (var i = 0; i <= -rx; i++) {
          result[i] = IntPoint(x - i, y - (i * slope).round());
        }
      } else {
        result[0] = this;
      }
    } else {
      result = List<IntPoint>.filled(ry.abs() + 1, IntPoint.zero());
      if (ry > 0) {
        final slope = rx / ry;
        for (var i = 0; i <= ry; i++) {
          result[i] = IntPoint(x + (i * slope).round(), y + i);
        }
      } else if (ry < 0) {
        final slope = rx / ry;
        for (var i = 0; i <= -ry; i++) {
          result[i] = IntPoint(x - (i * slope).round(), y - i);
        }
      } else {
        result[0] = this;
      }
    }
    return result;
  }

  @override
  bool operator ==(covariant IntPoint other) {
    if (identical(this, other)) return true;
    return other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  String toString() => '[$x, $y]';

  @override
  int compareTo(IntPoint other) {
    final resultY = y.compareTo(other.y);

    if (resultY != 0) return resultY;

    return x.compareTo(other.x);
  }
}
