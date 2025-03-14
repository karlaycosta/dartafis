import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/primitives/block_map.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/double_angle.dart' as double_angle;
import 'package:dartafis/src/primitives/double_matrix.dart';
import 'package:dartafis/src/primitives/double_point_matrix.dart';
import 'package:dartafis/src/extractor/pixelwise_orientations.dart'
    as pixelwise;
import 'package:dartafis/src/primitives/int_rect.dart';

@pragma('vm:align-loops')
DoublePointMatrix aggregate(
  DoublePointMatrix orientation,
  BlockMap blocks,
  BooleanMatrix mask,
) {
  final primary = blocks.primary;
  final width = primary.blocks.x;
  final height = primary.blocks.y;
  final sums = DoublePointMatrix(width: width, height: height);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      if (mask.get(xi, yi)) {
        final area = primary.block(xi, yi);
        final top = area.top;
        final bottom = area.bottom;
        final left = area.left;
        final right = area.right;
        for (var y = top; y < bottom; y++) {
          for (var x = left; x < right; x++) {
            sums.add(xi, yi, orientation.get(x, y));
          }
        }
      }
    }
  }
  return sums;
}

@pragma('vm:align-loops')
DoublePointMatrix smooth2(DoublePointMatrix orientation, BooleanMatrix mask) {
  final width = mask.width;
  final height = mask.height;
  final smoothed = DoublePointMatrix(width: width, height: height);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      if (mask.get(xi, yi)) {
        final neighbors = IntRect.around(
          xi,
          yi,
          orientationSmoothingRadius,
        ).intersect(IntRect(0, 0, width, height));
        final top = neighbors.top;
        final bottom = neighbors.bottom;
        final left = neighbors.left;
        final right = neighbors.right;
        for (var ny = top; ny < bottom; ny++) {
          for (var nx = left; nx < right; nx++) {
            if (mask.get(nx, ny)) {
              smoothed.add(xi, yi, orientation.get(nx, ny));
            }
          }
        }
      }
    }
  }
  return smoothed;
}

@pragma('vm:align-loops')
DoubleMatrix angles(DoublePointMatrix vectors, BooleanMatrix mask) {
  final width = mask.width;
  final height = mask.height;
  final angles = DoubleMatrix(width: width, height: height);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      if (mask.get(xi, yi)) {
        angles.set(xi, yi, double_angle.atan(vectors.get(xi, yi)));
      }
    }
  }
  return angles;
}

DoubleMatrix blockCompute(
  DoubleMatrix image,
  BooleanMatrix mask,
  BlockMap blocks,
) {
  final accumulated = pixelwise.compute(image, mask, blocks);
  final byBlock = aggregate(accumulated, blocks, mask);
  final smooth = smooth2(byBlock, mask);
  return angles(smooth, mask);
}
