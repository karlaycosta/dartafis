import 'dart:typed_data';

import 'int_point.dart';
import 'int_rect.dart';

final class BlockGrid {
  final IntPoint blocks;
  final IntPoint corners;
  final Uint16List x;
  final Uint16List y;

  BlockGrid(IntPoint size)
    : blocks = size,
      corners = IntPoint(size.x + 1, size.y + 1),
      x = Uint16List(size.x + 1),
      y = Uint16List(size.y + 1);

  IntPoint corner(int x, int y) => IntPoint(this.x[x], this.y[y]);

  IntRect block(int x, int y) {
    final cornerX = corner(x, y);
    final cornerY = corner(x + 1, y + 1);
    return IntRect.betweenXY(cornerX.x, cornerX.y, cornerY.x, cornerY.y);
  }
}
