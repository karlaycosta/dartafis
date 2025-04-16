import 'dart:typed_data';
import 'dart:math' as math;
import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/primitives/block_map.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/double_matrix.dart';
import 'package:dartafis/src/primitives/histogram_cube.dart';

@pragma('vm:align-loops')
DoubleMatrix getClippedContrast(BlockMap blocks, HistogramCube histogram) {
  final width = blocks.primary.blocks.x;
  final height = blocks.primary.blocks.y;
  final bins = histogram.bins;
  final result = DoubleMatrix(width: width, height: height);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      final volume = histogram.sum(xi, yi);
      final clipLimit = (volume * clippedContrast).round();
      int accumulator = 0;
      int lowerBound = bins - 1;
      for (int i = 0; i < bins; i++) {
        accumulator += histogram.get(xi, yi, i);
        if (accumulator > clipLimit) {
          lowerBound = i;
          break;
        }
      }
      accumulator = 0;
      int upperBound = 0;
      for (int i = bins - 1; i >= 0; i--) {
        accumulator += histogram.get(xi, yi, i);
        if (accumulator > clipLimit) {
          upperBound = i;
          break;
        }
      }
      result.set(xi, yi, (upperBound - lowerBound) * (1 / (bins - 1)));
    }
  }
  return result;
}

@pragma('vm:align-loops')
BooleanMatrix getAbsoluteContrastMask(DoubleMatrix contrast) {
  final width = contrast.width;
  final height = contrast.height;
  final result = BooleanMatrix(width: width, height: height);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      if (contrast.get(xi, yi) < minAbsoluteContrast) {
        result.set(xi, yi, true);
      }
    }
  }
  return result;
}

@pragma('vm:align-loops')
BooleanMatrix getRelativeContrastMask(DoubleMatrix contrast, BlockMap blocks) {
  final cwidth = contrast.width;
  final cheight = contrast.height;
  final sortedContrast = Float64List(cwidth * cheight);
  for (var yi = 0; yi < cheight; yi++) {
    for (var xi = 0; xi < cwidth; xi++) {
      sortedContrast[xi * cheight + yi] = contrast.get(xi, yi);
    }
  }
  sortedContrast.sort((a, b) => b.compareTo(a));
  final pixelsPerBlock = blocks.area ~/ blocks.primary.blocks.getArea();
  final sampleCount = math.min(
    sortedContrast.length,
    relativeContrastSample ~/ pixelsPerBlock,
  );
  final consideredBlocks = math.max(
    (sampleCount * relativeContrastPercentile).round(),
    1,
  );
  final averageContrast =
      sortedContrast.take(consideredBlocks).reduce((a, b) => a + b) /
      consideredBlocks;
  final limit = averageContrast * minRelativeContrast;
  final width = blocks.primary.blocks.x;
  final height = blocks.primary.blocks.y;
  final result = BooleanMatrix(width: width, height: height);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      if (contrast.get(xi, yi) < limit) {
        result.set(xi, yi, true);
      }
    }
  }
  return result;
}
