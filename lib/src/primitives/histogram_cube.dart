import 'dart:typed_data';

class HistogramCube {
  final int width;
  final int height;
  final int bins;
  final Uint16List counts;

  HistogramCube({required this.width, required this.height, required this.bins})
      : counts = Uint16List(width * height * bins);

  int constrain(int z) => z.clamp(0, bins - 1);

  int get(int x, int y, int z) => counts[(y * width + x) * bins + z];

	int sum(int x, int y) {
    final start = (y * width + x) * bins;
    final end = start + bins;
    int sum = 0;
    for (var i = start; i < end; i++) {
      sum += counts[i];
    }
		return sum;
	}

  void add(int x, int y, int z, int value) => counts[(y * width + x) * bins + z] += value;

  void increment(int x, int y, int z) => add(x, y, z, 1);

}
