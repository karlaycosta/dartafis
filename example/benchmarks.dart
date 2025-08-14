const file = 'C:/Users/karla/Documents/Dart - projetos/dartafis/probe.bmp';
Future<void> main(List<String> args) async {
  const dynamic a = 'ok';
  switch (a) {
    case bool a:
      print(a);
    case String b:
      print(b);
      print(a);
      break;
    case int a:
      print(a);
    default:
      print('fim');
  }
  print('Teste ....');
  // final bytes = await File(file).readAsBytes();
  // final sw = Stopwatch()..start();
  // final matrix = FingerImage(
  //   width: 388, //256,
  //   height: 374, // 288,
  //   bytes: bytes.buffer.asUint8List(1162),
  // );
  // for (var i = 0; i < 10; i++) {
  //   await featureExtract(matrix);
  // }

  // final usPerIteration = sw.elapsedMicroseconds / 10;
  // stdout.writeln('Media: ${usPerIteration.round()} us');
}
