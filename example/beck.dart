import 'dart:io';
import 'dart:math';

void main(List<String> args) {
  final sw = Stopwatch()..start();
  const u = 5; //int.parse(args[0]); // Get an input number from the command line
  final r = Random().nextInt(10000); // Get a random integer 0 <= r < 10k

  final a = List.filled(10000, 0);
  for (int i = 0; i < 10000; i++) {
    a[i];
    // 10k outer loop iterations
    for (int j = 0; j < 100000; j++) {
      // 100k inner loop iterations, per outer loop iteration
      a[i] += j % u;//a[i] + j % u; // Simple sum
    }
    a[i] += r; // Add a random value to each element in array
  }
  stdout.writeln(a[r]); // Print out a single element from the array
  stdout.writeln(sw.elapsed);
}