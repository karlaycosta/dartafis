import 'minutia_pair.dart';

final class RootList {
  final List<MinutiaPair> pairs = [];
  final duplicates = <int>{};

  void discard() {
    pairs.clear();
    duplicates.clear();
  }
}
