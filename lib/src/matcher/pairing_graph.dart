import 'package:dartafis/dartafis.dart';
import 'package:dartafis/src/matcher/minutia_pair.dart';

/// A classe `PairingGraph` gerencia a correspondência de pares de minúcias
/// entre uma amostra de pesquisa e um template de candidato.
final class PairingGraph {
  /// Contador de pares de minúcias.
  int count = 0;

  /// Lista de pares de minúcias na árvore.
  List<MinutiaPair?> tree = [];

  /// Lista de pares de minúcias por amostra de pesquisa.
  List<MinutiaPair?> byProbe = [];

  /// Lista de pares de minúcias por template de candidato.
  List<MinutiaPair?> byCandidate = [];

  /// Lista de suporte de pares de minúcias.
  final List<MinutiaPair> supportList = [];

  /// Reserva espaço para pares de minúcias da amostra de pesquisa.
  void reserveProbe(SearchMatcher probe) {
    final capacity = probe.search.minutiae.length;
    if (capacity > tree.length) {
      tree = List<MinutiaPair?>.generate(
        capacity,
        (_) => null,
        growable: false,
      );
      byProbe = List<MinutiaPair?>.generate(
        capacity,
        (_) => null,
        growable: false,
      );
    }
  }

  /// Reserva espaço para pares de minúcias do template de candidato.
  void reserveCandidate(SearchTemplate candidate) {
    final capacity = candidate.minutiae.length;
    if (byCandidate.length < capacity) {
      byCandidate = List<MinutiaPair?>.generate(
        capacity,
        (_) => null,
        growable: false,
      );
    }
  }

  /// Adiciona um par de minúcias.
  void addPair(MinutiaPair pair) {
    if (count >= tree.length) {
      throw Exception('Capacity exceeded');
    }
    tree[count] = pair;
    byProbe[pair.probe] = pair;
    byCandidate[pair.candidate] = pair;
    count++;
  }

  /// Adiciona suporte a um par de minúcias.
  void support(MinutiaPair pair) {
    final probePair = byProbe[pair.probe];
    if (probePair != null && probePair.candidate == pair.candidate) {
      probePair.supportingEdges++;
      byProbe[pair.probeRef]?.supportingEdges++;
    }
  }

  /// Limpa todos os pares de minúcias.
  void clear() {
    for (var i = 0; i < count; i++) {
      final pair = tree[i];
      if (pair != null) {
        byProbe[pair.probe] = null;
        byCandidate[pair.candidate] = null;
        tree[i] = null;
      }
    }
    count = 0;
  }
}
