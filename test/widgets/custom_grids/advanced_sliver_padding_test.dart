import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:code_base_riverpod/core/widgets/grid/layout/grid_layout_config.dart';
import 'package:code_base_riverpod/core/widgets/grid/widgets/advanced_sliver_grid.dart';

void main() {
  testWidgets(
    'AdvancedSliverGrid builds within SliverPadding without crashes',
    (tester) async {
      final Widget widget = MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: AdvancedSliverGrid(
                  layout: const FixedGridLayout(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    return Semantics(
                      label: 'Tile $index',
                      child: Container(
                        color:
                            Colors.primaries[index % Colors.primaries.length],
                      ),
                    );
                  }, childCount: 20),
                ),
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      semantics.dispose();
    },
  );
}
