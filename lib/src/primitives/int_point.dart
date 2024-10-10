final class IntPoint {
  final int x;
  final int y;

  IntPoint(this.x, this.y);

  @override
  bool operator ==(covariant IntPoint other) =>
      identical(this, other) || (other.x == x && other.y == y);

  @override
  int get hashCode => x ^ y;
}
