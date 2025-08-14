import 'dart:io';

import 'package:dartafis/src/finger_image.dart';
import 'package:dartafis/src/template.dart';

const file = 'C:/Users/karla/Documents/Dart - projetos/dartafis/probe.bmp';
// const file = 'C:/Users/karla/Documents/Dart - projetos/dartafis/01.bmp';
List<int> intToListHex(int value) {
  final head = [0, 0, 0, 0];
  head[0] = (value & 0xFF);
  value = value >> 8;
  head[1] = (value & 0xFF);
  value = value >> 8;
  head[2] = (value & 0xFF);
  value = value >> 8;
  head[3] = (value & 0xFF);
  print(head.map((e) => '0x${e.toRadixString(16).padLeft(2, '0')}'));
  return head;
}

int listHexToint(List<int> values) {
  if (values.length != 4) {
    throw ArgumentError('A lista deve conter 4 elementos!');
  }
  int value = 0;
  value += values[0] & 0xff;
  value += values[1] << 8;
  value += values[2] << 16;
  value += values[3] << 24;
  return value;
}

void main() async {
  // print(intToListHex(37942));
  // print(listHexToint([0x36, 0x04, 0x00, 0x00]));
  // print(listHexToint([0x36, 0x94, 0x00, 0x00]));

  final bytes = await File(file).readAsBytes();

  final sw = Stopwatch()..start();

  final matrix = FingerImage(
    width: 388, //256,
    height: 374, // 288,
    bytes: bytes.buffer.asUint8List(1162),
  );
  await featureExtract(matrix);
  // final raw = imageResizer(matrix.matrix, 500);
  // final blocks = BlockMap(raw.width, raw.height, blockSize);
  // final histogram = histogramCreate(blocks, raw);
  // final smoothHistogram = histogramSmooth(blocks, histogram);
  // final mask = segmentationMask(blocks, histogram);
  // final equalized = equalize(blocks, raw, smoothHistogram, mask);
  // final orientation = blockCompute(equalized, mask, blocks);
  // final smoothed = parallel(equalized, orientation, mask, blocks);
  // final orthogonal_ = orthogonal(smoothed, orientation, mask, blocks);
  // final binary = binarize(smoothed, orthogonal_, mask, blocks);
  // final pixelMask = pixelwise(mask, blocks);
  // cleanup(binary, pixelMask);
  // final inverted = invert(binary, pixelMask);
  // final innerMask = inner(pixelMask);
  // final ridges = skeletonCreate(binary, SkeletonType.ridges);
  // final valleys = skeletonCreate(inverted, SkeletonType.valleys);
  // var template = (
  //   width: raw.width,
  //   height: raw.height,
  //   minutiae: collect(ridges, valleys),
  // );
  // innerMinutiaeFilter(template.minutiae, innerMask);
  // minutiaCloudFilter(template.minutiae);
  // template = (
  //   width: template.width,
  //   height: template.height,
  //   minutiae: topMinutiaeFilter(template.minutiae)
  // );
  stdout.writeln('${sw.elapsedMilliseconds}');

  // for (var yi = 0; yi < 13; yi++) {
  //   for (var xi = 0; xi < 13; xi++) {
  //     print('[$xi, $yi]');
  //   }
  // }
  // final sw = Stopwatch()..start();
  // // final point = IntPoint(13, 13);
  // // final list = List<int>.filled(13 * 13, 0);
  // final list = Uint8List(13 * 13);
  // for (var i = 0; i < 10; i++) {
  //   // for (final element in list) {
  //   //   final a = element;
  //   // }
  //   final length = list.length;
  //   for (var i = 0; i < length; i++) {
  //     final a = list[i];
  //   }
  //   // for (var x = 0; x < 13; x++) {
  //   //   for (var y = 0; y < 13; y++) {
  //   //     // stdout.writeln(IntPoint(x, y));
  //   //     final a = IntPoint(x, y);
  //   //   }
  //   // }
  // }
  // final usPerIteration = sw.elapsedMicroseconds / 10;
  // stdout.writeln('Media: ${usPerIteration.round()} us');
}
