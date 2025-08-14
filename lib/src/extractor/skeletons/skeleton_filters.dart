import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/extractor/skeletons/skeleton_gap_filter.dart';
import 'package:dartafis/src/features/skeleton.dart';
import 'package:dartafis/src/features/skeleton_minutia.dart';
import 'package:dartafis/src/features/skeleton_ridge.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/double_angle.dart' as double_angle;

void skeletonFilters(Skeleton skeleton) {
  skeletonDotFilter(skeleton);
  skeletonPoreFilter(skeleton);
  skeletonGapFilter(skeleton);
  skeletonTailFilter(skeleton);
  skeletonFragmentFilter(skeleton);
}

@pragma('vm:align-loops')
void skeletonDotFilter(Skeleton skeleton) {
  final removed = <SkeletonMinutia>[];
  final minutias = skeleton.minutiae;
  final length = minutias.length;
  for (var i = 0; i < length; i++) {
    final minutia = minutias[i];
    if (minutia.ridges.isEmpty) {
      removed.add(minutia);
    }
  }
  final removeds = removed.length;
  for (var i = 0; i < removeds; i++) {
    skeleton.minutiae.remove(removed[i]);
  }
}

@pragma('vm:align-loops')
void skeletonPoreFilter(Skeleton skeleton) {
  final minutias = skeleton.minutiae;
  final length = minutias.length;
  for (var i = 0; i < length; i++) {
    final minutia = minutias[i];
    if (minutia.ridges.length == 3) {
      for (var exit = 0; exit < 3; exit++) {
        final exitRidge = minutia.ridges[exit];
        final arm1 = minutia.ridges[(exit + 1) % 3];
        final arm2 = minutia.ridges[(exit + 2) % 3];
        if (arm1.end == arm2.end &&
            exitRidge.end != arm1.end &&
            arm1.end != minutia &&
            exitRidge.end != minutia) {
          final end = arm1.end;
          if (end != null &&
              end.ridges.length == 3 &&
              arm1.points.length <= maxPoreArm &&
              arm2.points.length <= maxPoreArm) {
            arm1.detach();
            arm2.detach();
            final merged = SkeletonRidge();
            merged.setStart(minutia);
            merged.setEnd(end);
            final lines = minutia.position.lineTo(end.position);
            final length = lines.length;
            for (var i = 1; i < length; i++) {
              merged.points.add(lines[i]);
            }
          }
          break;
        }
      }
    }
  }
  skeletonKnotFilter(skeleton);
}

@pragma('vm:align-loops')
void skeletonKnotFilter(Skeleton skeleton) {
  final minutiaes = skeleton.minutiae;
  final length = minutiaes.length;
  for (var i = 0; i < length; i++) {
    final minutia = minutiaes[i];
    if (minutia.ridges.length == 2 &&
        minutia.ridges[0].reversed != minutia.ridges[1]) {
      var extended = minutia.ridges[0].reversed;
      var removed = minutia.ridges[1];
      if (extended.points.length < removed.points.length) {
        final tmp = extended;
        extended = removed;
        removed = tmp;
        extended = extended.reversed;
        removed = removed.reversed;
      }
      extended.points.removeAt(extended.points.length - 1);
      final points = removed.points;
      final length = points.length;
      for (var i = 0; i < length; i++) {
        extended.points.add(points[i]);
      }
      extended.setEnd(removed.end);
      removed.detach();
    }
  }
  skeletonDotFilter(skeleton);
}

@pragma('vm:align-loops')
void skeletonTailFilter(Skeleton skeleton) {
  final minutaes = skeleton.minutiae;
  final length = minutaes.length;
  for (var i = 0; i < length; i++) {
    final minutia = minutaes[i];
    final ridge = minutia.ridges[0];
    if (minutia.ridges.length == 1 && ridge.end!.ridges.length >= 3) {
      if (ridge.points.length < minTailLength) {
        ridge.detach();
      }
    }
  }
  skeletonDotFilter(skeleton);
  skeletonKnotFilter(skeleton);
}

@pragma('vm:align-loops')
void skeletonFragmentFilter(Skeleton skeleton) {
  final minutaes = skeleton.minutiae;
  final minTailLength = minutaes.length;
  for (var i = 0; i < minTailLength; i++) {
    final minutia = minutaes[i];
    if (minutia.ridges.length == 1) {
      final ridge = minutia.ridges[0];
      if (ridge.end!.ridges.length == 1 &&
          ridge.points.length < minFragmentLength) {
        ridge.detach();
      }
    }
  }
  skeletonDotFilter(skeleton);
}

void innerMinutiaeFilter(List<FeatureMinutia> minutiae, BooleanMatrix mask) {
  // final length = minutiae.length;
  // for (var i = 0; i < length; i++) {
  //   final minutia = minutiae[i];
  //   final arrow = double_angle
  //       .toVector(minutia.direction)
  //       .multiply(-maskDisplacement)
  //       .round();
  // }
  minutiae.removeWhere((minutia) {
    final arrow = double_angle
        .toVector(minutia.direction)
        .multiply(-maskDisplacement)
        .round();
    return mask.getF(minutia.x + arrow.x, minutia.y + arrow.y, false) == false;
  });
}

void minutiaCloudFilter(List<FeatureMinutia> minutiae) {
  const radiusSq = minutiaCloudRadius * minutiaCloudRadius;

  minutiae.removeWhere((minutia) {
    final count = minutiae.where((neighbor) {
      final dx = neighbor.x - minutia.x;
      final dy = neighbor.y - minutia.y;
      return dx * dx + dy * dy <= radiusSq;
    }).length;

    return count - 1 > maxCloudSize;
  });
}
