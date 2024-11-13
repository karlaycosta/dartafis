import 'dart:math' as match;

import '../configuration/parameters.dart';
import '../features/edge_shape.dart';
import '../templates/search_template.dart';
import 'minutia_pair.dart';
import 'pairing_graph.dart';
import 'scoring_data.dart';

void compute(
  SearchTemplate probe,
  SearchTemplate candidate,
  PairingGraph pairing,
  ScoringData score,
) {
  final pminutiae = probe.minutiae;
  final cminutiae = candidate.minutiae;
  final pairingCount = pairing.count;

  score.minutiaCount = pairingCount;
  score.minutiaScore = minutiaScore * pairingCount;
  score.minutiaFractionInProbe = pairingCount / pminutiae.length;
  score.minutiaFractionInCandidate = pairingCount / cminutiae.length;
  score.minutiaFraction =
      0.5 * (score.minutiaFractionInProbe + score.minutiaFractionInCandidate);
  score.minutiaFractionScore = minutiaFractionScore * score.minutiaFraction;

  score.supportingEdgeSum = 0;
  score.supportedMinutiaCount = 0;
  score.minutiaTypeHits = 0;

  for (int i = 0; i < pairingCount; i++) {
    final MinutiaPair pair = pairing.tree[i] ?? (throw Exception());
    score.supportingEdgeSum += pair.supportingEdges;
    if (pair.supportingEdges >= minSupportingEdges) {
      score.supportedMinutiaCount++;
    }
    if (pminutiae[pair.probe].type == cminutiae[pair.candidate].type) {
      score.minutiaTypeHits++;
    }
  }

  score.edgeCount = pairingCount + score.supportingEdgeSum;
  score.edgeScore = edgeScore * score.edgeCount;
  score.supportedMinutiaScore =
      supportedMinutiaScore * score.supportedMinutiaCount;
  score.minutiaTypeScore = minutiaTypeScore * score.minutiaTypeHits;

  final innerDistanceRadius =
      (distanceErrorFlatness * maxDistanceError).round();
  const innerAngleRadius = (angleErrorFlatness * maxAngleError);

  score.distanceErrorSum = 0;
  score.angleErrorSum = 0;

  for (int i = 1; i < pairingCount; i++) {
    final pair = pairing.tree[i] ?? (throw Exception());
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
      distance(probeEdge.referenceAngle, candidateEdge.referenceAngle),
    );
    score.angleErrorSum += match.max(
      innerAngleRadius,
      distance(probeEdge.neighborAngle, candidateEdge.neighborAngle),
    );
  }

  final int distanceErrorPotential =
      maxDistanceError * match.max(0, pairingCount - 1);
  score.distanceAccuracySum = distanceErrorPotential - score.distanceErrorSum;
  score.distanceAccuracyScore = distanceAccuracyScore *
      (distanceErrorPotential > 0
          ? score.distanceAccuracySum / distanceErrorPotential
          : 0);

  final angleErrorPotential =
      maxAngleError * match.max(0, pairingCount - 1) * 2;
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

  score.shapedScore = shape(score.totalScore);
}

double shape(double raw) {
  return switch (raw) {
    < thresholdFmrMax => 0,
    < thresholdFmr_2 => interpolate(raw, thresholdFmrMax, thresholdFmr_2, 0, 3),
    < thresholdFmr_10 =>
      interpolate(raw, thresholdFmr_2, thresholdFmr_10, 3, 7),
    < thresholdFmr_100 =>
      interpolate(raw, thresholdFmr_10, thresholdFmr_100, 10, 10),
    < thresholdFmr_1000 =>
      interpolate(raw, thresholdFmr_100, thresholdFmr_1000, 20, 10),
    < thresholdFmr_10_000 =>
      interpolate(raw, thresholdFmr_1000, thresholdFmr_10_000, 30, 10),
    < thresholdFmr_100_000 =>
      interpolate(raw, thresholdFmr_10_000, thresholdFmr_100_000, 40, 10),
    _ => (raw - thresholdFmr_100_000) /
            (thresholdFmr_100_000 - thresholdFmr_100) *
            30 +
        50,
  };
}

double interpolate(
  double raw,
  double min,
  double max,
  double start,
  double length,
) =>
    (raw - min) / (max - min) * length + start;
