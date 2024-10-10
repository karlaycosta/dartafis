import 'dart:typed_data';

import 'features/search_minutia.dart';
import 'primitives/float_angle.dart';
import 'primitives/int_point.dart';
import 'templates/search_template.dart';

final class Template {
  late final SearchTemplate inner;

  Template.fromSearchTemplate(this.inner);

  int decode(int value, double dpi) => (value / dpi * 500).round();

  Template.fromFmd(Uint8List fmd) {

    final code0 = String.fromCharCode(0);
    // Verifica o cabeçalho (MAGIC + VERSION)
    if (String.fromCharCodes(fmd.buffer.asUint8List(0, 8)) !=
        'FMR$code0 20$code0') {
      throw Exception('Arquivo inválido');
    }
    final totalBytes = fmd.buffer.asByteData(8, 4).getUint32(0);
    final minCount = fmd.buffer.asByteData(27, 1).getUint8(0);
    // Verifica a integridade dos bytes
    if (28 + (minCount * 6) + 2 != totalBytes) {
      throw Exception('Arquivo corrompido');
    }
    try {
      final width = fmd.buffer.asByteData(14, 2).getUint16(0);
      final heigth = fmd.buffer.asByteData(16, 2).getUint16(0);
      final resolutionX = fmd.buffer.asByteData(18, 2).getUint16(0) * 2.54;
      final resolutionY = fmd.buffer.asByteData(20, 2).getUint16(0) * 2.54;
      final x = decode(width, resolutionX);
      final y = decode(heigth, resolutionY);
      final minutiae = <FeatureMinutia>[];
      for (int i = 0; i < minCount; i++) {
        int byteX = fmd.buffer.asByteData(28 + (i * 6), 2).getUint16(0);
        final type = byteX >> 14;
        byteX &= 0x3fff;
        final byteY = fmd.buffer.asByteData(30 + (i * 6), 2).getUint16(0);
        final angle = fmd.buffer.asByteData(32 + (i * 6), 1).getUint8(0);
        final position = IntPoint(
          decode(byteX, resolutionX),
          decode(byteY, resolutionY),
        );
        minutiae.add((
          position: position,
          direction: FloatAngle.complementary(angle / 256 * FloatAngle.pi2),
          type: type == 1 ? MinutiaType.ending : MinutiaType.bifurcation,
        ));
      }
      final feature =
          (size: IntPoint(x, y), minutiae: minutiae);
      inner = SearchTemplate(feature);
    } catch (e) {
      rethrow;
    }
  }
}
