import '../primitives/int_point.dart';

enum MinutiaType { ending, bifurcation }

typedef FeatureMinutia = ({
  IntPoint position,
  double direction,
  MinutiaType type,
});

final class SearchMinutia {
  final int x;
  final int y;
  final double direction;
  final MinutiaType type;

  SearchMinutia(FeatureMinutia feature)
      : x = feature.position.x,
        y = feature.position.y,
        direction = feature.direction,
        type = feature.type;
}
