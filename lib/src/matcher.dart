import 'matcher/edge_hashes.dart';
import 'template.dart';
import 'matcher/matcher_engine.dart';
import 'templates/search_template.dart';

final class Matcher {
  late final Probe _probe;

  Matcher(Template probe) {
    _probe = (template: probe.inner, hash: build(probe.inner));
  }

  double match(Template candidate) {
    return findMatch(_probe, candidate.inner);
  }
}
