import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/extractor/contrast.dart';
import 'package:dartafis/src/extractor/vote_filter.dart';
import 'package:dartafis/src/primitives/block_map.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/histogram_cube.dart';

BooleanMatrix filter(BooleanMatrix input) => voteFilter(
  input,
  null,
  blockErrorsVoteRadius,
  blockErrorsVoteMajority,
  blockErrorsVoteBorderDistance,
);

BooleanMatrix segmentationMask(BlockMap blocks, HistogramCube histogram) {
  final contrast = getClippedContrast(blocks, histogram);
  final mask = getAbsoluteContrastMask(contrast);
  mask.merge(getRelativeContrastMask(contrast, blocks));
  mask.merge(filter(mask));
  mask.invert();
  mask.merge(filter(mask));
  mask.merge(filter(mask));
  mask.merge(
    voteFilter(
      mask,
      null,
      maskVoteRadius,
      maskVoteMajority,
      maskVoteBorderDistance,
    ),
  );
  return mask;
}

@pragma('vm:align-loops')
BooleanMatrix pixelwise(BooleanMatrix mask, BlockMap blocks) {
  final primary = blocks.primary;
  final width = primary.blocks.x;
  final height = primary.blocks.y;
  final pixelized = BooleanMatrix(width: blocks.width, height: blocks.height);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      if (mask.get(xi, yi)) {
        final pixel = primary.block(xi, yi);
        final width = pixel.width;
        final height = pixel.height;
        final x = pixel.x;
        final y = pixel.y;
        for (var yi = 0; yi < height; yi++) {
          for (var xi = 0; xi < width; xi++) {
            pixelized.set(xi + x, yi + y, true);
          }
        }
      }
    }
  }
  return pixelized;
}

@pragma('vm:align-loops')
BooleanMatrix shrink(BooleanMatrix mask, int amount) {
  final width = mask.width;
  final height = mask.height;
  final shrunk = BooleanMatrix(width: width, height: height);
  final xi = width - amount;
  final yi = height - amount;
  for (var y = amount; y < yi; y++) {
    for (var x = amount; x < xi; x++) {
      shrunk.set(
        x,
        y,
        mask.get(x, y - amount) &&
            mask.get(x, y + amount) &&
            mask.get(x - amount, y) &&
            mask.get(x + amount, y),
      );
    }
  }
  return shrunk;
}

@pragma('vm:align-loops')
BooleanMatrix inner(BooleanMatrix outer) {
  final width = outer.width;
  final height = outer.height;
  var inner = BooleanMatrix(width: width, height: height);
  for (int y = 1; y < height - 1; ++y) {
    for (int x = 1; x < width - 1; ++x) {
      inner.set(x, y, outer.get(x, y));
    }
  }
  if (innerMaskBorderDistance >= 1) inner = shrink(inner, 1);
  int total = 1;
  for (int step = 1; total + step <= innerMaskBorderDistance; step *= 2) {
    inner = shrink(inner, step);
    total += step;
  }
  if (total < innerMaskBorderDistance) {
    inner = shrink(inner, innerMaskBorderDistance - total);
  }
  return inner;
}
