import 'dart:async';
import 'dart:io';

import 'package:dartafis/src/features/indexed_edge.dart';
import 'package:dartafis/src/matcher/edge_hashes.dart';
import 'package:dartafis/src/matcher/matcher_engine.dart';
import 'package:dartafis/src/templates/search_template.dart';

/// Uma classe que fornece funcionalidade para busca e correspondência
/// de padrões.
///
/// A classe `SearchMatcher` é projetada para lidar com várias operações
/// de busca e correspondência. Pode ser usada para encontrar padrões
/// específicos dentro de uma entrada fornecida e realizar ações com base
/// nas correspondências encontradas.
///
/// Exemplo de uso:
/// ```dart
/// final matcher = SearchMatcher();
/// // Use matcher para realizar operações de busca
/// ```
///
/// Nota: Esta classe faz parte da biblioteca `dartafis`.
final class SearchMatcher {
  /// Cria um [SearchMatcher] com o [probe] fornecido.
  ///
  /// O parâmetro [probe] é um [SearchTemplate] que será usado
  /// para inicializar o matcher.
  SearchMatcher(this.search) : hash = build(search);

  /// Um template usado para realizar operações de busca.
  final SearchTemplate search;

  /// Um mapa que associa uma chave inteira a uma lista de
  /// objetos `IndexedEdge`.
  ///
  /// A chave inteira representa um identificador único, e a lista contém
  /// objetos `IndexedEdge` que estão associados a esse identificador.
  final Map<int, List<IndexedEdge>> hash;

  /// Faz a correspondência do [SearchTemplate] candidato e retorna um
  /// [Future] que completa com um valor double representando a pontuação
  /// da correspondência.
  ///
  /// A pontuação da correspondência é uma medida de quão bem o candidato
  /// corresponde ao template de busca.
  ///
  /// [candidate]: O template de busca a ser correspondido.
  ///
  /// Retorna um [Future<double>] que completa com a pontuação da
  /// correspondência.
  @pragma('vm:align-loops')
  @pragma('vm:unsafe:no-interrupts')
  Future<double> match(SearchTemplate candidate) async {
    try {
      return await findMatch(this, candidate);
    } catch (e) {
      stderr.writeln('Erro ao fazer o match: $e');
      return 0;
    }
  }
}
