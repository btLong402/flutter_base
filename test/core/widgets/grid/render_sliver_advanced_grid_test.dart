import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:code_base_riverpod/core/widgets/grid/layout/grid_layout_config.dart';
import 'package:code_base_riverpod/core/widgets/grid/render/advanced_sliver_render.dart';
import 'package:code_base_riverpod/core/widgets/grid/widgets/advanced_sliver_grid.dart';

void main() {
  testWidgets('RenderSliverAdvancedGrid coerces parent data before layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              AdvancedSliverGrid(
                layout: const FixedGridLayout(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate((
                  BuildContext context,
                  int index,
                ) {
                  return Container(
                    height: 72,
                    alignment: Alignment.center,
                    color: Colors.primaries[index % Colors.primaries.length],
                    child: Text('Item $index'),
                  );
                }, childCount: 6),
              ),
            ],
          ),
        ),
      ),
    );

    final RenderSliverAdvancedGrid renderObject =
        tester.renderObject(find.byType(AdvancedSliverGrid))
            as RenderSliverAdvancedGrid;
    final RenderBox firstChild = renderObject.firstChild!;

    final SliverMultiBoxAdaptorParentData originalParentData =
        SliverMultiBoxAdaptorParentData()
          ..index = 0
          ..layoutOffset = 0;
    firstChild.parentData = originalParentData;
    renderObject.setupParentData(firstChild);

    expect(firstChild.parentData, isA<AdvancedSliverGridParentData>());

    renderObject.markNeedsLayout();
    await tester.pump();

    expect(renderObject.geometry, isNotNull);
    expect(renderObject.geometry!.scrollExtent, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
