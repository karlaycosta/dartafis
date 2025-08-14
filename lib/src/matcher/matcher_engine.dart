import 'package:dartafis/dartafis.dart';
import 'package:dartafis/src/features/edge_shape.dart';
import 'package:dartafis/src/matcher/edge_hashes.dart';
import 'package:dartafis/src/matcher/edge_spider.dart';
import 'package:dartafis/src/matcher/minutia_pair.dart';
import 'package:dartafis/src/matcher/pairing_graph.dart';
import 'package:dartafis/src/matcher/root_list.dart';
import 'package:dartafis/src/matcher/scoring.dart';
import 'package:dartafis/src/matcher/scoring_data.dart';
import 'package:dartafis/src/primitives/priority_queue.dart';

/// Classe que representa o mecanismo de correspondência.
///
/// A classe `Matcher` é responsável por armazenar e gerenciar os dados
/// necessários para realizar a correspondência entre um `SearchMatcher`
/// e um `SearchTemplate`.
final class Matcher {
  /// Lista de raízes utilizadas na correspondência.
  late final roots = RootList();

  /// Grafo de pareamento utilizado na correspondência.
  late final pairing = PairingGraph();

  /// Fila de prioridade para armazenar pares de minúcias.
  final queue = PriorityQueue<MinutiaPair>(
    (a, b) => a.distance.compareTo(b.distance),
  );

  /// Dados de pontuação utilizados na correspondência.
  final score = ScoringData();
}

/// Função que encontra a correspondência entre um `SearchMatcher` e
/// um `SearchTemplate`.
///
/// - [probe]: O `SearchMatcher` utilizado na correspondência.
/// - [candidate]: O `SearchTemplate` candidato a ser correspondido.
///
/// Retorna um `Future<double>` que completa com a pontuação da correspondência.
Future<double> findMatch(SearchMatcher probe, SearchTemplate candidate) async {
  final matcher = Matcher();
  try {
    matcher.pairing.reserveProbe(probe);
    matcher.pairing.reserveCandidate(candidate);
    await _enumerate(probe, candidate, matcher.roots);

    var high = 0.0;
    var best = -1;

    // Pré-calcular as arestas para evitar recalcular dentro do loop
    final probeEdges = probe.search.edges;
    final candidateEdges = candidate.edges;

    final length = matcher.roots.pairs.length; // Cache for
    for (var i = 0; i < length; i++) {
      crawl(
        probeEdges,
        candidateEdges,
        matcher.pairing,
        matcher.roots.pairs[i],
        matcher.queue,
      );
      compute(probe.search, candidate, matcher.pairing, matcher.score);
      final partial = matcher.score.shapedScore;
      if (partial > high) {
        high = partial;
        best = i;
      }
      matcher.pairing.clear();
    }

    if (best >= 0) {
      crawl(
        probeEdges,
        candidateEdges,
        matcher.pairing,
        matcher.roots.pairs[best],
        matcher.queue,
      );
      compute(probe.search, candidate, matcher.pairing, matcher.score);
      matcher.pairing.clear();
    }
    matcher.roots.discard();
    return high;
  } catch (ex) {
    rethrow;
  }
}

/// Função auxiliar para enumerar as correspondências.
///
/// [probe]: O `SearchMatcher` utilizado na correspondência.
/// [candidate]: O `SearchTemplate` candidato a ser correspondido.
/// [roots]: A lista de raízes utilizada na correspondência.
Future<void> _enumerate(
  SearchMatcher probe,
  SearchTemplate candidate,
  RootList roots,
) async {
  final cminutiae = candidate.minutiae;
  var lookups = 0;
  var tried = 0;

  for (final shortEdges in {false, true}) {
    final length = cminutiae.length; // Cache for
    for (var period = 1; period < length; period++) {
      for (var phase = 0; phase <= period; phase++) {
        for (var cRef = phase; cRef < length; cRef += period + 1) {
          final cneighbor = (cRef + period) % length;
          final cedge = EdgeShape(cminutiae[cRef], cminutiae[cneighbor]);

          if ((cedge.length >= minRootEdgeLength) ^ shortEdges) {
            final matches = probe.hash[hash(cedge)];

            if (matches != null) {
              for (final match in matches) {
                if (matching(match, cedge)) {
                  final duplicateKey = (match.reference << 16) | cRef;

                  if (roots.duplicates.add(duplicateKey)) {
                    roots.pairs.add(
                      MinutiaPair(probe: match.reference, candidate: cRef),
                    );
                  }
                  if (++tried >= maxTriedRoots) return;
                }
              }
            }

            if (++lookups >= maxRootEdgeLookups) return;
          }
        }
      }
    }
  }
}
