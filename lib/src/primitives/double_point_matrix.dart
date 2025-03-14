import 'dart:typed_data';

import 'package:dartafis/src/primitives/double_point.dart';

final class DoublePointMatrix {
  final int width;
  final int height;
  final Float64List cells;

  DoublePointMatrix({
    required this.width,
    required this.height,
    Float64List? cells,
  }) : cells = cells ?? Float64List(2 * width * height);

  void add(int x, int y, DoublePoint point) {
    final i = 2 * (y * width + x);
    cells[i] += point.x;
    cells[i + 1] += point.y;
  }

  DoublePoint get(int x, int y) {
    final i = 2 * (y * width + x);
    return DoublePoint(cells[i], cells[i + 1]);
  }
}
