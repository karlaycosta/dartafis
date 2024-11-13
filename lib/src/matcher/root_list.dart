import 'minutia_pair.dart';

final class RootList {
  final List<MinutiaPair> pairs = [];
  final Set<int> duplicates = {};

  void discard() {
    pairs.clear();
    duplicates.clear();
  }
}
