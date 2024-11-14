import 'dart:io';

import 'package:dartafis/dartafis.dart';

Future<void> main() async {
  final fmd = await File(
    'C:/Users/karla/Documents/Flutter - projetos/acesso_ifpa_admin/image/fmd1.dat',
  ).readAsBytes();
  final fmd2 = await File(
    'C:/Users/karla/Documents/Flutter - projetos/acesso_ifpa_admin/image/fmd2.dat',
  ).readAsBytes();
  final a = fromIsoFmd(fmd);
  final b = fromIsoFmd(fmd2);
  final matcher = SearchMatcher(a);
  for (var i = 0; i < 10; i++) {
    final stopwatch = Stopwatch()..start();
    final score = await matcher.match(b);
    stopwatch.stop();
    stdout.writeln(
      'Score ${(i + 1).toString().padLeft(2, '0')}: $score | ${stopwatch.elapsedMicroseconds}',
    );
  }

  // final probe = Matcher(Template.fromFmd(fmd));
  // probe.match(candidate);
}
