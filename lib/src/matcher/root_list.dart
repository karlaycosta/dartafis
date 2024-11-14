import 'package:dartafis/src/matcher/minutia_pair.dart';

/// A classe `RootList` gerencia uma lista de pares de minúcias e um conjunto
/// de duplicatas.
///
/// Esta classe é utilizada para armazenar e gerenciar pares de minúcias e
/// identificar duplicatas durante o processo de correspondência.
final class RootList {
  /// Uma lista de pares de minúcias.
  final List<MinutiaPair> pairs = [];
  
  /// Um conjunto de identificadores de duplicatas.
  final Set<int> duplicates = {};

  /// Limpa a lista de pares e o conjunto de duplicatas.
  void discard() {
    pairs.clear();
    duplicates.clear();
  }
}
