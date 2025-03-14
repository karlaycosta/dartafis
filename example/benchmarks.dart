import 'dart:io';

import 'package:dartafis/dartafis.dart';

const file = 'C:/Users/karla/Documents/Dart - projetos/dartafis/probe.bmp';
Future<void> main(List<String> args) async {
  final bytes = await File(file).readAsBytes();
  final sw = Stopwatch()..start();
  final matrix = FingerImage(
    width: 388, //256,
    height: 374, // 288,
    bytes: bytes.buffer.asUint8List(1162),
  );
  for (var i = 0; i < 10; i++) {
    await featureExtract(matrix);
  }

  final usPerIteration = sw.elapsedMicroseconds / 10;
  stdout.writeln('Media: ${usPerIteration.round()} us');
}
