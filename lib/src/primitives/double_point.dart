final class DoublePoint {
  final double x;
  final double y;
  const DoublePoint(this.x, this.y);

  @override
  bool operator ==(covariant DoublePoint other) =>
      identical(this, other) || (other.x == x && other.y == y);

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
