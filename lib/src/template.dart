import 'dart:typed_data';

import 'package:dartafis/src/configuration/parameters.dart';
import 'package:dartafis/src/templates/search_template.dart';

import 'package:dartafis/src/extractor/binarized_image.dart';
import 'package:dartafis/src/extractor/block_orientations.dart';
import 'package:dartafis/src/extractor/image_equalization.dart';
import 'package:dartafis/src/extractor/image_resizer.dart';
import 'package:dartafis/src/extractor/local_histograms.dart';
import 'package:dartafis/src/extractor/minutiae/minutia_collector.dart';
import 'package:dartafis/src/extractor/minutiae/top_minutiae_filter.dart';
import 'package:dartafis/src/extractor/oriented_smoothing.dart';
import 'package:dartafis/src/extractor/segmentation_mask.dart';
import 'package:dartafis/src/extractor/skeletons/skeleton_filters.dart';
import 'package:dartafis/src/extractor/skeletons/skeletons.dart';
import 'package:dartafis/src/features/skeleton.dart';
import 'package:dartafis/src/finger_image.dart';
import 'package:dartafis/src/primitives/block_map.dart';

@pragma('vm:align-loops')
@pragma('vm:unsafe:no-interrupts')
Future<SearchTemplate> featureExtract(FingerImage image) async {
  final raw = imageResizer(image.matrix, 500);
  final blocks = BlockMap(raw.width, raw.height, blockSize);
  final histogram = histogramCreate(blocks, raw);
  final smoothHistogram = histogramSmooth(blocks, histogram);
  final mask = segmentationMask(blocks, histogram);
  final equalized = equalize(blocks, raw, smoothHistogram, mask);
  final orientation = blockCompute(equalized, mask, blocks);
  final smoothed = parallel(equalized, orientation, mask, blocks);
  final orthogonal_ = orthogonal(smoothed, orientation, mask, blocks);
  final binary = binarize(smoothed, orthogonal_, mask, blocks);
  final pixelMask = pixelwise(mask, blocks);
  cleanup(binary, pixelMask);
  final inverted = invert(binary, pixelMask);
  final innerMask = inner(pixelMask);
  final ridges = skeletonCreate(binary, SkeletonType.ridges);
  final valleys = skeletonCreate(inverted, SkeletonType.valleys);
  var template = (
    width: raw.width,
    height: raw.height,
    minutiae: collect(ridges, valleys),
  );
  innerMinutiaeFilter(template.minutiae, innerMask);
  minutiaCloudFilter(template.minutiae);
  return SearchTemplate((
    width: template.width,
    height: template.height,
    minutiae: topMinutiaeFilter(template.minutiae),
  ));
}

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
Future<SearchTemplate> fromIsoFmd(Uint8List fmd) async {
  int decode(int value, double dpi) => (value / dpi * 500).round();
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
    final widthX = decode(width, resolutionX);
    final heigthY = decode(heigth, resolutionY);
    final minutiae = List<FeatureMinutia>.generate(minCount, (i) {
      final ii = i * 6;
      final byteX = fmd.buffer.asByteData(28 + ii, 2).getUint16(0);
      final type = byteX >> 14;
      final byteY = fmd.buffer.asByteData(30 + ii, 2).getUint16(0);
      final angle = fmd.buffer.asByteData(32 + ii, 1).getUint8(0);
      final position = (
        x: decode(byteX & 0x3fff, resolutionX),
        y: decode(byteY, resolutionY),
      );
      return (
        x: position.x,
        y: position.y,
        direction: complementary(angle / 256 * pi2),
        type: type == 1 ? MinutiaType.ending : MinutiaType.bifurcation,
      );
    });
    return SearchTemplate((width: widthX, height: heigthY, minutiae: minutiae));
  } catch (e) {
    rethrow;
  }
}
