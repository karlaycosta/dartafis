import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/primitives/block_map.dart';
import 'package:dartafis/src/primitives/double_matrix.dart';
import 'package:dartafis/src/primitives/histogram_cube.dart';

@pragma('vm:align-loops')
HistogramCube histogramCreate(BlockMap blocks, DoubleMatrix image) {
  final width = blocks.primary.blocks.x;
  final height = blocks.primary.blocks.y;
  final out = HistogramCube(width: width, height: height, bins: histogramDepth);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      final area = blocks.primary.block(xi, yi);
      final top = area.top;
      final bottom = area.bottom;
      final left = area.left;
      final right = area.right;

      for (int y = top; y < bottom; ++y) {
        for (int x = left; x < right; ++x) {
          final depth = (image.get(x, y) * histogramDepth).toInt();
          out.increment(xi, yi, out.constrain(depth));
        }
      }
    }
  }
  return out;
}

@pragma('vm:align-loops')
HistogramCube histogramSmooth(BlockMap blocks, HistogramCube input) {
  final width = blocks.secondary.blocks.x;
  final height = blocks.secondary.blocks.y;
  final pW = blocks.primary.blocks.x;
  final pH = blocks.primary.blocks.y;
  final bins = input.bins;
  final blocksAround = [(0, 0), (-1, 0), (0, -1), (-1, -1)];
  final out = HistogramCube(width: width, height: height, bins: bins);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      for (final (rX, rY) in blocksAround) {
        final (x, y) = (xi + rX, yi + rY);
        if ((x >= 0 && y >= 0 && x < pW && y < pH)) {
          for (int i = 0; i < bins; i++) {
            out.add(xi, yi, i, input.get(x, y, i));
          }
        }
      }
    }
  }
  return out;
}
