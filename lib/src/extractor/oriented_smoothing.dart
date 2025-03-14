import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/primitives/block_map.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/double_matrix.dart';
import 'package:dartafis/src/primitives/int_point.dart';
import 'package:dartafis/src/primitives/double_angle.dart' as double_angle;
import 'package:dartafis/src/primitives/int_rect.dart';

@pragma('vm:align-loops')
List<List<IntPoint>> lines(int resolution, int radius, double step) {
  final result = List<List<IntPoint>>.filled(resolution, []);
  final resolution2 = 2 * resolution;
  for (int orientationIndex = 0;
      orientationIndex < resolution;
      orientationIndex++) {
    final line = <IntPoint>[IntPoint.zero()];
    final direction = double_angle
        .toVector((pi2 * (2 * orientationIndex + 1) / resolution2) * 0.5);
    for (double r = radius.toDouble(); r >= 0.5; r /= step) {
      final sample = direction.multiply(r).round();
      if (line.contains(sample) == false) {
        line.add(sample);
        line.add(sample.negate());
      }
    }
    result[orientationIndex] = line;
  }
  return result;
}

@pragma('vm:align-loops')
DoubleMatrix smooth(
  DoubleMatrix input,
  DoubleMatrix orientation,
  BooleanMatrix mask,
  BlockMap blocks,
  double angle,
  List<List<IntPoint>> lines,
) {
  final output = DoubleMatrix(width: input.width, height: input.height);
  final width = blocks.primary.blocks.x;
  final height = blocks.primary.blocks.y;
  final pixel = IntRect(0, 0, blocks.width, blocks.height);
  final count = lines.length;
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      if (mask.get(xi, yi)) {
        final line = lines[double_angle.quantize(
          double_angle.add(orientation.get(xi, yi), angle),
          count,
        )];
        final length = line.length;
        for (var i = 0; i < length; i++) {
          var target = blocks.primary.block(xi, yi);
          final linePoint = line[i];
          final source = target.move(linePoint).intersect(pixel);
          target = source.move(linePoint.negate());
          final top = target.top;
          final bottom = target.bottom;
          final left = target.left;
          final right = target.right;
          for (int y = top; y < bottom; ++y) {
            for (int x = left; x < right; ++x) {
              output.add(x, y, input.get(x + linePoint.x, y + linePoint.y));
            }
          }
        }
        final blockArea = blocks.primary.block(xi, yi);
        final top = blockArea.top;
        final bottom = blockArea.bottom;
        final left = blockArea.left;
        final right = blockArea.right;
        for (int y = top; y < bottom; ++y) {
          for (int x = left; x < right; ++x) {
            output.multiply(x, y, 1.0 / length);
          }
        }
      }
    }
  }
  return output;
}

DoubleMatrix parallel(
  DoubleMatrix input,
  DoubleMatrix orientation,
  BooleanMatrix mask,
  BlockMap blocks,
) {
  final lines_ = lines(
    parallelSmoothingResolution,
    parallelSmoothingRadius,
    parallelSmoothingStep,
  );
  return smooth(input, orientation, mask, blocks, 0, lines_);
}

DoubleMatrix orthogonal(
  DoubleMatrix input,
  DoubleMatrix orientation,
  BooleanMatrix mask,
  BlockMap blocks,
) {
  final lines_ = lines(
    orthogonalSmoothingResolution,
    orthogonalSmoothingRadius,
    orthogonalSmoothingStep,
  );
 return smooth(input, orientation, mask, blocks, pi, lines_);
}
