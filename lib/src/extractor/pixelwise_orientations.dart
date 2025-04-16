import 'dart:math' as math;
import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/primitives/block_map.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/double_angle.dart' as double_angle;
import 'package:dartafis/src/primitives/double_matrix.dart';
import 'package:dartafis/src/primitives/double_point.dart';
import 'package:dartafis/src/primitives/double_point_matrix.dart';
import 'package:dartafis/src/primitives/int_point.dart';

final class OrientationRandom {
  int state = 536871037;

  double get next {
    state *= 1610612741;
    return ((state & 1073741823) + 0.5) * 9.313225746154785e-10;
  }
}

final class ConsideredOrientation {
  IntPoint offset = IntPoint.zero();
  DoublePoint orientation = DoublePoint(0, 0);
}

typedef IntRange = (int start, int end);

List<ConsideredOrientation> plan() {
  final random = OrientationRandom();
  final splits = List<ConsideredOrientation>.filled(
    orientationSplit * orientationsChecked,
    ConsideredOrientation(),
  );
  bool rep = false;
  final zero = IntPoint.zero();
  final maxMin = maxOrientationRadius / minOrientationRadius;
  for (int y = 0; y < orientationSplit; y++) {
    for (int x = 0; x < orientationsChecked; x++) {
      final sample = ConsideredOrientation();
      do {
        final angle = random.next * pi;
        final distance = math.pow(maxMin, random.next) * minOrientationRadius;
        sample.offset = double_angle.toVector(angle).multiply(distance).round();
        for (int i = 0; i < x; i++) {
          rep = splits[y * orientationsChecked + i].offset == sample.offset;
          if (rep) break;
        }
      } while (rep || sample.offset == zero || sample.offset.y < 0);
      final angle = double_angle.atan(sample.offset.toDouble());
      sample.orientation = double_angle.toVector(
        double_angle.add(angle < pi ? 2 * angle : 2 * (angle - pi), pi),
      );
      splits[y * orientationsChecked + x] = sample;
    }
  }
  return splits;
}

IntRange maskRange2(BooleanMatrix mask, int y) {
  int first = -1;
  int last = -1;
  final width = mask.width;
  for (int x = 0; x < width; x++) {
    if (mask.get(x, y)) {
      last = x;
      if (first < 0) first = x;
    }
  }
  return (first >= 0) ? (first, last + 1) : (0, 0);
}

DoublePointMatrix compute(
  DoubleMatrix input,
  BooleanMatrix mask,
  BlockMap blocks,
) {
  final neighbors = plan();
  final orientation = DoublePointMatrix(
    width: input.width,
    height: input.height,
  );
  final primary = blocks.primary;
  final blocksY = primary.blocks.y; // Cache
  for (int blockY = 0; blockY < blocksY; blockY++) {
    final (start, end) = maskRange2(mask, blockY);
    if (end - start > 0) {
      final (vStart, vEnd) = (
        primary.block(start, blockY).left,
        primary.block(end - 1, blockY).right,
      );
      final blockTop = blocks.primary.block(0, blockY).top;
      final blockBottom = primary.block(0, blockY).bottom; // Cache
      for (int y = blockTop; y < blockBottom; y++) {
        final start = (y % orientationSplit) * orientationsChecked;
        final end = start + orientationsChecked;
        for (int i = start; i < end; i++) {
          final neighbor = neighbors[i];
          final offsetX = neighbor.offset.x;
          final offsetY = neighbor.offset.y;
          final radius = math.max(offsetX.abs(), offsetY.abs());
          if (y - radius >= 0 && y + radius < input.height) {
            final (xStart, xEnd) = (
              math.max(radius, vStart),
              math.min(input.width - radius, vEnd),
            );
            for (int x = xStart; x < xEnd; x++) {
              final before = input.get(x - offsetX, y - offsetY);
              final at = input.get(x, y);
              final after = input.get(x + offsetX, y + offsetY);
              final strength = at - math.max(before, after);
              if (strength > 0) {
                orientation.add(x, y, neighbor.orientation.multiply(strength));
              }
            }
          }
        }
      }
    }
  }
  return orientation;
}
