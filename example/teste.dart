import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/features/neighbor_edge.dart';

typedef Matrix<T> = ({List<T> list, int col, int row});
// extension type Matriz<T>._(List<T> list) {
//   // final int row;
//   final int col;
//   Matriz(this.list, this.col);
// }

void teste<T>(Matrix<T> matrix) {
  final (:list, :col, :row) = matrix;
  // final row = matrix.row;
  // final column = matrix.col;
  for (var y = 0; y < row; y++) {
    for (var x = 0; x < col; x++) {
      print(matrix.list[y * col + x]);
    }
  }
}
typedef Karlay = ({int x, int y});
extension type Deriks(Karlay k) {
  int get area => k.x * k.y;
}
void main(List<String> args) {
  final Deriks r = Deriks((x: 10, y:5));
  r.area;
  final matrix = (list: [1, 2, 3, 4, 5, 6], col: 3, row: 2);
  teste(matrix);
  // final minutiaes = List<FeatureMinutia>.generate(
  //   8,
  //   (i) => (
  //     x: i,
  //     y: i,
  //     direction: i.toDouble(),
  //     type: i.isEven ? MinutiaType.ending : MinutiaType.bifurcation,
  //   ),
  // );
  // buildTable(minutiaes);
  // stdout.writeln('fim...');
}

int _sq(int value) => value * value;

List<List<NeighborEdge>> buildTable(List<FeatureMinutia> minutiae) {
  final minutiaeLength = minutiae.length;
  final edges = List<List<NeighborEdge>>.filled(minutiaeLength, []);
  final allSqDistances = List<int>.filled(minutiaeLength, 0);
  final star = <NeighborEdge>[];
  final maxNeighbors = minutiaeLength > edgeTableNeighbors
      ? edgeTableNeighbors
      : minutiaeLength - 1;
  int getMax(List<int> list) {
    final res = list.toList(growable: false)..sort();
    return res[edgeTableNeighbors];
  }
  for (var reference = 0; reference < minutiaeLength; reference++) {
    final rminutia = minutiae[reference];
    var maxSqDistance = 0x7fffffffffffffff;

    if (minutiaeLength - 1 > edgeTableNeighbors) {
      for (var neighbor = 0; neighbor < minutiaeLength; neighbor++) {
        final nminutia = minutiae[neighbor];
        allSqDistances[neighbor] =
            _sq(rminutia.x - nminutia.x) + _sq(rminutia.y - nminutia.y);
      }
      // allSqDistances.sort();
      // maxSqDistance = allSqDistances[edgeTableNeighbors];
      maxSqDistance = getMax(allSqDistances);
    }

    for (var neighbor = 0; neighbor < minutiaeLength; neighbor++) {
      if (neighbor != reference) {
        // final nminutia = minutiae[neighbor];
        // final sqDistance =
        //     _sq(rminutia.x - nminutia.x) + _sq(rminutia.y - nminutia.y);
        // if (sqDistance <= maxSqDistance) {
        if (allSqDistances[neighbor] <= maxSqDistance) {
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
  print('${edges.first.length}');
  return edges;
}
