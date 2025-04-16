import 'dart:typed_data';
import 'dart:math' as math;

import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/primitives/block_map.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/double_matrix.dart';
import 'package:dartafis/src/primitives/histogram_cube.dart';

@pragma('vm:align-loops')
DoubleMatrix equalize(
  BlockMap blocks,
  DoubleMatrix image,
  HistogramCube histogram,
  BooleanMatrix blockMask,
) {
  const rgMin = -1.0;
  const rgMax = 1.0;
  const rgSize = rgMax - rgMin;
  const widMax = rgSize / 256 * maxEqualizationScaling;
  const widMin = rgSize / 256 * minEqualizationScaling;
  final bins = histogram.bins;
  final limMin = Float64List(bins);
  final limMax = Float64List(bins);
  final dequantized = Float64List(bins);

  for (int i = 0; i < bins; i++) {
    final def = bins - 1 - i;
    limMin[i] = math.max(i * widMin + rgMin, rgMax - def * widMax);
    limMax[i] = math.min(i * widMax + rgMin, rgMax - def * widMin);
    dequantized[i] = i / (bins - 1);
  }

  final mappings = <(int x, int y), Float64List>{};
  final width = blocks.secondary.blocks.x;
  final height = blocks.secondary.blocks.y;

  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      final mapping = Float64List(bins);
      mappings[(xi, yi)] = mapping;

      if (blockMask.getF(xi, yi, false) ||
          blockMask.getF(xi - 1, yi, false) ||
          blockMask.getF(xi, yi - 1, false) ||
          blockMask.getF(xi - 1, yi - 1, false)) {
        final step = rgSize / histogram.sum(xi, yi);
        double top = rgMin;

        for (int i = 0; i < bins; i++) {
          final band = histogram.get(xi, yi, i) * step;
          double equalized = top + dequantized[i] * band;
          top += band;

          if (equalized < limMin[i]) equalized = limMin[i];

          if (equalized > limMax[i]) equalized = limMax[i];

          mapping[i] = equalized;
        }
      }
    }
  }

  final result = DoubleMatrix(width: blocks.width, height: blocks.height);
  final pWidth = blocks.primary.blocks.x;
  final pHeight = blocks.primary.blocks.y;

  for (var yi = 0; yi < pHeight; yi++) {
    for (var xi = 0; xi < pWidth; xi++) {
      final area = blocks.primary.block(xi, yi);
      final top = area.top;
      final bottom = area.bottom;
      final left = area.left;
      final right = area.right;

      if (blockMask.get(xi, yi)) {
        final topL = mappings[(xi, yi)]!;
        final topR = mappings[(xi + 1, yi)]!;
        final botL = mappings[(xi, yi + 1)]!;
        final botR = mappings[(xi + 1, yi + 1)]!;
        final ax = area.x;
        final ay = area.y;
        final aw = area.width;
        final ah = area.height;

        for (int y = top; y < bottom; y++) {
          for (int x = left; x < right; x++) {
            final depth = histogram.constrain((image.get(x, y) * bins).toInt());
            final rx = (x - ax + 0.5) / aw;
            final ry = (y - ay + 0.5) / ah;
            result.set(
              x,
              y,
              interpolate(
                botL[depth],
                botR[depth],
                topL[depth],
                topR[depth],
                rx,
                ry,
              ),
            );
          }
        }
      } else {
        for (int y = top; y < bottom; y++) {
          for (int x = left; x < right; x++) {
            result.set(x, y, -1);
          }
        }
      }
    }
  }
  return result;
}

double interpolate(
  double bottomleft,
  double bottomright,
  double topleft,
  double topright,
  double x,
  double y,
) {
  final left = topleft + y * (bottomleft - topleft);
  final right = topright + y * (bottomright - topright);
  return left + x * (right - left);
}
