/// A classe `MinutiaPair` representa um par de minúcias utilizado no processo
/// de correspondência.
///
/// Esta classe armazena informações sobre as minúcias de referência e
/// candidatas, incluindo suas posições, distância entre elas e o número de
/// arestas de suporte.
final class MinutiaPair {
  /// Cria uma nova instância de `MinutiaPair`.
  ///
  /// Os parâmetros opcionais permitem inicializar os valores das propriedades.
  MinutiaPair({
    this.probe = 0,
    this.candidate = 0,
    this.probeRef = 0,
    this.candidateRef = 0,
    this.distance = 0,
    this.supportingEdges = 0,
  });

  /// A posição da minúcia de referência na amostra de pesquisa.
  final int probe;

  /// A posição da minúcia candidata no template de candidato.
  final int candidate;

  /// A referência da minúcia de pesquisa.
  int probeRef;

  /// A referência da minúcia candidata.
  int candidateRef;

  /// A distância entre as minúcias de referência e candidata.
  final int distance;

  /// O número de arestas de suporte entre as minúcias.
  int supportingEdges;
}
