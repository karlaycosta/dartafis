import 'dart:typed_data';

final class IntMatrix {
  final int width;
  final int height;
  final Uint16List cells;

  IntMatrix({required this.width, required this.height, Uint16List? cells})
    : cells = cells ?? Uint16List(width * height);

  int get(int x, int y) => cells[y * width + x];

  void set(int x, int y, int value) => cells[y * width + x] = value;
}
