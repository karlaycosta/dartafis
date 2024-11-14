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

/// Calcula o quadrado de um valor inteiro.
///
/// - [value]: O valor a ser elevado ao quadrado.
/// - Retorna o quadrado do valor fornecido.
int _sq(int value) => value * value;

/// Constrói uma tabela de arestas vizinhas a partir de uma lista de minúcias.
///
/// - [minutiae]: Lista de minúcias.
/// - Retorna uma lista de listas de `NeighborEdge`, onde cada lista interna
///   representa as arestas vizinhas de uma minúcia de referência.
List<List<NeighborEdge>> buildTable(List<FeatureMinutia> minutiae) {
  final edges = List<List<NeighborEdge>>.generate(
    minutiae.length,
    (_) => [],
    growable: false,
  );
  final allSqDistances = List<int>.generate(
    minutiae.length,
    (_) => 0,
    growable: false,
  );
  final star = <NeighborEdge>[];

  for (var reference = 0; reference < edges.length; ++reference) {
    final rminutia = minutiae[reference];
    var maxSqDistance = 0x7fffffffffffffff;

    if (minutiae.length - 1 > edgeTableNeighbors) {
      for (var neighbor = 0; neighbor < minutiae.length; ++neighbor) {
        final nminutia = minutiae[neighbor];
        allSqDistances[neighbor] =
            _sq(rminutia.x - nminutia.x) + _sq(rminutia.y - nminutia.y);
      }
      allSqDistances.sort();
      maxSqDistance = allSqDistances[edgeTableNeighbors];
    }

    for (var neighbor = 0; neighbor < minutiae.length; ++neighbor) {
      if (neighbor != reference) {
        final nminutia = minutiae[neighbor];
        final sqDistance =
            _sq(rminutia.x - nminutia.x) + _sq(rminutia.y - nminutia.y);
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
