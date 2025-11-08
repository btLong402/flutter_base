import 'package:flutter_test/flutter_test.dart';

import 'package:code_base_riverpod/core/widgets/infinite_scroll/pagination_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PaginationController', () {
    test('refresh loads first page and resets state', () async {
      var requestedPage = 0;
      final controller = PaginationController<int>(
        autoStart: false,
        pageSize: 3,
        loadPage: ({required int page, required int pageSize}) async {
          requestedPage = page;
          return List.generate(
            pageSize,
            (index) => (page - 1) * pageSize + index,
          );
        },
      );

      await controller.refresh();

      expect(requestedPage, 1);
      expect(controller.itemCount, 3);
      expect(controller.items.first, 0);
      expect(controller.hasMore, isTrue);
      controller.dispose();
    });

    test('loadMore appends items while keeping previous pages', () async {
      final controller = PaginationController<int>(
        autoStart: false,
        pageSize: 2,
        keepPagesInMemory: 4,
        loadPage: ({required int page, required int pageSize}) async {
          return List.generate(
            pageSize,
            (index) => (page - 1) * pageSize + index,
          );
        },
      );

      await controller.refresh();
      await controller.loadMore();

      expect(controller.itemCount, 4);
      expect(controller.items, [0, 1, 2, 3]);
      expect(controller.hasMore, isTrue);
      controller.dispose();
    });

    test('retry replays failed request', () async {
      var shouldFail = true;
      final controller = PaginationController<int>(
        autoStart: false,
        pageSize: 2,
        loadPage: ({required int page, required int pageSize}) async {
          if (page == 2 && shouldFail) {
            throw Exception('network');
          }
          return List.generate(
            pageSize,
            (index) => (page - 1) * pageSize + index,
          );
        },
      );

      await controller.refresh();
      expect(controller.itemCount, 2);

      await controller.loadMore();
      expect(controller.error, isNotNull);
      expect(controller.itemCount, 2);

      shouldFail = false;
      await controller.retry();

      expect(controller.error, isNull);
      expect(controller.itemCount, 4);
      controller.dispose();
    });
  });
}
