import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/edge_shape.dart';

/// A classe `IndexedEdge` representa uma aresta indexada entre duas minúcias.
///
/// Esta classe estende a classe `EdgeShape` e adiciona propriedades para
/// armazenar os índices das minúcias de referência e vizinha.
final class IndexedEdge extends EdgeShape {
  /// Cria uma instância de `IndexedEdge`.
  ///
  /// - [minutiae]: Lista de minúcias.
  /// - [_reference]: Índice da minúcia de referência.
  /// - [_neighbor]: Índice da minúcia vizinha.
  IndexedEdge(List<FeatureMinutia> minutiae, this._reference, this._neighbor)
      : super(minutiae[_reference], minutiae[_neighbor]);

  /// Índice da minúcia de referência.
  final int _reference;

  /// Índice da minúcia vizinha.
  final int _neighbor;

  /// Retorna o índice da minúcia de referência como um valor sem sinal de
  /// 8 bits.
  int get reference => _reference.toUnsigned(8);

  /// Retorna o índice da minúcia vizinha como um valor sem sinal de 8 bits.
  int get neighbor => _neighbor.toUnsigned(8);
}
