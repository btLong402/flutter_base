import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:code_base_riverpod/core/widgets/custom_grids/custom_grids.dart';

void main() {
  group('HyperFixedGridDelegate', () {
    test('computes deterministic geometry', () {
      final delegate = HyperFixedGridDelegate(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: const EdgeInsets.all(8),
        mainAxisExtent: 120,
      );

      final constraints = _testConstraints(crossAxisExtent: 400);
      final layout = delegate.getLayout(constraints);

      final first = layout.getGeometryForChildIndex(0);
      final second = layout.getGeometryForChildIndex(1);
      final third = layout.getGeometryForChildIndex(2);

      expect(first.crossAxisOffset, closeTo(8, 0.001));
      expect(first.scrollOffset, closeTo(8, 0.001));
      expect(second.crossAxisOffset, greaterThan(first.crossAxisOffset));
      expect(second.scrollOffset, first.scrollOffset);
      expect(third.scrollOffset, greaterThan(first.scrollOffset));
      expect(layout.computeMaxScrollOffset(4), greaterThan(0));
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
