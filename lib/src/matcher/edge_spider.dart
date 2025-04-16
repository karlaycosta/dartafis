import 'package:collection/collection.dart';

import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/neighbor_edge.dart';
import 'package:dartafis/src/matcher/minutia_pair.dart';
import 'package:dartafis/src/matcher/pairing_graph.dart';

final double _complementaryMaxAngleError = complementary(maxAngleError);

/// Encontra pares de minúcias correspondentes entre duas listas de
/// arestas vizinhas.
///
/// - [pstar] - Lista de arestas vizinhas da amostra de pesquisa.
/// - [cstar] - Lista de arestas vizinhas do template de candidato.
///
/// Retorna uma lista de pares de minúcias correspondentes.
List<MinutiaPair> _matchPairs(
  List<NeighborEdge> pstar,
  List<NeighborEdge> cstar,
) {
  final results = <MinutiaPair>[];
  var start = 0;
  var end = 0;
  for (final cedge in cstar) {
    final length = pstar.length; // Cache for
    final cLength = cedge.length; // Cache for
    while (start < length && pstar[start].length < cLength - maxDistanceError) {
      start++;
    }

    if (end < start) end = start;

    while (end < length && pstar[end].length <= cLength + maxDistanceError) {
      end++;
    }

    for (var pindex = start; pindex < end; pindex++) {
      final pedge = pstar[pindex];
      final rdiff = difference(pedge.referenceAngle, cedge.referenceAngle);
      if (rdiff <= maxAngleError || rdiff >= _complementaryMaxAngleError) {
        final ndiff = difference(pedge.neighborAngle, cedge.neighborAngle);
        if (ndiff <= maxAngleError || ndiff >= _complementaryMaxAngleError) {
          results.add(
            MinutiaPair(
              probe: pedge.neighbor,
              candidate: cedge.neighbor,
              distance: cLength,
            ),
          );
        }
      }
    }
  }
  return results;
}

/// Coleta arestas correspondentes e as adiciona à fila de prioridade.
///
/// - [pedges] - Lista de listas de arestas vizinhas da amostra de pesquisa.
/// - [cedges] - Lista de listas de arestas vizinhas do template de candidato.
/// - [pairing] - Grafo de pareamento.
/// - [queue] - Fila de prioridade de pares de minúcias.
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
    pair
      ..probeRef = reference.probe
      ..candidateRef = reference.candidate;
    if (pairing.byCandidate[pair.candidate] == null &&
        pairing.byProbe[pair.probe] == null) {
      queue.add(pair);
    } else {
      pairing.support(pair);
    }
  }
}

/// Remove pares de minúcias já pareados da fila de prioridade e adiciona
/// suporte a eles.
///
/// - [pairing] - Grafo de pareamento.
/// - [queue] - Fila de prioridade de pares de minúcias.
void _skipPaired(PairingGraph pairing, PriorityQueue<MinutiaPair> queue) {
  while (queue.isNotEmpty &&
      (pairing.byProbe[queue.first.probe] != null ||
          pairing.byCandidate[queue.first.candidate] != null)) {
    pairing.support(queue.removeFirst());
  }
}

/// Realiza a correspondência de pares de minúcias entre duas listas de
/// arestas vizinhas.
///
/// - [pedges] - Lista de listas de arestas vizinhas da amostra de pesquisa.
/// - [cedges] - Lista de listas de arestas vizinhas do template de candidato.
/// - [pairing] - Grafo de pareamento.
/// - [root] - Par de minúcias raiz.
/// - [queue] - Fila de prioridade de pares de minúcias.
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
