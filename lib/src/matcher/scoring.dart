import 'dart:math' as match;

import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/edge_shape.dart';
import 'package:dartafis/src/matcher/pairing_graph.dart';
import 'package:dartafis/src/matcher/scoring_data.dart';
import 'package:dartafis/src/templates/search_template.dart';

/// Calcula a pontuação com base nos critérios fornecidos.
///
/// Esta função recebe vários parâmetros e calcula a pontuação
/// de acordo. Os critérios e parâmetros exatos devem ser definidos
/// dentro da implementação da função.
///
/// Nota: Certifique-se de que todos os parâmetros necessários sejam passados
/// para esta função para um cálculo preciso da pontuação.
void compute(
  SearchTemplate probe,
  SearchTemplate candidate,
  PairingGraph pairing,
  ScoringData score,
) {
  final pminutiae = probe.minutiae;
  final cminutiae = candidate.minutiae;
  final pairingCount = pairing.count;

  score
    ..minutiaCount = pairingCount
    ..minutiaScore = minutiaScore * pairingCount
    ..minutiaFractionInProbe = pairingCount / pminutiae.length
    ..minutiaFractionInCandidate = pairingCount / cminutiae.length
    ..minutiaFraction =
        0.5 * (score.minutiaFractionInProbe + score.minutiaFractionInCandidate)
    ..minutiaFractionScore = minutiaFractionScore * score.minutiaFraction
    ..supportingEdgeSum = 0
    ..supportedMinutiaCount = 0
    ..minutiaTypeHits = 0;

  for (var i = 0; i < pairingCount; i++) {
    final pair = pairing.tree[i] ?? (throw Exception());
    score.supportingEdgeSum += pair.supportingEdges;
    if (pair.supportingEdges >= minSupportingEdges) {
      score.supportedMinutiaCount++;
    }
    if (pminutiae[pair.probe].type == cminutiae[pair.candidate].type) {
      score.minutiaTypeHits++;
    }
  }

  score
    ..edgeCount = pairingCount + score.supportingEdgeSum
    ..edgeScore = edgeScore * score.edgeCount
    ..supportedMinutiaScore =
        supportedMinutiaScore * score.supportedMinutiaCount
    ..minutiaTypeScore = minutiaTypeScore * score.minutiaTypeHits;

  final innerDistanceRadius =
      (distanceErrorFlatness * maxDistanceError).round();
  const innerAngleRadius = angleErrorFlatness * maxAngleError;

  score
    ..distanceErrorSum = 0
    ..angleErrorSum = 0;

  for (var i = 1; i < pairingCount; i++) {
    final pair = pairing.tree[i] ?? (throw Exception());
    final probeEdge =
        EdgeShape(pminutiae[pair.probeRef], pminutiae[pair.probe]);
    final candidateEdge =
        EdgeShape(cminutiae[pair.candidateRef], cminutiae[pair.candidate]);
    score
      ..distanceErrorSum += match.max(
        innerDistanceRadius,
        (probeEdge.length - candidateEdge.length).abs(),
      )
      ..angleErrorSum += match.max(
        innerAngleRadius,
        _distance(probeEdge.referenceAngle, candidateEdge.referenceAngle),
      )
      ..angleErrorSum += match.max(
        innerAngleRadius,
        _distance(probeEdge.neighborAngle, candidateEdge.neighborAngle),
      );
  }

  final distanceErrorPotential =
      maxDistanceError * match.max<int>(0, pairingCount - 1);
  score
    ..distanceAccuracySum = distanceErrorPotential - score.distanceErrorSum
    ..distanceAccuracyScore = distanceAccuracyScore *
        (distanceErrorPotential > 0
            ? score.distanceAccuracySum / distanceErrorPotential
            : 0);

  final angleErrorPotential =
      maxAngleError * match.max(0, pairingCount - 1) * 2;
  score
    ..angleAccuracySum = angleErrorPotential - score.angleErrorSum
    ..angleAccuracyScore = angleAccuracyScore *
        (angleErrorPotential > 0
            ? score.angleAccuracySum / angleErrorPotential
            : 0)
    ..totalScore = score.minutiaScore +
        score.minutiaFractionScore +
        score.supportedMinutiaScore +
        score.edgeScore +
        score.minutiaTypeScore +
        score.distanceAccuracyScore +
        score.angleAccuracyScore
    ..shapedScore = _shape(score.totalScore);
}

double _distance(double first, double second) {
  final delta = (first - second).abs();
  return delta <= pi ? delta : pi2 - delta;
}

double _shape(double raw) => switch (raw) {
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

double _interpolate(
  double raw,
  double min,
  double max,
  double start,
  double length,
) =>
    (raw - min) / (max - min) * length + start;
