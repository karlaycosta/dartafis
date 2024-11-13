import '../configuration/parameters.dart';
import '../features/edge_shape.dart';
import '../templates/search_template.dart';
import 'edge_hashes.dart';
import 'minutia_pair.dart';
import 'root_list.dart';

final class RootEnumerator {
  static void enumerate(Probe probe, SearchTemplate candidate, RootList roots) {
    final cminutiae = candidate.minutiae;
    int lookups = 0;
    int tried = 0;

    for (bool shortEdges in {false, true}) {
      for (int period = 1; period < cminutiae.length; period++) {
        for (int phase = 0; phase <= period; phase++) {
          for (int creference = phase;
              creference < cminutiae.length;
              creference += period + 1) {
            final cneighbor = (creference + period) % cminutiae.length;
            final cedge =
                EdgeShape(cminutiae[creference], cminutiae[cneighbor]);

            if ((cedge.length >= minRootEdgeLength) ^ shortEdges) {
              final matches = probe.hash[hash(cedge)];

              if (matches != null) {
                for (final match in matches) {
                  if (matching(match, cedge)) {
                    final duplicateKey = (match.reference << 16) | creference;

                    if (roots.duplicates.add(duplicateKey)) {
                      roots.pairs.add(MinutiaPair(
                        probe: match.reference,
                        candidate: creference,
                      ));
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
}
