// ignore_for_file: parameter_assignments

import 'dart:math' as math;

import 'package:dartafis/src/configuration/parameters.dart';

/// A classe `EdgeShape` representa a forma de uma aresta entre duas minúcias.
///
/// Esta classe calcula o comprimento e os ângulos de referência e do vizinho
/// com base nas coordenadas das minúcias fornecidas.
class EdgeShape {
  /// Cria uma instância de `EdgeShape`.
  ///
  /// - [reference]: A minúcia de referência.
  /// - [neighbor]: A minúcia vizinha.
  EdgeShape(FeatureMinutia reference, FeatureMinutia neighbor) {
    _load();
    var quadrant = 0.0;
    var x = neighbor.x - reference.x;
    var y = neighbor.y - reference.y;
    if (y < 0) {
      x = -x;
      y = -y;
      quadrant = pi;
    }
    if (x < 0) {
      final tmp = x;
      x = y;
      y = -tmp;
      quadrant += _halfPi;
    }
    final shift = 32 - _numberOfLeadingZeros((x | y) >>> polarCacheBits);
    final offset = (y >> shift) * polarCacheRadius + (x >> shift);
    length = polarDistanceCache[offset] << shift;
    final angle = polarAngleCache[offset] + quadrant;
    referenceAngle = difference(reference.direction, angle);
    neighborAngle = difference(neighbor.direction, _opposite(angle));
  }

  /// Carrega a cache polar com valores de distância e ângulo.
  static void _load() {
    if (_isLoad) return;
    for (var y = 0; y < polarCacheRadius; y++) {
      for (var x = 0; x < polarCacheRadius; x++) {
        final index = y * polarCacheRadius + x;
        polarDistanceCache[index] = math.sqrt(x * x + y * y).round();
        polarAngleCache[index] = (y > 0 || x > 0) ? _atan(x, y) : 0.0;
      }
    }
    _isLoad = true;
  }

  /// Indica se a cache polar foi carregada.
  static bool _isLoad = false;

  /// Número de bits da cache polar.
  static const polarCacheBits = 8;

  /// Raio da cache polar.
  static const polarCacheRadius = 1 << polarCacheBits;

  /// Comprimento da cache polar.
  static const polarCacheLength = polarCacheRadius * polarCacheRadius;

  /// Cache de distâncias polares.
  static final List<int> polarDistanceCache = List<int>.generate(
    polarCacheLength,
    (_) => 0,
    growable: false,
  );

  /// Cache de ângulos polares.
  static final List<double> polarAngleCache = List<double>.generate(
    polarCacheLength,
    (_) => 0.0,
    growable: false,
  );

  /// Comprimento da aresta.
  late final int length;

  /// Ângulo de referência da aresta.
  late final double referenceAngle;

  /// Ângulo do vizinho da aresta.
  late final double neighborAngle;
}

/// Calcula o ângulo atan2 de um ponto (x, y).
///
/// - [x]: Coordenada x do ponto.
/// - [y]: Coordenada y do ponto.
/// - Retorna o ângulo em radianos.
double _atan(int x, int y) {
  final angle = math.atan2(y, x);
  return angle >= 0 ? angle : angle + pi2;
}

/// Calcula o ângulo oposto de um ângulo fornecido.
///
/// - [angle]: O ângulo original em radianos.
/// - Retorna o ângulo oposto em radianos.
double _opposite(double angle) {
  return angle < pi ? angle + pi : angle - pi;
}

/// Retorna o número de bits zero que precedem o bit de ordem mais alta
/// ("mais à esquerda") na representação binária de complemento de dois
/// do valor [int] especificado. Retorna 32 se o valor especificado não
/// tiver um bit em sua representação em complemento de dois, ou seja,
/// se for igual a zero.
///
/// - [i]: O valor inteiro a ser analisado.
/// - Retorna o número de bits zero precedentes.
int _numberOfLeadingZeros(int i) {
  if (i <= 0) return i < 0 ? 0 : 32;
  var n = 1;
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
  return n -= i >> 31;
}

const double _halfPi = 0.5 * math.pi;
