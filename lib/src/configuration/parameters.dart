import 'dart:math' as math;

const int blockSize = 15;
const int histogramDepth = 256;
const double clippedContrast = 0.08;
const double minAbsoluteContrast = 17 / 255;
const double minRelativeContrast = 0.34;
const int relativeContrastSample = 168568;
const double relativeContrastPercentile = 0.49;
const int maskVoteRadius = 7;
const double maskVoteMajority = 0.51;
const int maskVoteBorderDistance = 4;
const int blockErrorsVoteRadius = 1;
const double blockErrorsVoteMajority = 0.7;
const int blockErrorsVoteBorderDistance = 4;
const double maxEqualizationScaling = 3.99;
const double minEqualizationScaling = 0.25;
const double minOrientationRadius = 2;
const double maxOrientationRadius = 6;
const int orientationSplit = 50;
const int orientationsChecked = 20;
const int orientationSmoothingRadius = 1;
const int parallelSmoothingResolution = 32;
const int parallelSmoothingRadius = 7;
const double parallelSmoothingStep = 1.59;
const int orthogonalSmoothingResolution = 11;
const int orthogonalSmoothingRadius = 4;
const double orthogonalSmoothingStep = 1.11;
const int binarizedVoteRadius = 2;
const double binarizedVoteMajority = 0.61;
const int binarizedVoteBorderDistance = 17;
const int innerMaskBorderDistance = 14;
const double maskDisplacement = 10.06;
const int minutiaCloudRadius = 20;
const int maxCloudSize = 4;
const int maxMinutiae = 100;
const int sortByNeighbor = 5;

const int thinningIterations = 26;
const int maxPoreArm = 41;
const int shortestJoinedEnding = 7;
const int maxRuptureSize = 5;
const int maxGapSize = 20;
const int gapAngleOffset = 22;
const int toleratedGapOverlap = 2;
const int minTailLength = 21;
const int minFragmentLength = 22;

const double maxGapAngle = 45 * 0.017453292519943295;
const int ridgeDirectionSample = 21;
const int ridgeDirectionSkip = 1;

/// Número de vizinhos na tabela de arestas.
const int edgeTableNeighbors = 9;

/// Erro máximo de distância permitido.
const int maxDistanceError = 13;

/// Erro máximo de ângulo permitido.
const double maxAngleError = 3.1415926535897932 / 180 * 10;

/// Número máximo de raízes tentadas.
const int maxTriedRoots = 70;

/// Comprimento mínimo da aresta raiz.
const int minRootEdgeLength = 58;

/// Número máximo de buscas de arestas raiz.
const int maxRootEdgeLookups = 1633;

/// Número mínimo de arestas de suporte.
const int minSupportingEdges = 1;

/// Planicidade do erro de distância.
const double distanceErrorFlatness = 0.69;

/// Planicidade do erro de ângulo.
const double angleErrorFlatness = 0.27;

/// Pontuação da minúcia.
const double minutiaScore = 0.032;

/// Pontuação da fração de minúcia.
const double minutiaFractionScore = 8.98;

/// Pontuação do tipo de minúcia.
const double minutiaTypeScore = 0.629;

/// Pontuação da minúcia suportada.
const double supportedMinutiaScore = 0.193;

/// Pontuação da aresta.
const double edgeScore = 0.265;

/// Pontuação da precisão de distância.
const double distanceAccuracyScore = 9.9;

/// Pontuação da precisão de ângulo.
const double angleAccuracyScore = 2.79;

/// Limite máximo de FMR.
const double thresholdFmrMax = 8.48;

/// Limite de FMR para 2.
const double thresholdFmr_2 = 11.12;

/// Limite de FMR para 10.
const double thresholdFmr_10 = 14.15;

/// Limite de FMR para 100.
const double thresholdFmr_100 = 18.22;

/// Limite de FMR para 1000.
const double thresholdFmr_1000 = 22.39;

/// Limite de FMR para 10.000.
const double thresholdFmr_10_000 = 27.24;

/// Limite de FMR para 100.000.
const double thresholdFmr_100_000 = 32.01;

/// Valor de pi.
const double pi = math.pi;

/// Valor de 2 * pi.
const double pi2 = 2 * math.pi;

/// Calcula a diferença entre dois ângulos.
///
/// - [first]: O primeiro ângulo.
/// - [second]: O segundo ângulo.
/// - Retorna a diferença entre os ângulos.
double difference(double first, double second) {
  final angle = first - second;
  return angle >= 0 ? angle : angle + pi2;
}

/// Calcula o ângulo complementar.
///
/// - [angle]: O ângulo original.
/// - Retorna o ângulo complementar.
double complementary(double angle) {
  final complement = pi2 - angle;
  return complement < pi2 ? complement : complement - pi2;
}

/// Calcula o quadrado de um valor inteiro.
///
/// - [value]: O valor a ser elevado ao quadrado.
/// - Retorna o quadrado do valor fornecido.
int sq(int value) => value * value;

/// Enumeração dos tipos de minúcia em uma impressão digital.
///
/// Minúcias são pontos específicos de interesse em uma impressão digital, como
/// terminações de cristas ou bifurcações, que são usados para correspondência
/// de impressões digitais.
enum MinutiaType {
  /// Minúcia de cristas.
  ending,

  /// Minúcia de bifurcação.
  bifurcation,
}

/// Tipo definido para uma minúcia de característica.
///
/// - `x`: Coordenada x da minúcia.
/// - `y`: Coordenada y da minúcia.
/// - `direction`: Direção da minúcia.
/// - `type`: Tipo da minúcia.
typedef FeatureMinutia = ({int x, int y, double direction, MinutiaType type});
