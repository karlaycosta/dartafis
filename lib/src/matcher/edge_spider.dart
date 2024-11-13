import 'package:collection/collection.dart';

import '../configuration/parameters.dart';
import '../features/neighbor_edge.dart';
import 'minutia_pair.dart';
import 'pairing_graph.dart';

final double _complementaryMaxAngleError = complementary(maxAngleError);

List<MinutiaPair> _matchPairs(
  List<NeighborEdge> pstar,
  List<NeighborEdge> cstar,
) {
  final results = <MinutiaPair>[];
  int start = 0;
  int end = 0;
  for (final cedge in cstar) {
    while (start < pstar.length &&
        pstar[start].length < cedge.length - maxDistanceError) {
      start++;
    }

    if (end < start) end = start;

    while (end < pstar.length &&
        pstar[end].length <= cedge.length + maxDistanceError) {
      end++;
    }

    for (int pindex = start; pindex < end; pindex++) {
      final pedge = pstar[pindex];
      final rdiff = difference(pedge.referenceAngle, cedge.referenceAngle);
      if (rdiff <= maxAngleError || rdiff >= _complementaryMaxAngleError) {
        final ndiff = difference(pedge.neighborAngle, cedge.neighborAngle);
        if (ndiff <= maxAngleError || ndiff >= _complementaryMaxAngleError) {
          results.add(MinutiaPair(
            probe: pedge.neighbor,
            candidate: cedge.neighbor,
            distance: cedge.length,
          ));
        }
      }
    }
  }
  return results;
}

void _collectEdges(
  List<List<NeighborEdge>> pedges,
  List<List<NeighborEdge>> cedges,
  PairingGraph pairing,
  PriorityQueue<MinutiaPair> queue,
) {
  final reference = pairing.tree[pairing.count - 1] ?? (throw Exception());

  final pstar = pedges[reference.probe];
  final cstar = cedges[reference.candidate];
  for (final pair in _matchPairs(pstar, cstar)) {
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

void _skipPaired(
  PairingGraph pairing,
  PriorityQueue<MinutiaPair> queue,
) {
  while (queue.isNotEmpty &&
      (pairing.byProbe[queue.first.probe] != null ||
          pairing.byCandidate[queue.first.candidate] != null)) {
    pairing.support(queue.removeFirst());
  }
}

void crawl(
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