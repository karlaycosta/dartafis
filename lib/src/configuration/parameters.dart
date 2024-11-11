import 'dart:math' as math;

const int edgeTableNeighbors = 9;
const int maxDistanceError = 13;
const double maxAngleError = 3.1415926535897932 / 180 * 10;
const int maxTriedRoots = 70;
const int minRootEdgeLength = 58;
const int maxRootEdgeLookups = 1633;
const int minSupportingEdges = 1;
const double distanceErrorFlatness = 0.69;
const double angleErrorFlatness = 0.27;
const double minutiaScore = 0.032;
const double minutiaFractionScore = 8.98;
const double minutiaTypeScore = 0.629;
const double supportedMinutiaScore = 0.193;
const double edgeScore = 0.265;
const double distanceAccuracyScore = 9.9;
const double angleAccuracyScore = 2.79;
const double thresholdFmrMax = 8.48;
const double thresholdFmr_2 = 11.12;
const double thresholdFmr_10 = 14.15;
const double thresholdFmr_100 = 18.22;
const double thresholdFmr_1000 = 22.39;
const double thresholdFmr_10_000 = 27.24;
const double thresholdFmr_100_000 = 32.01;

const double pi = math.pi;
const double pi2 = 2 * math.pi;
const double halfPi = 0.5 * math.pi;

/// Utility class for floating point angle operations.

double add(double start, double delta) {
  final double angle = start + delta;
  return angle < pi2 ? angle : angle - pi2;
}

double difference(double first, double second) {
  final double angle = first - second;
  return angle >= 0 ? angle : angle + pi2;
}

double distance(double first, double second) {
  final double delta = (first - second).abs();
  return delta <= pi ? delta : pi2 - delta;
}

double opposite(double angle) {
  return angle < pi ? angle + pi : angle - pi;
}

double complementary(double angle) {
  final double complement = pi2 - angle;
  return complement < pi2 ? complement : complement - pi2;
}

/// End utility class for floating point angle operations.

/// Utility class for integer operations.

/// Retorna o número de zero bits que precedem o bit de ordem mais alta ("mais à esquerda")
/// na representação binária de complemento de dois do valor [int] especificado. Retorna 32
/// se o valor especificado não tiver um bit em sua representação em complemento de dois,
/// ou seja, se for igual a zero.
int numberOfLeadingZeros(int i) {
  if (i <= 0) return i < 0 ? 0 : 32;
  int n = 1;
  if (i >> 16 == 0) {
    n += 16;
    i <<= 16;
  }
  if (i >> 24 == 0) {
    n += 8;
    i <<= 8;
  }
  if (i >> 28 == 0) {
    n += 4;
    i <<= 4;
  }
  if (i >> 30 == 0) {
    n += 2;
    i <<= 2;
  }
  n -= i >> 31;
  return n;
}

/// End utility class for integer operations.

typedef IntPoint = ({int x, int y});

enum MinutiaType { ending, bifurcation }

typedef FeatureMinutia = ({
  int x,
  int y,
  double direction,
  MinutiaType type,
});