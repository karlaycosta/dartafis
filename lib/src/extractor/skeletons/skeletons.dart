import 'dart:io';
import 'dart:typed_data';

import 'package:dartafis/src/extractor/skeletons/binary_thinning.dart';
import 'package:dartafis/src/extractor/skeletons/skeleton_filters.dart';
import 'package:dartafis/src/extractor/skeletons/skeleton_tracing.dart';
import 'package:dartafis/src/features/skeleton.dart';
import 'package:dartafis/src/primitives/boolean_matrix.dart';

Skeleton skeletonCreate(BooleanMatrix binary, SkeletonType type) {
  final thinned = thin(binary, type);
  // save(thinned);
  final skeleton = trace(thinned, type);
  skeletonFilters(skeleton);
  return skeleton;
}

BooleanMatrix thinCreate(BooleanMatrix binary, SkeletonType type) {
  return thin(binary, type);
}

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

Future<void> save(BooleanMatrix data) async {
  final width = data.width;
  final height = data.height;
  final size = width * height + 1078;
  final header = <int>[
    0x42, 0x4d, //file type
    // 0x36, 0x94, 0x00, 0x00, //file size*** 37942
    ...intToListHex(size),
    0x00, 0x00, 0x00, 0x00, //reserved
    0x36, 0x04, 0x00, 0x00, //head byte***
    //infoheader
    0x28, 0x00, 0x00, 0x00, //struct size
    ...intToListHex(width),
    ...intToListHex(height),
    0x01, 0x00, //must be 1
    0x08, 0x00, //color count
    0x00, 0x00, 0x00, 0x00, //compression
    // 0x00, 0x94, 0x00, 0x00, //data size*** 37632
    0x00, 0x00, 0x00, 0x00, //data size*** 37632
    0x00, 0x00, 0x00, 0x00, //dpix
    0x00, 0x00, 0x00, 0x00, //dpiy
    0x00, 0x01, 0x00, 0x00, //color used
    0x00, 0x00, 0x00, 0x00, //color important
  ];

  final bmp = Uint8List(size);

  bmp.buffer.asUint8List().setAll(0, header);

  int j = 0;
  for (int i = 54; i < 1078; i += 4) {
    bmp[i] = bmp[i + 1] = bmp[i + 2] = j;
    bmp[i + 3] = 0;
    j++;
  }

  bmp.buffer.asUint8List(1078).setAll(0, data.cells.map((e) => e ? 0 : 255));
  File('data.bmp').writeAsBytesSync(bmp);
}
