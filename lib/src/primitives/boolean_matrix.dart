import 'dart:convert';
import 'package:crypto/crypto.dart';

class BooleanMatrix {
  final int width;
  final int height;
  final List<bool> cells;

  BooleanMatrix({
    required this.width,
    required this.height,
    List<bool>? cells,
  }) : cells = cells ??
            List.filled(width * height, false);

  void set(int x, int y, bool value) => cells[y * width + x] = value;

  void invert() {
    final length = cells.length;
    for (var i = 0; i < length; i++) {
      // TODO: Testar essa melhoria de desempenho;
      // cells[i];
      cells[i] = !cells[i];
    }
  }

  void merge(BooleanMatrix other) {
    if (other.width != width || other.height != height) {
      throw ArgumentError('O tamanho da matriz não confere!');
    }
    final length = cells.length;
    for (var i = 0; i < length; i++) {
      // TODO: Testar essa melhoria de desempenho;
      // cells[i];
      cells[i] |= other.cells[i];
    }
  }

  bool getF(int x, int y, bool fallback) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return fallback;
    }
    return cells[y * width + x];
  }

  bool get(int x, int y) => cells[y * width + x];

  String hash() {
    final count = cells.length;
    final buffer = StringBuffer();
    for (var i = 0; i < count; i++) {
      buffer.write(cells[i] ? 1 : 0);
    }
    return buffer.toString();
  }

  @override
  String toString() =>
      md5.convert(utf8.encode(hash())).toString().toUpperCase();
}
