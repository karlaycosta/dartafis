import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/neighbor_edge.dart';

/// Um typedef para um template de característica que contém as seguintes
/// propriedades:
///
/// - `width` (int): A largura da característica.
/// - `height` (int): A altura da característica.
/// - `minutiae` (List`<FeatureMinutia>`): Uma lista de minúcias associadas
///   à característica.
typedef FeatureTemplate = ({
  int width,
  int height,
  List<FeatureMinutia> minutiae,
});

/// Uma classe template para funcionalidade de busca.
///
/// Esta classe é destinada a ser usada como base para implementar recursos
/// relacionados à busca em sua aplicação. Ela fornece uma estrutura e
/// funcionalidade comum que pode ser estendida e personalizada conforme
/// necessário.
final class SearchTemplate {
  /// Um construtor factory para criar uma instância de [SearchTemplate].
  ///
  /// Este construtor recebe um objeto [FeatureTemplate] como parâmetro
  /// e retorna uma instância de [SearchTemplate].
  ///
  /// - Parâmetro [features]: Uma instância de [FeatureTemplate] que contém
  ///   as características necessárias para criar um [SearchTemplate].
  factory SearchTemplate(FeatureTemplate features) {
    final minutiae = features.minutiae;
    // final keys = <FeatureMinutia, int>{
    //   for (final m in minutiae) m: ((m.x * 161) + m.y) * 161, // 1610612741
    // };

    // minutiae.sort((a, b) {
    //   final keyA = keys[a]!;
    //   final keyB = keys[b]!;

    //   // var result = keyA.compareTo(keyB);
    //   // if (result != 0) return result;

    //   // result = a.x.compareTo(b.x);
    //   // if (result != 0) return result;

    //   // result = a.y.compareTo(b.y);
    //   // if (result != 0) return result;

    //   // result = a.direction.compareTo(b.direction);
    //   // if (result != 0) return result;

    //   // return a.type.index.compareTo(b.type.index);
    //   return keyA.compareTo(keyB);
    // });
    final edges = buildTable(minutiae);
    return SearchTemplate._(features.width, features.height, minutiae, edges);
  }
  const SearchTemplate._(this.width, this.height, this.minutiae, this.edges);

  /// A largura do template de busca.
  ///
  /// Este valor determina a largura do template em pixels.
  final int width;

  /// A altura do template de busca.
  ///
  /// Este valor representa a altura em pixels.
  final int height;

  /// Uma lista de objetos `FeatureMinutia` representando os pontos de minúcias
  /// em uma impressão digital ou outro conjunto de características biométricas.
  final List<FeatureMinutia> minutiae;

  /// Uma lista de listas contendo objetos `NeighborEdge`.
  ///
  /// Cada lista interna representa uma coleção de arestas associadas a um
  /// vizinho específico.
  final List<List<NeighborEdge>> edges;
}
