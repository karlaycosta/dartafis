import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/skeleton.dart';

void _collect(
  List<FeatureMinutia> minutiae,
  Skeleton skeleton,
  MinutiaType type,
) {
  final minutiaes = skeleton.minutiae;
  final minutiaesLength = minutiaes.length;
  for (var i = 0; i < minutiaesLength; i++) {
    final sminutia = minutiaes[i];
    if (sminutia.ridges.length == 1) {
      final position = sminutia.position;
      minutiae.add((
        x: position.x,
        y: position.y,
        direction: sminutia.ridges[0].direction(),
        type: type,
      ));
    }
  }
}

List<FeatureMinutia> collect(Skeleton ridges, Skeleton valleys) {
  final minutiae = <FeatureMinutia>[];
  _collect(minutiae, ridges, MinutiaType.ending);
  _collect(minutiae, valleys, MinutiaType.bifurcation);
  return minutiae;
}
