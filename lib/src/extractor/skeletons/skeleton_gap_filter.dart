import 'package:collection/collection.dart';
import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/extractor/skeletons/skeleton_filters.dart';
import 'package:dartafis/src/extractor/skeletons/skeleton_gap.dart';
import 'package:dartafis/src/features/skeleton.dart';
import 'package:dartafis/src/features/skeleton_minutia.dart';
import 'package:dartafis/src/features/skeleton_ridge.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/double_angle.dart';
import 'package:dartafis/src/primitives/int_point.dart';

void addGapRidge(BooleanMatrix shadow, SkeletonGap gap, List<IntPoint> line) {
  final ridge = SkeletonRidge();
  final length = line.length;
  for (var i = 0; i < length; i++) {
    ridge.points.add(line[i]);
  }
  ridge.setStart(gap.end1);
  ridge.setEnd(gap.end2);
  // final ridge = SkeletonRidge(start: gap.end1, end: gap.end2, points: line);
  for (var i = 0; i < length; i++) {
    final point = line[i];
    shadow.set(point.x, point.y, true);
  }
}

IntPoint angleSampleForGapRemoval(SkeletonMinutia minutia) {
  final ridge = minutia.ridges[0];
  return gapAngleOffset < ridge.points.length
      ? ridge.points[gapAngleOffset]
      : ridge.end!.position;
}

double distance(double first, double second) {
  final delta = (first - second).abs();
  return delta <= pi ? delta : pi2 - delta;
}

double opposite(double angle) => angle < pi ? angle + pi : angle - pi;

bool isWithinGapLimits(SkeletonMinutia end1, SkeletonMinutia end2) {
  final distanceSq = end1.position.minus(end2.position).lengthSq();
  if (distanceSq <= sq(maxRuptureSize)) {
    return true;
  }
  if (distanceSq > sq(maxGapSize)) {
    return false;
  }
  final gapDirection = atanDouble(end1.position, end2.position);
  final direction1 = atanDouble(end1.position, angleSampleForGapRemoval(end1));
  if (distance(direction1, opposite(gapDirection)) > maxGapAngle) {
    return false;
  }
  final direction2 = atanDouble(end2.position, angleSampleForGapRemoval(end2));
  if (distance(direction2, gapDirection) > maxGapAngle) {
    return false;
  }
  return true;
}

bool isRidgeOverlapping(List<IntPoint> line, BooleanMatrix shadow) {
  final length = line.length;
  for (var i = toleratedGapOverlap; i < length - toleratedGapOverlap; i++) {
    final point = line[i];
    if (shadow.get(point.x, point.y)) {
      return true;
    }
  }
  return false;
}

void skeletonGapFilter(Skeleton skeleton) {
  final queue = PriorityQueue<SkeletonGap>();
  final minutiaes = skeleton.minutiae;
  final length = minutiaes.length;
  for (var i = 0; i < length; i++) {
    final end1 = minutiaes[i];
    if (end1.ridges.length == 1 &&
        end1.ridges[0].points.length >= shortestJoinedEnding) {
      for (var j = 0; j < length; j++) {
        final end2 = minutiaes[j];
        if (end2 != end1 &&
            end2.ridges.length == 1 &&
            end1.ridges[0].end != end2 &&
            end2.ridges[0].points.length >= shortestJoinedEnding &&
            isWithinGapLimits(end1, end2)) {
          final gap = SkeletonGap(
            distance: end1.position.minus(end2.position).lengthSq(),
            end1: end1,
            end2: end2,
          );
          queue.add(gap);
        }
      }
    }
  }
  final shadow = skeleton.shadow();
  while (queue.isNotEmpty) {
    final gap = queue.removeFirst();
    if (gap.end1.ridges.length == 1 && gap.end2.ridges.length == 1) {
      final line = gap.end1.position.lineTo(gap.end2.position);
      if (isRidgeOverlapping(line, shadow) == false) {
        addGapRidge(shadow, gap, line);
      }
    }
  }
  skeletonKnotFilter(skeleton);
}
