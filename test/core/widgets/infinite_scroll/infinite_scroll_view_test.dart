import 'package:code_base_riverpod/core/widgets/infinite_scroll/infinite_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('InfiniteScrollView builds items with stable keys', (
    tester,
  ) async {
    final controller = PaginationController<int>(
      autoStart: false,
      pageSize: 5,
      loadPage: ({required int page, required int pageSize}) async {
        return List.generate(
          pageSize,
          (index) => (page - 1) * pageSize + index,
        );
      },
    );

    await controller.refresh();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfiniteScrollView<int>(
            controller: controller,
            layout: InfiniteScrollLayout.list,
            itemKeyBuilder: (item, index) => ValueKey('item-$item'),
            itemBuilder: (context, index, item) =>
                ListTile(title: Text('Item $item')),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('item-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('item-4')), findsOneWidget);

    controller.dispose();
  });
}
