import 'dart:io';

import 'package:dartafis/dartafis.dart';

Future<void> main() async {
  final fmd = await File(
    'C:/Users/karla/Documents/Flutter - projetos/acesso_ifpa_admin/image/fmd1.dat',
    // 'image_joao_01.fmd',
  ).readAsBytes();
  final fmd2 = await File(
    'C:/Users/karla/Documents/Flutter - projetos/acesso_ifpa_admin/image/fmd2.dat',
    // 'image_joao_02.fmd',
  ).readAsBytes();

  // final sw = Stopwatch()..start();


  // for (var i = 0; i < 10; i++) {
  //   final _ = fromIsoFmd(fmd);
  // }
  // final usPerIteration = sw.elapsedMicroseconds / 10;
  // stdout.writeln('Media: ${usPerIteration.round()} us');

  final a = await fromIsoFmd(fmd);
  final b = await fromIsoFmd(fmd2);
  final matcher = SearchMatcher(a);
  final sw = Stopwatch()..start();
  for (var i = 0; i < 10; i++) {
    final stopwatch = Stopwatch()..start();
    final score = await matcher.match(b);
    stopwatch.stop();
    stdout.writeln(
      'Score ${(i + 1).toString().padLeft(2, '0')}: $score | ${stopwatch.elapsedMicroseconds}',
    );
  }
  final usPerIteration = sw.elapsedMicroseconds / 10;
  stdout.writeln('Media: ${usPerIteration.round()} us');
  // final probe = Matcher(Template.fromFmd(fmd));
  // probe.match(candidate);
}
