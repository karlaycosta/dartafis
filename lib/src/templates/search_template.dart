import '../configuration/parameters.dart';
import '../features/indexed_edge.dart';
import '../features/neighbor_edge.dart';

typedef Probe = ({SearchTemplate template, Map<int, List<IndexedEdge>> hash});

typedef FeatureTemplate = ({IntPoint size, List<FeatureMinutia> minutiae});

final class SearchTemplate {
  final int width;
  final int height;
  final List<FeatureMinutia> minutiae;
  final List<List<NeighborEdge>> edges;

  const SearchTemplate._(this.width, this.height, this.minutiae, this.edges);

  factory SearchTemplate(FeatureTemplate features) {
    final List<FeatureMinutia> minutiae = features.minutiae;
    final Map<FeatureMinutia, int> keys = {
      for (final m in minutiae) m: ((m.x * 1610612741) + m.y) * 1610612741
    };

    minutiae.sort((a, b) {
      final keyA = keys[a]!;
      final keyB = keys[b]!;

      int result = keyA.compareTo(keyB);
      if (result != 0) return result;

      result = a.x.compareTo(b.x);
      if (result != 0) return result;

      result = a.y.compareTo(b.y);
      if (result != 0) return result;

      result = a.direction.compareTo(b.direction);
      if (result != 0) return result;

      return a.type.index.compareTo(b.type.index);
    });
    final List<List<NeighborEdge>> edges = buildTable(minutiae);
    return SearchTemplate._(features.size.x, features.size.y, minutiae, edges);
  }
}
