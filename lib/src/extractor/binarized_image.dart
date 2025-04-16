import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/extractor/vote_filter.dart';
import 'package:dartafis/src/primitives/block_map.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/double_matrix.dart';

@pragma('vm:align-loops')
BooleanMatrix binarize(
  DoubleMatrix input,
  DoubleMatrix baseline,
  BooleanMatrix mask,
  BlockMap blocks,
) {
  final primary = blocks.primary;
  final width = primary.blocks.x;
  final height = primary.blocks.y;
  final binarized = BooleanMatrix(width: input.width, height: input.height);
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      if (mask.get(xi, yi)) {
        final rect = primary.block(xi, yi);
        final top = rect.top;
        final bottom = rect.bottom;
        final left = rect.left;
        final right = rect.right;
        for (int y = top; y < bottom; ++y) {
          for (int x = left; x < right; ++x) {
            if (input.get(x, y) - baseline.get(x, y) > 0) {
              binarized.set(x, y, true);
            }
          }
        }
      }
    }
  }
  return binarized;
}

@pragma('vm:align-loops')
void cleanup(BooleanMatrix binary, BooleanMatrix mask) {
  final width = binary.width;
  final height = binary.height;
  final inverted = BooleanMatrix(
    width: width,
    height: height,
    cells: binary.cells.toList(),
  );
  inverted.invert();
  final islands = voteFilter(
    inverted,
    mask,
    binarizedVoteRadius,
    binarizedVoteMajority,
    binarizedVoteBorderDistance,
  );
  final holes = voteFilter(
    binary,
    mask,
    binarizedVoteRadius,
    binarizedVoteMajority,
    binarizedVoteBorderDistance,
  );
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      binary.set(
        x,
        y,
        binary.get(x, y) && islands.get(x, y) == false || holes.get(x, y),
      );
    }
  }
  removeCrosses(binary);
}

@pragma('vm:align-loops')
void removeCrosses(BooleanMatrix input) {
  final width = input.width;
  final height = input.height;
  bool any = true;
  while (any) {
    any = false;
    for (var y = 0; y < height - 1; y++) {
      for (var x = 0; x < width - 1; x++) {
        if (input.get(x, y) &&
                input.get(x + 1, y + 1) &&
                input.get(x, y + 1) == false &&
                input.get(x + 1, y) == false ||
            input.get(x, y + 1) &&
                input.get(x + 1, y) &&
                input.get(x, y) == false &&
                input.get(x + 1, y + 1) == false) {
          input.set(x, y, false);
          input.set(x, y + 1, false);
          input.set(x + 1, y, false);
          input.set(x + 1, y + 1, false);
          any = true;
        }
      }
    }
  }
}

@pragma('vm:align-loops')
BooleanMatrix invert(BooleanMatrix binary, BooleanMatrix mask) {
  final width = binary.width;
  final height = binary.height;
  final inverted = BooleanMatrix(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      inverted.set(x, y, binary.get(x, y) == false && mask.get(x, y));
    }
  }
  return inverted;
}
