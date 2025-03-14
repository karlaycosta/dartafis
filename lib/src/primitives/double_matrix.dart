import 'dart:typed_data';

final class DoubleMatrix {
  final int width;
  final int height;
  final Float64List cells;

  DoubleMatrix({
    required this.width,
    required this.height,
    Float64List? cells,
  }) : cells = cells ?? Float64List(width * height);

  double get(int x, int y) => cells[y * width + x];

  void set(int x, int y, double value) => cells[y * width + x] = value;

  void add(int x, int y, double value) => cells[y * width + x] += value;

  void multiply(int x, int y, double value) => cells[y * width + x] *= value;
}
