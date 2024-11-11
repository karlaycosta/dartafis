import 'dart:math' as match;

import '../configuration/parameters.dart';
import '../features/edge_shape.dart';
import '../features/indexed_edge.dart';
import '../templates/search_template.dart';

final class EdgeHashes {
  static final double _complementaryMaxAngleError =
      complementary(maxAngleError);

  static int hash(EdgeShape edge) {
    final int lengthBin = edge.length ~/ maxDistanceError;
    final int referenceAngleBin = edge.referenceAngle ~/ maxAngleError;
    final int neighborAngleBin = edge.neighborAngle ~/ maxAngleError;
    return (referenceAngleBin << 24) + (neighborAngleBin << 16) + lengthBin;
  }

  static bool matching(EdgeShape probe, EdgeShape candidate) {
    final int lengthDelta = probe.length - candidate.length;
    if (lengthDelta >= -maxDistanceError && lengthDelta <= maxDistanceError) {
      final referenceDelta =
          difference(probe.referenceAngle, candidate.referenceAngle);
      if (referenceDelta <= maxAngleError ||
          referenceDelta >= _complementaryMaxAngleError) {
        final neighborDelta =
            difference(probe.neighborAngle, candidate.neighborAngle);
        if (neighborDelta <= maxAngleError ||
            neighborDelta >= _complementaryMaxAngleError) {
          return true;
        }
      }
    }
    return false;
  }

  static List<int> _coverage(EdgeShape edge) {
    final int minLengthBin =
        (edge.length - maxDistanceError) ~/ maxDistanceError;
    final int maxLengthBin =
        (edge.length + maxDistanceError) ~/ maxDistanceError;
    final int angleBins = (2 * match.pi / maxAngleError).ceil();
    final int minReferenceBin =
        difference(edge.referenceAngle, maxAngleError) ~/ maxAngleError;
    final int maxReferenceBin =
        add(edge.referenceAngle, maxAngleError) ~/ maxAngleError;
    final int endReferenceBin = (maxReferenceBin + 1) % angleBins;
    final int minNeighborBin =
        difference(edge.neighborAngle, maxAngleError) ~/ maxAngleError;
    final int maxNeighborBin =
        add(edge.neighborAngle, maxAngleError) ~/ maxAngleError;
    final int endNeighborBin = (maxNeighborBin + 1) % angleBins;
    final coverage = <int>[];
    for (int lengthBin = minLengthBin; lengthBin <= maxLengthBin; lengthBin++) {
      for (int referenceBin = minReferenceBin;
          referenceBin != endReferenceBin;
          referenceBin = (referenceBin + 1) % angleBins) {
        for (int neighborBin = minNeighborBin;
            neighborBin != endNeighborBin;
            neighborBin = (neighborBin + 1) % angleBins) {
          coverage.add((referenceBin << 24) + (neighborBin << 16) + lengthBin);
        }
      }
    }
    return coverage;
  }

  static Map<int, List<IndexedEdge>> build(SearchTemplate template) {
    final map = <int, List<IndexedEdge>>{};
    for (int reference = 0; reference < template.minutiae.length; reference++) {
      for (int neighbor = 0; neighbor < template.minutiae.length; neighbor++) {
        if (reference != neighbor) {
          final edge = IndexedEdge(template.minutiae, reference, neighbor);
          for (final hash in _coverage(edge)) {
            List<IndexedEdge>? list = map[hash];
            if (list == null) {
              map[hash] = list = [];
            }
            list.add(edge);
          }
        }
      }
    }
    return map;
  }
}
