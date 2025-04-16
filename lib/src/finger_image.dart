import 'dart:typed_data';

import 'package:dartafis/src/primitives/double_matrix.dart';

final class FingerImage {
  final DoubleMatrix matrix;
  final int dpi;

  FingerImage._(this.matrix, this.dpi);

  factory FingerImage({
    required int width,
    required int height,
    required Uint8List bytes,
    int dpi = 500,
  }) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Width e height não podem ser negativos!');
    }

    final length = bytes.length;

    if (length != width * height) {
      throw ArgumentError(
        'A quantidade de bytes[${bytes.length}] da imagem não confere (width * height)!',
      );
    }

    final list = Float64List(length);
    for (int i = 0; i < length; i++) {
      list[i] = 1 - bytes[i] / 255;
    }
    return FingerImage._(
      DoubleMatrix(width: width, height: height, cells: list),
      dpi,
    );
  }
}
