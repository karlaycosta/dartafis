import 'package:dartafis/src/primitives/block_map.dart';
import 'package:dartafis/src/primitives/int_point.dart';
import 'package:dartafis/src/primitives/int_rect.dart';
import 'package:test/test.dart';

void main() {
  group('BlockMap', () {
    test('Construtor', () {
      final width = 400;
      final height = 600;
      final maxBlockSize = 20;

      final blockMap = BlockMap(width, height, maxBlockSize);

      expect(blockMap, isNotNull);
      expect(blockMap.primary, isNotNull);
      expect(blockMap.secondary, isNotNull);

      // expect(blockMap.pixels, equals(IntPoint(width, height)));
      expect(blockMap.width, equals(width));
      expect(blockMap.height, equals(height));

      expect(blockMap.primary.blocks, equals(IntPoint(20, 30)));
      expect(blockMap.primary.corners, equals(IntPoint(21, 31)));

      expect(blockMap.secondary.blocks, equals(IntPoint(21, 31)));
      expect(blockMap.secondary.corners, equals(IntPoint(22, 32)));

      expect(blockMap.primary.corner(0, 0), equals(IntPoint(0, 0)));
	    expect(blockMap.primary.corner(20, 30), equals(IntPoint(width, height)));
      expect(blockMap.primary.corner(10, 15), equals(IntPoint(200, 300)));
      expect(blockMap.primary.block(0, 0), equals(IntRect(0, 0, 20, 20)));
      expect(blockMap.primary.block(19, 29), equals(IntRect(380, 580, 20, 20)));
      expect(blockMap.primary.block(10, 15), equals(IntRect(200, 300, 20, 20)));

      expect(blockMap.secondary.corner(0, 0), equals(IntPoint(0, 0)));
      expect(blockMap.secondary.block(0, 0), equals(IntRect(0, 0, 10, 10)));
      expect(blockMap.secondary.block(20, 30), equals(IntRect(390, 590, 10, 10)));
      expect(blockMap.secondary.block(10, 15), equals(IntRect(190, 290, 20, 20)));
    });
  });
}