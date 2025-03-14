import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/skeleton_minutia.dart';
import 'package:dartafis/src/primitives/double_angle.dart';
import 'package:dartafis/src/primitives/int_point.dart';
import 'package:dartafis/src/primitives/reversed_list.dart';



final class SkeletonRidge {
  late final List<IntPoint> points;
  late final SkeletonRidge reversed;
  SkeletonMinutia? start;
  SkeletonMinutia? end;

  // SkeletonRidge(this.start, this.end, this.points);
  SkeletonRidge() {
    points = [];
    reversed = SkeletonRidge.reverse(this);
  }

  SkeletonRidge.reverse(this.reversed)
      : start = reversed.end,
        end = reversed.start,
        points = ReversedList(reversed.points);

  void setStart(SkeletonMinutia? value) {
    if (start != value) {
      if (start != null) {
        final detachFrom = start!;
        start = null;
        detachFrom.detachStart(this);
      }
      start = value;
      if (start != null) {
        start?.attachStart(this);
      }
      reversed.end = value;
    }
  }

  void setEnd(SkeletonMinutia? value) {
    if (end != value) {
      end = value;
      reversed.setStart(value);
    }
  }

  void detach() {
    setStart(null);
    setEnd(null);
  }

  double direction() {
    var first = ridgeDirectionSkip;
    var last = ridgeDirectionSkip + ridgeDirectionSample - 1;
    if (last >= points.length) {
      final shift = last - points.length + 1;
      last -= shift;
      first -= shift;
    }
    if (first < 0) {
      first = 0;
    }
    return atanDouble(points[first], points[last]);
  }
}
