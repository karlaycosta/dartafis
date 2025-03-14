import 'package:dartafis/src/features/skeleton_minutia.dart';

class SkeletonGap implements Comparable<SkeletonGap> {
  final int distance;
  final SkeletonMinutia end1;
  final SkeletonMinutia end2;

  SkeletonGap({required this.distance, required this.end1, required this.end2});
  
  @override
  int compareTo(SkeletonGap other) {
		final distanceCmp = distance.compareTo(other.distance);
		if (distanceCmp != 0) {
		  return distanceCmp;
		}
		final end1Cmp = end1.position.compareTo(other.end1.position);
		if (end1Cmp != 0) {
		  return end1Cmp;
		}
		return end2.position.compareTo(other.end2.position);
  }
}
