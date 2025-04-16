import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/edge_shape.dart';

/// A classe `NeighborEdge` representa uma aresta entre duas minúcias vizinhas.
///
/// Esta classe estende a classe `EdgeShape` e adiciona uma propriedade
/// para armazenar o índice da minúcia vizinha.
final class NeighborEdge extends EdgeShape {
  /// Cria uma instância de `NeighborEdge`.
  ///
  /// - [minutiae]: Lista de minúcias.
  /// - [reference]: Índice da minúcia de referência.
  /// - [neighbor]: Índice da minúcia vizinha.
  NeighborEdge(List<FeatureMinutia> minutiae, int reference, this.neighbor)
    : super(minutiae[reference], minutiae[neighbor]);

  /// Índice da minúcia vizinha.
  final int neighbor;
}

/// Constrói uma tabela de arestas vizinhas a partir de uma lista de minúcias.
///
/// - [minutiae]: Lista de minúcias.
/// - Retorna uma lista de listas de `NeighborEdge`, onde cada lista interna
///   representa as arestas vizinhas de uma minúcia de referência.
List<List<NeighborEdge>> buildTable(List<FeatureMinutia> minutiae) {
  final minutiaeLength = minutiae.length; // Cache for
  final edges = List<List<NeighborEdge>>.filled(minutiaeLength, []);
  final allSqDistances = List<int>.filled(minutiaeLength, 0);
  final star = <NeighborEdge>[];
  for (var reference = 0; reference < minutiaeLength; reference++) {
    final rminutia = minutiae[reference];
    var maxSqDistance = 0x7fffffffffffffff;

    if (minutiaeLength - 1 > edgeTableNeighbors) {
      for (var neighbor = 0; neighbor < minutiaeLength; neighbor++) {
        final nminutia = minutiae[neighbor];
        allSqDistances[neighbor] =
            sq(rminutia.x - nminutia.x) + sq(rminutia.y - nminutia.y);
      }
      allSqDistances.sort();
      maxSqDistance = allSqDistances[edgeTableNeighbors];
    }

    for (var neighbor = 0; neighbor < minutiaeLength; neighbor++) {
      if (neighbor != reference) {
        final nminutia = minutiae[neighbor];
        final sqDistance =
            sq(rminutia.x - nminutia.x) + sq(rminutia.y - nminutia.y);
        if (sqDistance <= maxSqDistance) {
          star.add(NeighborEdge(minutiae, reference, neighbor));
        }
      }
    }

    star.sort((a, b) {
      final lengthCmp = a.length.compareTo(b.length);
      if (lengthCmp != 0) return lengthCmp;
      return a.neighbor.compareTo(b.neighbor);
    });

    if (star.length > edgeTableNeighbors) {
      star.removeRange(edgeTableNeighbors, star.length);
    }

    edges[reference] = star.toList();
    star.clear();
  }
  return edges;
}
