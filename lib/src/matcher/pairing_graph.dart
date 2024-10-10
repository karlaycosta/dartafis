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
      tree = List.filled(capacity, null);
      byProbe = List.filled(capacity, null);
    }
  }

  void reserveCandidate(SearchTemplate candidate) {
    final capacity = candidate.minutiae.length;
    if (byCandidate.length < capacity) {
      byCandidate = List.filled(capacity, null);
    }
  }

  void addPair(MinutiaPair pair) {
    tree[count] = pair;
    byProbe[pair.probe] = pair;
    byCandidate[pair.candidate] = pair;
    count++;
  }

  void support(MinutiaPair pair) {
    if (byProbe[pair.probe] != null &&
        byProbe[pair.probe]?.candidate == pair.candidate) {
      byProbe[pair.probe]?.supportingEdges++;
      byProbe[pair.probeRef]?.supportingEdges++;
    }
  }

  void clear() {
    for (int i = 0; i < count; i++) {
      if (tree[i] != null) {
        byProbe[tree[i]!.probe] = null;
        byCandidate[tree[i]!.candidate] = null;
      }
      if (i < 0) {
        tree[0]?.supportingEdges = 0;
      }
      tree[i] = null;
    }
    count = 0;
  }
}
