import '../templates/search_template.dart';
import 'minutia_pair.dart';

final class PairingGraph {
  int count = 0;
  List<MinutiaPair?> tree = [];
  List<MinutiaPair?> byProbe = [];
  List<MinutiaPair?> byCandidate = [];
  final List<MinutiaPair> supportList = [];

  void reserveProbe(Probe probe) {
    final capacity = probe.template.minutiae.length;
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

  void addPair(MinutiaPair pair) {
    if (count >= tree.length) {
      throw Exception('Capacity exceeded');
    }
    tree[count] = pair;
    byProbe[pair.probe] = pair;
    byCandidate[pair.candidate] = pair;
    count++;
  }

  void support(MinutiaPair pair) {
    final probePair = byProbe[pair.probe];
    if (probePair != null && probePair.candidate == pair.candidate) {
      probePair.supportingEdges++;
      byProbe[pair.probeRef]?.supportingEdges++;
    }
  }

  void clear() {
    for (int i = 0; i < count; i++) {
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
