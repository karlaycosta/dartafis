import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/skeleton.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/int_point.dart';

enum NeighborhoodType {
  skeleton,
  ending,
  removable;

  @override
  String toString() => name;
}

int bitCount(int i) {
  // HD, Figure 5-2
  i = i - ((i >>> 1) & 0x55555555);
  i = (i & 0x33333333) + ((i >>> 2) & 0x33333333);
  i = (i + (i >>> 4)) & 0x0f0f0f0f;
  i = i + (i >>> 8);
  i = i + (i >>> 16);
  return i & 0x3f;
}

// // Described in Hacker's Delight (Figure 5-2).
// int bitCount64(int n) {
//   n = n - ((n >> 1) & 0x5555555555555555);
//   n = (n & 0x3333333333333333) + ((n >> 2) & 0x3333333333333333);
//   n = (n + (n >> 4)) & 0x0f0f0f0f0f0f0f0f;
//   n = n + (n >> 8);
//   n = n + (n >> 16);
//   n = n + (n >> 32);
//   return n & 0x7f;
// }

List<NeighborhoodType> neighborhoodTypes() {
  final types = List<NeighborhoodType>.filled(256, NeighborhoodType.ending);
  for (var mask = 0; mask < 256; mask++) {
    final tl = (mask & 1) != 0;
    final tc = (mask & 2) != 0;
    final tr = (mask & 4) != 0;
    final cl = (mask & 8) != 0;
    final cr = (mask & 16) != 0;
    final bl = (mask & 32) != 0;
    final bc = (mask & 64) != 0;
    final br = (mask & 128) != 0;
    final count = bitCount(mask);
    final diagonal = !tc && !cl && tl ||
        !cl && !bc && bl ||
        !bc && !cr && br ||
        !cr && !tc && tr;
    final horizontal = !tc && !bc && (tr || cr || br) && (tl || cl || bl);
    final vertical = !cl && !cr && (tl || tc || tr) && (bl || bc || br);
    final end = count == 1;
    if (end) {
      types[mask] = NeighborhoodType.ending;
    } else if (!diagonal && !horizontal && !vertical) {
      types[mask] = NeighborhoodType.removable;
    } else {
      types[mask] = NeighborhoodType.skeleton;
    }
  }
  return types;
}

bool isFalseEnding(BooleanMatrix binary, IntPoint ending) {
  for (final relativeNeighbor in IntPoint.cornerNeighbors) {
    final neighbor = ending.plus(relativeNeighbor);
    if (binary.get(neighbor.x, neighbor.y)) {
      var count = 0;
      for (final relative2 in IntPoint.cornerNeighbors) {
        final plus = neighbor.plus(relative2);
        if (binary.getF(plus.x, plus.y, false)) ++count;
      }
      return count > 2;
    }
  }
  return false;
}

BooleanMatrix thin(BooleanMatrix input, SkeletonType type) {
  final neighborhoodTypes_ = neighborhoodTypes();
  final width = input.width;
  final height = input.height;
  final partial = BooleanMatrix(width: width, height: height);
  final widthX = width - 1;
  final heightY = height - 1;
  for (var y = 1; y < heightY; y++) {
    for (var x = 1; x < widthX; x++) {
      partial.set(x, y, input.get(x, y));
    }
  }

  final thinned = BooleanMatrix(width: width, height: height);
  var removedAnything = true;
  for (var i = 0; i < thinningIterations && removedAnything; i++) {
    removedAnything = false;
    for (var evenY = 0; evenY < 2; evenY++) {
      for (var evenX = 0; evenX < 2; evenX++) {
        for (var y = 1 + evenY; y < heightY; y += 2) {
          for (var x = 1 + evenX; x < widthX; x += 2) {
            if (partial.get(x, y) &&
                !thinned.get(x, y) &&
                !(partial.get(x, y - 1) &&
                    partial.get(x, y + 1) &&
                    partial.get(x - 1, y) &&
                    partial.get(x + 1, y))) {
              final neighbors = (partial.get(x + 1, y + 1) ? 128 : 0) |
                  (partial.get(x, y + 1) ? 64 : 0) |
                  (partial.get(x - 1, y + 1) ? 32 : 0) |
                  (partial.get(x + 1, y) ? 16 : 0) |
                  (partial.get(x - 1, y) ? 8 : 0) |
                  (partial.get(x + 1, y - 1) ? 4 : 0) |
                  (partial.get(x, y - 1) ? 2 : 0) |
                  (partial.get(x - 1, y - 1) ? 1 : 0);
              if (neighborhoodTypes_[neighbors] == NeighborhoodType.removable ||
                  neighborhoodTypes_[neighbors] == NeighborhoodType.ending &&
                      isFalseEnding(partial, IntPoint(x, y))) {
                removedAnything = true;
                partial.set(x, y, false);
              } else {
                thinned.set(x, y, true);
              }
            }
          }
        }
      }
    }
  }
  return thinned;
}
