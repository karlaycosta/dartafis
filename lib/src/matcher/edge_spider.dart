import 'package:collection/collection.dart';

import '../configuration/parameters.dart';
import '../features/neighbor_edge.dart';
import '../primitives/float_angle.dart';
import 'minutia_pair.dart';
import 'pairing_graph.dart';

final class EdgeSpider {
  static final double _complementaryMaxAngleError =
      FloatAngle.complementary(maxAngleError);

  static List<MinutiaPair> _matchPairs(
    List<NeighborEdge> pstar,
    List<NeighborEdge> cstar,
  ) {
    final results = <MinutiaPair>[];
    int start = 0;
    int end = 0;
    for (int cindex = 0; cindex < cstar.length; cindex++) {
      final cedge = cstar[cindex];
      while (start < pstar.length &&
          pstar[start].length < cedge.length - maxDistanceError) {
        start++;
      }
      if (end < start) {
        end = start;
      }
      while (end < pstar.length &&
          pstar[end].length <= cedge.length + maxDistanceError) {
        end++;
      }
      for (int pindex = start; pindex < end; pindex++) {
        final pedge = pstar[pindex];
        final rdiff =
            FloatAngle.difference(pedge.referenceAngle, cedge.referenceAngle);
        if (rdiff <= maxAngleError || rdiff >= _complementaryMaxAngleError) {
          final ndiff =
              FloatAngle.difference(pedge.neighborAngle, cedge.neighborAngle);
          if (ndiff <= maxAngleError || ndiff >= _complementaryMaxAngleError) {
            final pair = MinutiaPair();
            pair.probe = pedge.neighbor;
            pair.candidate = cedge.neighbor;
            pair.distance = cedge.length;
            results.add(pair);
          }
        }
      }
    }
    return results;
  }

  static void _collectEdges(
    List<List<NeighborEdge>> pedges,
    List<List<NeighborEdge>> cedges,
    PairingGraph pairing,
    PriorityQueue<MinutiaPair> queue,
  ) {
    final reference = pairing.tree[pairing.count - 1];
    if (reference == null) {
      throw Exception();
    }
    final pstar = pedges[reference.probe];
    final cstar = cedges[reference.candidate];
    for (final pair in _matchPairs(
      pstar,
      cstar,
    )) {
      pair.probeRef = reference.probe;
      pair.candidateRef = reference.candidate;
      if (pairing.byCandidate[pair.candidate] == null &&
          pairing.byProbe[pair.probe] == null) {
        queue.add(pair);
      } else {
        pairing.support(pair);
      }
    }
  }

  static void _skipPaired(
    PairingGraph pairing,
    PriorityQueue<MinutiaPair> queue,
  ) {
    while (queue.isNotEmpty &&
        (pairing.byProbe[queue.first.probe] != null ||
            pairing.byCandidate[queue.first.candidate] != null)) {
      pairing.support(queue.removeFirst());
    }
  }

  static void crawl(
    List<List<NeighborEdge>> pedges,
    List<List<NeighborEdge>> cedges,
    PairingGraph pairing,
    MinutiaPair root,
    PriorityQueue<MinutiaPair> queue,
  ) {
    queue.add(root);
    do {
      pairing.addPair(queue.removeFirst());
      _collectEdges(pedges, cedges, pairing, queue);
      _skipPaired(pairing, queue);
    } while (queue.isNotEmpty);
  }
}