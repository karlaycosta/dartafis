import '../primitives/integers.dart';
import '../configuration/parameters.dart';
import 'edge_shape.dart';
import 'search_minutia.dart';

final class NeighborEdge extends EdgeShape {
  final int neighbor;
  NeighborEdge(List<SearchMinutia> minutiae, int reference, this.neighbor)
      : super(minutiae[reference], minutiae[neighbor]);

  static List<List<NeighborEdge>> buildTable(List<SearchMinutia> minutiae) {
    final edges = List<List<NeighborEdge>>.filled(minutiae.length, []);
    final star = <NeighborEdge>[];
    final allSqDistances = List.filled(minutiae.length, 0);
    for (int reference = 0; reference < edges.length; ++reference) {
      final rminutia = minutiae[reference];
      // 32-bit = 0x7fffffff e 64-bit = 0x7fffffffffffffff
      int maxSqDistance = 0x7fffffffffffffff; //Integer.MAX_VALUE ;
      if (minutiae.length - 1 > edgeTableNeighbors) {
        for (int neighbor = 0; neighbor < minutiae.length; ++neighbor) {
          final nminutia = minutiae[neighbor];
          allSqDistances[neighbor] = Integers.sq(rminutia.x - nminutia.x) +
              Integers.sq(rminutia.y - nminutia.y);
        }
        allSqDistances.sort();
        maxSqDistance = allSqDistances[edgeTableNeighbors];
      }
      for (int neighbor = 0; neighbor < minutiae.length; ++neighbor) {
        final nminutia = minutiae[neighbor];
        if (neighbor != reference &&
            Integers.sq(rminutia.x - nminutia.x) +
                    Integers.sq(rminutia.y - nminutia.y) <=
                maxSqDistance) {
          star.add(NeighborEdge(minutiae, reference, neighbor));
        }
      }
      star.sort((a, b) {
        final lengthCmp = a.length.compareTo(b.length);
        if (lengthCmp != 0) return lengthCmp;
        return a.neighbor.compareTo(b.neighbor);
      });
      while (star.length > edgeTableNeighbors) {
        star.removeAt(star.length - 1);
      }
      edges[reference] = star.toList();
      star.clear();
    }
    return edges;
  }
}