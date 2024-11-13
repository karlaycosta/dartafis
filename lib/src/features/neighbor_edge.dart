import '../configuration/parameters.dart';
import 'edge_shape.dart';

final class NeighborEdge extends EdgeShape {
  final int neighbor;
  NeighborEdge(List<FeatureMinutia> minutiae, int reference, this.neighbor)
      : super(minutiae[reference], minutiae[neighbor]);
}

int sq(int value) => value * value;

List<List<NeighborEdge>> buildTable(List<FeatureMinutia> minutiae) {
  final edges = List<List<NeighborEdge>>.generate(
    minutiae.length,
    (_) => [],
    growable: false,
  );
  final allSqDistances = List<int>.generate(
    minutiae.length,
    (_) => 0,
    growable: false,
  );
  final star = <NeighborEdge>[];

  for (int reference = 0; reference < edges.length; ++reference) {
    final rminutia = minutiae[reference];
    int maxSqDistance = 0x7fffffffffffffff; //Integer.MAX_VALUE ;

    if (minutiae.length - 1 > edgeTableNeighbors) {
      for (int neighbor = 0; neighbor < minutiae.length; ++neighbor) {
        final nminutia = minutiae[neighbor];
        allSqDistances[neighbor] =
            sq(rminutia.x - nminutia.x) + sq(rminutia.y - nminutia.y);
      }
      allSqDistances.sort();
      maxSqDistance = allSqDistances[edgeTableNeighbors];
    }

    for (int neighbor = 0; neighbor < minutiae.length; ++neighbor) {
      if (neighbor != reference) {
        final nminutia = minutiae[neighbor];
        final sqDistance =
            sq(rminutia.x - nminutia.x) + sq(rminutia.y - nminutia.y);
        if (sqDistance <= maxSqDistance) {
          star.add(NeighborEdge(minutiae, reference, neighbor));
        }
      }
    }

    star.sort((a, b) {
      final lengthCmp = a.length.compareTo(b.length);
      if (lengthCmp != 0) return lengthCmp;
      return a.neighbor.compareTo(b.neighbor);
    });

    if (star.length > edgeTableNeighbors) {
      star.removeRange(edgeTableNeighbors, star.length);
    }

    edges[reference] = star.toList();
    star.clear();
  }

  return edges;
}
