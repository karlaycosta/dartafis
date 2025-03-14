import 'dart:math' as math;
import 'dart:typed_data';
import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/int_matrix.dart';
import 'package:dartafis/src/primitives/int_rect.dart';

@pragma('vm:align-loops')
BooleanMatrix voteFilter(
  BooleanMatrix input,
  BooleanMatrix? mask,
  int radius,
  double majority,
  int borderDistance,
) {
  final width = input.width;
  final height = input.height;
  final rect = IntRect(
    borderDistance,
    borderDistance,
    width - 2 * borderDistance,
    height - 2 * borderDistance,
  );
  final rTop = rect.top;
  final rBottom = rect.bottom;
  final rLeft = rect.left;
  final rRight = rect.right;
  final length = sq(2 * radius + 1) + 1;
  final thresholds = Uint32List(length);
  for (int i = 0; i < length; i++) {
    thresholds[i] = (majority * i).ceil();
  }
  final counts = IntMatrix(width: width, height: height);
  final output = BooleanMatrix(width: width, height: height);
  for (int y = rTop; y < rBottom; y++) {
    final superTop = y - radius - 1;
    final superBottom = y + radius;
    final yMin = math.max(0, y - radius);
    final yMax = math.min(height - 1, y + radius);
    final yRange = yMax - yMin + 1;
    for (int x = rLeft; x < rRight; x++) {
      if (mask == null || mask.get(x, y)) {
        final left = x > 0 ? counts.get(x - 1, y) : 0;
        final top = y > 0 ? counts.get(x, y - 1) : 0;
        final diagonal = x > 0 && y > 0 ? counts.get(x - 1, y - 1) : 0;
        final xMin = math.max(0, x - radius);
        final xMax = math.min(width - 1, x + radius);
        int ones;
        if (left > 0 && top > 0 && diagonal > 0) {
          ones = top + left - diagonal - 1;
          final superLeft = x - radius - 1;
          final superRight = x + radius;
          if (superLeft >= 0 &&
              superTop >= 0 &&
              input.get(superLeft, superTop)) {
            ones++;
          }
          if (superLeft >= 0 &&
              superBottom < height &&
              input.get(superLeft, superBottom)) {
            ones--;
          }
          if (superRight < width &&
              superTop >= 0 &&
              input.get(superRight, superTop)) {
            ones--;
          }
          if (superRight < width &&
              superBottom < height &&
              input.get(superRight, superBottom)) {
            ones++;
          }
        } else {
          ones = 0;
          for (int ny = yMin; ny <= yMax; ++ny) {
            for (int nx = xMin; nx <= xMax; ++nx) {
              if (input.get(nx, ny)) ones++;
            }
          }
        }
        counts.set(x, y, ones + 1);
        if (ones >= thresholds[yRange * (xMax - xMin + 1)]) {
          output.set(x, y, true);
        }
      }
    }
  }
  return output;
}
