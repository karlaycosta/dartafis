import 'dart:typed_data';

import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/templates/search_template.dart';

int _decode(int value, double dpi) => (value / dpi * 500).round();

/// Cria um [SearchTemplate] a partir do ISO FMD (Finger Minutiae Data) 
/// fornecido.
/// 
/// O parâmetro [fmd] é um [Uint8List] contendo os dados do ISO FMD.
/// 
/// Retorna um objeto [SearchTemplate] criado a partir do FMD fornecido.
/// 
/// Exemplo:
/// ```dart
/// Uint8List fmdData = ...; // seus dados ISO FMD
/// SearchTemplate template = fromIsoFmd(fmdData);
/// ```
SearchTemplate fromIsoFmd(Uint8List fmd) {
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
    final x = _decode(width, resolutionX);
    final y = _decode(heigth, resolutionY);
    final minutiae = List<FeatureMinutia>.generate(minCount, (i) {
      final byteX = fmd.buffer.asByteData(28 + (i * 6), 2).getUint16(0);
      final type = byteX >> 14;
      final byteY = fmd.buffer.asByteData(30 + (i * 6), 2).getUint16(0);
      final angle = fmd.buffer.asByteData(32 + (i * 6), 1).getUint8(0);
      final position = (
        x: _decode(byteX & 0x3fff, resolutionX),
        y: _decode(byteY, resolutionY),
      );
      return (
        x: position.x,
        y: position.y,
        direction: complementary(angle / 256 * pi2),
        type: type == 1 ? MinutiaType.ending : MinutiaType.bifurcation,
      );
    });
    return SearchTemplate((x: x, y: y, minutiae: minutiae));
  } catch (e) {
    rethrow;
  }
}
