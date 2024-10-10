import 'package:collection/collection.dart';

import '../templates/search_template.dart';
import 'edge_spider.dart';
import 'minutia_pair.dart';
import 'pairing_graph.dart';
import 'root_enumerator.dart';
import 'root_list.dart';
import 'scoring.dart';
import 'scoring_data.dart';

final class Matcher {
  late final roots = RootList();
  late final pairing = PairingGraph();
  final queue =
      PriorityQueue<MinutiaPair>((a, b) => a.distance.compareTo(b.distance));
  final score = ScoringData();
}

double findMatch(Probe probe, SearchTemplate candidate) {
  final matcher = Matcher();
  try {
    matcher.pairing.reserveProbe(probe);
    matcher.pairing.reserveCandidate(candidate);
    RootEnumerator.enumerate(probe, candidate, matcher.roots);
    double high = 0;
    int best = -1;
    for (int i = 0; i < matcher.roots.pairs.length; i++) {
      EdgeSpider.crawl(probe.template.edges, candidate.edges, matcher.pairing,
          matcher.roots.pairs[i], matcher.queue);
      Scoring.compute(
          probe.template, candidate, matcher.pairing, matcher.score);
      double partial = matcher.score.shapedScore;
      if (best < 0 || partial > high) {
        high = partial;
        best = i;
      }
      matcher.pairing.clear();
    }
    if (best >= 0) {
      EdgeSpider.crawl(probe.template.edges, candidate.edges, matcher.pairing,
          matcher.roots.pairs[best], matcher.queue);
      Scoring.compute(
          probe.template, candidate, matcher.pairing, matcher.score);
      matcher.pairing.clear();
    }
    matcher.roots.discard();
    return high;
  } catch (ex) {
    rethrow;
  }
}
