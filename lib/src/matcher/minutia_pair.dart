final class MinutiaPair {
  final int probe;
  final int candidate;
  int probeRef;
  int candidateRef;
  final int distance;
  int supportingEdges;

  MinutiaPair({
    this.probe = 0,
    this.candidate = 0,
    this.probeRef = 0,
    this.candidateRef = 0,
    this.distance = 0,
    this.supportingEdges = 0,
  });
}
