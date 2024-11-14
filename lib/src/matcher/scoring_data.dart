/// Classe que representa os dados de pontuação utilizados na correspondência.
///
/// A classe `ScoringData` armazena várias métricas e pontuações que são
/// calculadas durante o processo de correspondência de minúcias.
final class ScoringData {
  /// Contagem de minúcias correspondidas.
  int minutiaCount = 0;

  /// Pontuação baseada na contagem de minúcias.
  double minutiaScore = 0;

  /// Fração de minúcias no probe.
  double minutiaFractionInProbe = 0;

  /// Fração de minúcias no candidato.
  double minutiaFractionInCandidate = 0;

  /// Fração média de minúcias.
  double minutiaFraction = 0;

  /// Pontuação baseada na fração de minúcias.
  double minutiaFractionScore = 0;

  /// Soma das arestas de suporte.
  int supportingEdgeSum = 0;

  /// Contagem total de arestas.
  int edgeCount = 0;

  /// Pontuação baseada na contagem de arestas.
  double edgeScore = 0;

  /// Contagem de minúcias suportadas.
  int supportedMinutiaCount = 0;

  /// Pontuação baseada na contagem de minúcias suportadas.
  double supportedMinutiaScore = 0;

  /// Contagem de acertos de tipos de minúcias.
  int minutiaTypeHits = 0;

  /// Pontuação baseada nos tipos de minúcias.
  double minutiaTypeScore = 0;

  /// Soma dos erros de distância.
  int distanceErrorSum = 0;

  /// Soma da precisão de distância.
  int distanceAccuracySum = 0;

  /// Pontuação baseada na precisão de distância.
  double distanceAccuracyScore = 0;

  /// Soma dos erros de ângulo.
  double angleErrorSum = 0;

  /// Soma da precisão de ângulo.
  double angleAccuracySum = 0;

  /// Pontuação baseada na precisão de ângulo.
  double angleAccuracyScore = 0;

  /// Pontuação total.
  double totalScore = 0;

  /// Pontuação ajustada.
  double shapedScore = 0;
}
