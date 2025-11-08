import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:code_base_riverpod/core/widgets/grid/layout/grid_layout_config.dart';
import 'package:code_base_riverpod/core/widgets/grid/render/advanced_sliver_render.dart';
import 'package:code_base_riverpod/core/widgets/grid/widgets/advanced_sliver_grid.dart';

void main() {
  testWidgets('RenderSliverAdvancedGrid assigns grid parent data to children', (
    tester,
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
                    color: Colors.indigo[(index % 8 + 1) * 100],
                    child: Text('Tile $index'),
                  );
                }, childCount: 8),
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
    expect(firstChild.parentData, isA<AdvancedSliverGridParentData>());

    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pump();
    semantics.dispose();
    expect(tester.takeException(), isNull);
  });
}
