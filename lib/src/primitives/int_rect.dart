import 'dart:math' as math;
import 'int_point.dart';

final class IntRect {
  final int x;
  final int y;
  final int width;
  final int height;

  IntRect(this.x, this.y, this.width, this.height);

  IntRect.betweenXY(int startX, int startY, int endX, int endY)
    : this(startX, startY, endX - startX, endY - startY);

  IntRect.around(int x, int y, int radius)
    : this.betweenXY(x - radius, y - radius, x + radius + 1, y + radius + 1);

  IntRect intersect(IntRect other) => IntRect.betweenXY(
    math.max(left, other.left),
    math.max(top, other.top),
    math.min(right, other.right),
    math.min(bottom, other.bottom),
  );

  IntRect move(IntPoint delta) =>
      IntRect(x + delta.x, y + delta.y, width, height);

  int get left => x;

  int get top => y;

  int get right => x + width;

  int get bottom => y + height;

  IntPoint center() => IntPoint((right + left) ~/ 2, (top + bottom) ~/ 2);

  @override
  bool operator ==(covariant IntRect other) {
    if (identical(this, other)) return true;

    return other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode {
    return x.hashCode ^ y.hashCode ^ width.hashCode ^ height.hashCode;
  }
}
