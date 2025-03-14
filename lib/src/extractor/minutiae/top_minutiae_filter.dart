import 'package:dartafis/src/configuration/parameters.dart';

List<FeatureMinutia> topMinutiaeFilter(List<FeatureMinutia> minutiae) {
  if (minutiae.length <= maxMinutiae) return minutiae;

  final sortedMinutiae = minutiae.map((minutia) {
    final distances = minutiae
        .map((neighbor) =>
            sq(minutia.x - neighbor.x) + sq(minutia.y - neighbor.y))
        .toList()
      ..sort();
    final distance = distances.length > sortByNeighbor
        ? distances[sortByNeighbor]
        : double.maxFinite;
    return MapEntry(minutia, distance);
  }).toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sortedMinutiae.take(maxMinutiae).map((entry) => entry.key).toList();
}
