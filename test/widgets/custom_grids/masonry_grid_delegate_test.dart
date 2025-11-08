import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:code_base_riverpod/core/widgets/custom_grids/custom_grids.dart';

void main() {
  group('HyperMasonryGridDelegate', () {
    test('assigns items to lowest column first', () {
      final delegate = HyperMasonryGridDelegate(
        columnCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        sizeEstimator: (index) => 120 + (index % 3) * 30,
      );

      final layout = delegate.getLayout(_testConstraints(crossAxisExtent: 360));

      final tile0 = layout.getGeometryForChildIndex(0);
      final tile1 = layout.getGeometryForChildIndex(1);
      final tile2 = layout.getGeometryForChildIndex(2);
      final tile3 = layout.getGeometryForChildIndex(3);

      expect(tile0.scrollOffset, closeTo(12, 0.001));
      expect(tile1.scrollOffset, closeTo(12, 0.001));
      expect(tile2.scrollOffset, closeTo(12, 0.001));
      expect(tile3.scrollOffset, greaterThan(tile0.scrollOffset));
      expect(
        layout.computeMaxScrollOffset(6),
        greaterThan(tile2.scrollOffset + tile2.mainAxisExtent),
      );
    });
  });
}

SliverConstraints _testConstraints({required double crossAxisExtent}) {
  return SliverConstraints(
    axisDirection: AxisDirection.down,
    crossAxisDirection: AxisDirection.right,
    growthDirection: GrowthDirection.forward,
    userScrollDirection: ScrollDirection.idle,
    scrollOffset: 0,
    precedingScrollExtent: 0,
    overlap: 0,
    remainingPaintExtent: 600,
    crossAxisExtent: crossAxisExtent,
    viewportMainAxisExtent: 600,
    remainingCacheExtent: 600,
    cacheOrigin: 0,
  );
}
