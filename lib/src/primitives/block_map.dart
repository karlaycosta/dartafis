import 'block_grid.dart';
import 'int_point.dart';

int _roundUpDiv(int dividend, int divisor) {
  return (dividend + divisor - 1) ~/ divisor;
}

final class BlockMap {
  final int width;
  final int height;
  final BlockGrid primary;
  final BlockGrid secondary;

  BlockMap._(this.width, this.height, this.primary, this.secondary);

  factory BlockMap(int width, int height, int maxBlockSize) {
    final pbx = _roundUpDiv(width, maxBlockSize);
    final pby = _roundUpDiv(height, maxBlockSize);
    final primary = BlockGrid(IntPoint(pbx, pby));
    final secondary = BlockGrid(primary.corners);

    for (int y = 0; y <= pby; y++) {
      primary.y[y] = y * height ~/ pby;
    }

    for (int x = 0; x <= pbx; x++) {
      primary.x[x] = x * width ~/ pbx;
    }

    for (int y = 0; y < pby; y++) {
      secondary.y[y + 1] = primary.block(0, y).center().y;
    }
    secondary.y[secondary.blocks.y] = height;

    for (int x = 0; x < pbx; x++) {
      secondary.x[x + 1] = primary.block(x, 0).center().x;
    }
    secondary.x[secondary.blocks.x] = width;

    return BlockMap._(width, height, primary, secondary);
  }

  int get area => width * height;
}
