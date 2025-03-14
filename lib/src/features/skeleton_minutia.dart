import 'package:dartafis/src/features/skeleton_ridge.dart';
import 'package:dartafis/src/primitives/int_point.dart';

class SkeletonMinutia {
  final IntPoint position;
  final ridges = <SkeletonRidge>[];

  SkeletonMinutia(this.position);

  void attachStart(SkeletonRidge ridge) {
    if (ridges.contains(ridge) == false) {
      ridges.add(ridge);
      ridge.setStart(this);
    }
  }

  void detachStart(SkeletonRidge ridge) {
    if (ridges.contains(ridge)) {
      ridges.remove(ridge);
      if (ridge.start == this) {
        ridge.setStart(null);
      }
    }
  }

  @override
  String toString() {
    return '$position*${ridges.length}';
  }
}
