import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/edge_shape.dart';
import 'package:dartafis/src/features/indexed_edge.dart';
import 'package:dartafis/src/templates/search_template.dart';

final double _complementaryMaxAngleError = complementary(maxAngleError);
final int _angleBins = (pi2 / maxAngleError).ceil();

/// Calcula o hash de uma aresta (`EdgeShape`).
///
/// O hash é calculado com base no comprimento da aresta e nos ângulos
/// de referência
/// e do vizinho, divididos em bins.
///
/// - [edge]: A aresta para a qual o hash será calculado.
/// - Retorna um inteiro representando o hash da aresta.
int hash(EdgeShape edge) {
  final lengthBin = edge.length ~/ maxDistanceError;
  final referenceAngleBin = edge.referenceAngle ~/ maxAngleError;
  final neighborAngleBin = edge.neighborAngle ~/ maxAngleError;
  return (referenceAngleBin << 24) + (neighborAngleBin << 16) + lengthBin;
}

/// Verifica se duas arestas (`EdgeShape`) são correspondentes.
///
/// A correspondência é determinada com base nas diferenças de comprimento
/// e ângulos entre as arestas de referência e do vizinho.
///
/// - [probe]: A aresta de referência.
/// - [candidate]: A aresta candidata.
/// - Retorna `true` se as arestas corresponderem, caso contrário, `false`.
bool matching(EdgeShape probe, EdgeShape candidate) {
  final lengthDelta = (probe.length - candidate.length).abs();
  if (lengthDelta > maxDistanceError) return false;

  final referenceDelta =
      difference(probe.referenceAngle, candidate.referenceAngle);
  if (referenceDelta > maxAngleError &&
      referenceDelta < _complementaryMaxAngleError) {
    return false;
  }

  final neighborDelta =
      difference(probe.neighborAngle, candidate.neighborAngle);
  return neighborDelta <= maxAngleError ||
      neighborDelta >= _complementaryMaxAngleError;
}

/// Adiciona um delta a um ângulo, garantindo que o resultado esteja no
/// intervalo [0, 2*pi].
///
/// - [start]: O ângulo inicial.
/// - [delta]: O delta a ser adicionado.
/// - Retorna o ângulo resultante.
double _add(double start, double delta) {
  final angle = start + delta;
  return angle < pi2 ? angle : angle - pi2;
}

/// Calcula a cobertura de bins de uma aresta (`EdgeShape`).
///
/// A cobertura é determinada com base nos comprimentos e ângulos de
/// referência e do vizinho, divididos em bins.
///
/// - [edge]: A aresta para a qual a cobertura será calculada.
/// - Retorna um conjunto de inteiros representando os bins cobertos
/// pela aresta.
Set<int> _coverage(EdgeShape edge) {
  final minLengthBin = (edge.length - maxDistanceError) ~/ maxDistanceError;
  final maxLengthBin = (edge.length + maxDistanceError) ~/ maxDistanceError;
  final minReferenceBin =
      difference(edge.referenceAngle, maxAngleError) ~/ maxAngleError;
  final maxReferenceBin =
      _add(edge.referenceAngle, maxAngleError) ~/ maxAngleError;
  final endReferenceBin = (maxReferenceBin + 1) % _angleBins;
  final minNeighborBin =
      difference(edge.neighborAngle, maxAngleError) ~/ maxAngleError;
  final maxNeighborBin =
      _add(edge.neighborAngle, maxAngleError) ~/ maxAngleError;
  final endNeighborBin = (maxNeighborBin + 1) % _angleBins;

  final coverage = <int>{};
  for (var lengthBin = minLengthBin; lengthBin <= maxLengthBin; lengthBin++) {
    for (var referenceBin = minReferenceBin;
        referenceBin != endReferenceBin;
        referenceBin = (referenceBin + 1) % _angleBins) {
      for (var neighborBin = minNeighborBin;
          neighborBin != endNeighborBin;
          neighborBin = (neighborBin + 1) % _angleBins) {
        coverage.add((referenceBin << 24) + (neighborBin << 16) + lengthBin);
      }
    }
  }
  return coverage;
}

/// Constrói um mapa de arestas indexadas (`IndexedEdge`) a partir de um
/// template de busca (`SearchTemplate`).
///
/// O mapa é construído com base nos hashes das arestas, onde cada hash é
/// associado a uma lista de arestas indexadas.
///
/// - [template]: O template de busca a partir do qual o mapa será construído.
/// - Retorna um mapa onde as chaves são inteiros representando os hashes das
/// arestas e os valores são listas de arestas indexadas.
Map<int, List<IndexedEdge>> build(SearchTemplate template) {
  final map = <int, List<IndexedEdge>>{};
  final length = template.minutiae.length; // Cache for
  for (var reference = 0; reference < length; reference++) {
    for (var neighbor = 0; neighbor < length; neighbor++) {
      if (reference == neighbor) continue;

      final edge = IndexedEdge(template.minutiae, reference, neighbor);
      for (final hash in _coverage(edge)) {
        map.putIfAbsent(hash, () => []).add(edge);
      }
    }
  }
  return map;
}
