import 'package:dartafis/src/features/skeleton_minutia.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';
import 'package:dartafis/src/primitives/int_point.dart';

enum SkeletonType {
  ridges('ridges-'),
  valleys('valleys-');

  final String prefix;
  const SkeletonType(this.prefix);
}

class Skeleton {
  final SkeletonType type;
  final IntPoint size;
  final List<SkeletonMinutia> minutiae = [];

  Skeleton(this.type, this.size);

  BooleanMatrix shadow() {
    final shadow = BooleanMatrix(width: size.x, height: size.y);
    final length = minutiae.length;
    for (var i = 0; i < length; i++) {
      final minutia = minutiae[i];
      final position = minutia.position;
      shadow.set(position.x, position.y, true);
      final ridges = minutia.ridges;
      final ridgesLength = ridges.length;
      for (var j = 0; j < ridgesLength; j++) {
        final ridge = ridges[j];
        if (ridge.start!.position.y <= ridge.end!.position.y) {
          final points = ridge.points;
          final pointsLength = points.length;
          for (var k = 0; k < pointsLength; k++) {
            final point = points[k];
            shadow.set(point.x, point.y, true);
          }
        }
      }
    }
    return shadow;
  }
}
