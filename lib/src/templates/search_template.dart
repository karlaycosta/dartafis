import '../features/indexed_edge.dart';
import '../features/neighbor_edge.dart';
import '../features/search_minutia.dart';
import '../primitives/int_point.dart';

typedef Probe = ({SearchTemplate template, Map<int, List<IndexedEdge>> hash});

typedef FeatureTemplate = ({IntPoint size, List<FeatureMinutia> minutiae});

final class SearchTemplate {
  final int width;
  final int height;
  final List<SearchMinutia> minutiae;
  final List<List<NeighborEdge>> edges;

  static const int _prime = 1610612741;

  const SearchTemplate._(this.width, this.height, this.minutiae, this.edges);

  factory SearchTemplate(FeatureTemplate features) {
    final minutiae = features.minutiae.map(SearchMinutia.new).toList();
    minutiae.sort((a, b) {
      final keyA = ((a.x * _prime) + a.y) * _prime;
      final keyB = ((b.x * _prime) + b.y) * _prime;

      int result = keyA.compareTo(keyB);
      if (result != 0) return result;

      result = a.x.compareTo(b.x);
      if (result != 0) return result;

      result = a.y.compareTo(b.y);
      if (result != 0) return result;

      result = a.direction.compareTo(b.direction);
      if (result != 0) return result;

      return '${a.type}'.compareTo('${b.type}');
    });
    final edges = NeighborEdge.buildTable(minutiae);
    return SearchTemplate._(features.size.x, features.size.y, minutiae, edges);
  }
}
