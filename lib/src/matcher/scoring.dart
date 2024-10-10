import 'dart:math' as match;

import '../configuration/parameters.dart';
import '../features/edge_shape.dart';
import '../primitives/float_angle.dart';
import '../templates/search_template.dart';
import 'minutia_pair.dart';
import 'pairing_graph.dart';
import 'scoring_data.dart';

final class Scoring {
  static void compute(SearchTemplate probe, SearchTemplate candidate,
      PairingGraph pairing, ScoringData score) {
    final pminutiae = probe.minutiae;
    final cminutiae = candidate.minutiae;
    score.minutiaCount = pairing.count;
    score.minutiaScore = minutiaScore * score.minutiaCount;
    score.minutiaFractionInProbe = pairing.count / pminutiae.length;
    score.minutiaFractionInCandidate = pairing.count / cminutiae.length;
    score.minutiaFraction =
        0.5 * (score.minutiaFractionInProbe + score.minutiaFractionInCandidate);
    score.minutiaFractionScore = minutiaFractionScore * score.minutiaFraction;
    score.supportingEdgeSum = 0;
    score.supportedMinutiaCount = 0;
    score.minutiaTypeHits = 0;
    for (int i = 0; i < pairing.count; i++) {
      if (pairing.tree[i] == null) throw Exception();
      final MinutiaPair pair = pairing.tree[i]!;
      score.supportingEdgeSum += pair.supportingEdges;
      if (pair.supportingEdges >= minSupportingEdges) {
        score.supportedMinutiaCount++;
      }
      if (pminutiae[pair.probe].type == cminutiae[pair.candidate].type) {
        score.minutiaTypeHits++;
      }
    }
    score.edgeCount = pairing.count + score.supportingEdgeSum;
    score.edgeScore = edgeScore * score.edgeCount;
    score.supportedMinutiaScore =
        supportedMinutiaScore * score.supportedMinutiaCount;
    score.minutiaTypeScore = minutiaTypeScore * score.minutiaTypeHits;
    final innerDistanceRadius =
        (distanceErrorFlatness * maxDistanceError).round();
    const innerAngleRadius = (angleErrorFlatness * maxAngleError);
    score.distanceErrorSum = 0;
    score.angleErrorSum = 0;
    for (int i = 1; i < pairing.count; i++) {
      if (pairing.tree[i] == null) throw Exception();
      final MinutiaPair pair = pairing.tree[i]!;
      final probeEdge =
          EdgeShape(pminutiae[pair.probeRef], pminutiae[pair.probe]);
      final candidateEdge =
          EdgeShape(cminutiae[pair.candidateRef], cminutiae[pair.candidate]);
      score.distanceErrorSum += match.max(
        innerDistanceRadius,
        (probeEdge.length - candidateEdge.length).abs(),
      );
      score.angleErrorSum += match.max(
          innerAngleRadius,
          FloatAngle.distance(
            probeEdge.referenceAngle,
            candidateEdge.referenceAngle,
          ));
      score.angleErrorSum += match.max(
          innerAngleRadius,
          FloatAngle.distance(
            probeEdge.neighborAngle,
            candidateEdge.neighborAngle,
          ));
    }
    score.distanceAccuracyScore = 0;
    score.angleAccuracyScore = 0;
    final int distanceErrorPotential =
        maxDistanceError * match.max(0, pairing.count - 1);
    score.distanceAccuracySum = distanceErrorPotential - score.distanceErrorSum;
    score.distanceAccuracyScore = distanceAccuracyScore *
        (distanceErrorPotential > 0
            ? score.distanceAccuracySum / distanceErrorPotential
            : 0);
    final angleErrorPotential =
        maxAngleError * match.max(0, pairing.count - 1) * 2;
    score.angleAccuracySum = angleErrorPotential - score.angleErrorSum;
    score.angleAccuracyScore = angleAccuracyScore *
        (angleErrorPotential > 0
            ? score.angleAccuracySum / angleErrorPotential
            : 0);
    score.totalScore = score.minutiaScore +
        score.minutiaFractionScore +
        score.supportedMinutiaScore +
        score.edgeScore +
        score.minutiaTypeScore +
        score.distanceAccuracyScore +
        score.angleAccuracyScore;
    score.shapedScore = _shape(score.totalScore);
  }

  static double _shape(double raw) {
    return switch (raw) {
      < thresholdFmrMax => 0,
      < thresholdFmr_2 =>
        _interpolate(raw, thresholdFmrMax, thresholdFmr_2, 0, 3),
      < thresholdFmr_10 =>
        _interpolate(raw, thresholdFmr_2, thresholdFmr_10, 3, 7),
      < thresholdFmr_100 =>
        _interpolate(raw, thresholdFmr_10, thresholdFmr_100, 10, 10),
      < thresholdFmr_1000 =>
        _interpolate(raw, thresholdFmr_100, thresholdFmr_1000, 20, 10),
      < thresholdFmr_10_000 =>
        _interpolate(raw, thresholdFmr_1000, thresholdFmr_10_000, 30, 10),
      < thresholdFmr_100_000 =>
        _interpolate(raw, thresholdFmr_10_000, thresholdFmr_100_000, 40, 10),
      _ => (raw - thresholdFmr_100_000) /
              (thresholdFmr_100_000 - thresholdFmr_100) *
              30 +
          50,
    };
    // if (raw < thresholdFmrMax) {
    //   return 0;
    // }
    // if (raw < thresholdFmr_2) {
    //   return _interpolate(raw, thresholdFmrMax, thresholdFmr_2, 0, 3);
    // }
    // if (raw < thresholdFmr_10) {
    //   return _interpolate(raw, thresholdFmr_2, thresholdFmr_10, 3, 7);
    // }
    // if (raw < thresholdFmr_100) {
    //   return _interpolate(raw, thresholdFmr_10, thresholdFmr_100, 10, 10);
    // }
    // if (raw < thresholdFmr_1000) {
    //   return _interpolate(raw, thresholdFmr_100, thresholdFmr_1000, 20, 10);
    // }
    // if (raw < thresholdFmr_10_000) {
    //   return _interpolate(raw, thresholdFmr_1000, thresholdFmr_10_000, 30, 10);
    // }
    // if (raw < thresholdFmr_100_000) {
    //   return _interpolate(
    //       raw, thresholdFmr_10_000, thresholdFmr_100_000, 40, 10);
    // }
    // return (raw - thresholdFmr_100_000) /
    //         (thresholdFmr_100_000 - thresholdFmr_100) *
    //         30 +
    //     50;
  }

  static double _interpolate(
    double raw,
    double min,
    double max,
    double start,
    double length,
  ) =>
      (raw - min) / (max - min) * length + start;
}
