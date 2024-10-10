import 'edge_shape.dart';
import 'search_minutia.dart';

final class IndexedEdge extends EdgeShape {
  final int _reference;
  final int _neighbor;

  IndexedEdge(List<SearchMinutia> minutiae, this._reference, this._neighbor)
      : super(minutiae[_reference], minutiae[_neighbor]);

  int get reference => _reference.toUnsigned(8);

  int get neighbor => _neighbor.toUnsigned(8);
}
