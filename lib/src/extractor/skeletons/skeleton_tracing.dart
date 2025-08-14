import 'dart:collection';

import 'package:dartafis/src/features/skeleton.dart';
import 'package:dartafis/src/features/skeleton_minutia.dart';
import 'package:dartafis/src/features/skeleton_ridge.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/int_point.dart';

List<IntPoint> findMinutiae(BooleanMatrix thinned) {
  final result = <IntPoint>[];
  final width = thinned.width;
  final height = thinned.height;
  final neighbors = IntPoint.cornerNeighbors;
  for (var yi = 0; yi < height; yi++) {
    for (var xi = 0; xi < width; xi++) {
      if (thinned.get(xi, yi)) {
        int count = 0;
        final length = neighbors.length;
        for (var i = 0; i < length; i++) {
          final relative = neighbors[i];
          if (thinned.getF(xi + relative.x, yi + relative.y, false)) {
            count++;
          }
        }
        if (count == 1 || count > 2) {
          result.add(IntPoint(xi, yi));
        }
      }
    }
  }
  return result;
}

HashMap<IntPoint, List<IntPoint>> linkNeighboringMinutiae(
  List<IntPoint> minutiae,
) {
  final HashMap<IntPoint, List<IntPoint>> linking = HashMap();
  final neighbors = IntPoint.cornerNeighbors;
  final length = neighbors.length;
  final minutiaes = minutiae.length;
  for (var i = 0; i < minutiaes; i++) {
    List<IntPoint>? ownLinks;
    final minutiaPos = minutiae[i];
    for (var i = 0; i < length; i++) {
      final neighborPos = minutiaPos.plus(neighbors[i]);
      final neighborLinks = linking[neighborPos];

      if (neighborLinks != null && neighborLinks != ownLinks) {
        if (ownLinks != null) {
          neighborLinks.addAll(ownLinks);
          final length = ownLinks.length;
          for (var j = 0; j < length; j++) {
            linking[ownLinks[j]] = neighborLinks;
          }
        }
        ownLinks = neighborLinks;
      }
    }
    ownLinks ??= [];
    ownLinks.add(minutiaPos);
    linking[minutiaPos] = ownLinks;
  }
  return linking;
}

HashMap<IntPoint, SkeletonMinutia> minutiaCenters(
  Skeleton skeleton,
  HashMap<IntPoint, List<IntPoint>> linking,
) {
  final HashMap<IntPoint, SkeletonMinutia> centers = HashMap();
  final sortedKeys = linking.keys.toList()..sort();
  final length = sortedKeys.length;
  for (var i = 0; i < length; i++) {
    final currentPos = sortedKeys[i];
    final linkedMinutiae = linking[currentPos]!;
    final primaryPos = linkedMinutiae.first;
    if (centers.containsKey(primaryPos) == false) {
      var x = 0;
      var y = 0;
      final length = linkedMinutiae.length;
      for (var i = 0; i < length; i++) {
        final linkedPos = linkedMinutiae[i];
        x += linkedPos.x;
        y += linkedPos.y;
      }
      final count = linkedMinutiae.length;
      final center = IntPoint(x ~/ count, y ~/ count);
      final minutia = SkeletonMinutia(center);
      skeleton.minutiae.add(minutia);
      centers[primaryPos] = minutia;
    }
    centers[currentPos] = centers[primaryPos]!;
  }
  return centers;
}

void traceRidges(
  BooleanMatrix thinned,
  HashMap<IntPoint, SkeletonMinutia> minutiaePoints,
) {
  // final Map<IntPoint, SkeletonRidge> leads = {};
  final leads = <IntPoint>[];
  final sortedMinutiaePoints = minutiaePoints.keys.toList()..sort();
  final points = sortedMinutiaePoints.length;
  final neighbors = IntPoint.cornerNeighbors;
  final length = neighbors.length;

  for (var i = 0; i < points; i++) {
    final minutiaPoint = sortedMinutiaePoints[i];
    for (var j = 0; j < length; j++) {
      final start = minutiaPoint.plus(neighbors[j]);
      if (thinned.getF(start.x, start.y, false) &&
          minutiaePoints.containsKey(start) == false &&
          leads.contains(start) == false) {
        final ridge = SkeletonRidge()
          ..points.add(minutiaPoint)
          ..points.add(start);
        // final ridges = <IntPoint>[minutiaPoint, start];
        var previous = minutiaPoint;
        var current = start;
        do {
          var next = IntPoint.zero();
          for (var j = 0; j < length; j++) {
            next = current.plus(neighbors[j]);
            if (thinned.getF(next.x, next.y, false) && next != previous) {
              break;
            }
          }
          previous = current;
          current = next;
          ridge.points.add(current);
          // ridges.add(current);
        } while (minutiaePoints.containsKey(current) == false);
        // final end = current;
        // final mStart = minutiaePoints[minutiaPoint];
        // final mEnd = minutiaePoints[current];
        // final startRidge = SkeletonRidge(mStart!, mEnd!, ridges);
        // final endRidge = SkeletonRidge(mEnd, mStart, ridges.reversed.toList());
        // mStart.ridges.add(startRidge);
        // mEnd.ridges.add(endRidge);
        ridge.setStart(minutiaePoints[minutiaPoint]);
        ridge.setEnd(minutiaePoints[current]);
        leads.addAll([start, previous]);
      }
    }
  }
}

void fixLinkingGaps(Skeleton skeleton) {
  final minutiae = skeleton.minutiae;
  final lengthM = minutiae.length;
  for (var i = 0; i < lengthM; i++) {
    final minutia = minutiae[i];
    final ridges = minutia.ridges;
    final lengthR = ridges.length;
    for (var j = 0; j < lengthR; j++) {
      final ridge = ridges[j];
      final first = ridge.points[0];
      if (first != minutia.position) {
        final filling = first.lineTo(minutia.position);
        final lengthP = filling.length;
        for (var ii = 1; ii < lengthP; ii++) {
          ridge.points.insert(0, filling[ii]);
        }
      }
    }
  }
}

Skeleton trace(BooleanMatrix thinned, SkeletonType type) {
  final skeleton = Skeleton(type, IntPoint(thinned.width, thinned.height));
  final minutiaPoints = findMinutiae(thinned);
  final linking = linkNeighboringMinutiae(minutiaPoints);
  final minutiaMap = minutiaCenters(skeleton, linking);
  traceRidges(thinned, minutiaMap);
  fixLinkingGaps(skeleton);
  return skeleton;
}
