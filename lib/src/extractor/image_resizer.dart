import 'package:dartafis/src/primitives/double_matrix.dart';

DoubleMatrix imageResizer(DoubleMatrix input, double dpi) {
  final div = 500 / dpi;
  final width = (div * input.width).round();
  final height = (div * input.height).round();

  if (width == input.width && height == input.height) return input;

  DoubleMatrix output = DoubleMatrix(width: width, height: height);
  final scaleX = width / input.width;
  final scaleY = height / input.height;
  final descaleX = 1 / scaleX;
  final descaleY = 1 / scaleY;
  for (int y = 0; y < height; y++) {
    final y1 = y * descaleY;
    final y2 = y1 + descaleY;
    final y1i = y1.toInt();
    final y2i = y2.ceil().clamp(0, input.height);
    for (int x = 0; x < width; x++) {
      final x1 = x * descaleX;
      final x2 = x1 + descaleX;
      final x1i = x1.toInt();
      final x2i = x2.ceil().clamp(0, input.width);
      double sum = 0;
      for (int oy = y1i; oy < y2i; oy++) {
        final ry = (oy + 1).clamp(0, y2) - oy.clamp(y1, y2);
        for (int ox = x1i; ox < x2i; ox++) {
          final rx = (ox + 1).clamp(0, x2) - ox.clamp(x1, x2);
          final value = input.get(ox, oy);
          sum += rx * ry * value;
        }
      }
      output.set(x, y, sum * (scaleX * scaleY));
    }
  }
  return output;
}
