import 'package:code_base_riverpod/core/widgets/infinite_scroll/pagination_controller.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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

    test('loadMore avoids duplicate in-flight requests', () async {
      var requestCount = 0;
      final controller = PaginationController<int>(
        autoStart: false,
        pageSize: 2,
        loadPage: ({required int page, required int pageSize}) async {
          requestCount++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return List.generate(
            pageSize,
            (index) => (page - 1) * pageSize + index,
          );
        },
      );

      await controller.refresh();
      expect(requestCount, 1);

      controller.loadMore();
      controller.loadMore();
      controller.loadMore();

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(requestCount, 2); // first page + one load more
      expect(controller.itemCount, 4);
      controller.dispose();
    });

    test('handleScrollMetrics debounces load triggers', () {
      fakeAsync((async) {
        var loadCount = 0;
        final controller = PaginationController<int>(
          autoStart: false,
          pageSize: 2,
          debounceDuration: const Duration(milliseconds: 120),
          loadPage: ({required int page, required int pageSize}) async {
            loadCount++;
            return List.generate(
              pageSize,
              (index) => (page - 1) * pageSize + index,
            );
          },
        );

        controller.refresh();
        async.elapse(const Duration(milliseconds: 10));

        final metrics = FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 1000,
          pixels: 900,
          viewportDimension: 400,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        );

        controller.handleScrollMetrics(metrics);
        controller.handleScrollMetrics(metrics);
        controller.handleScrollMetrics(metrics);

        expect(loadCount, 1); // refresh already fired first page

        async.elapse(const Duration(milliseconds: 200));

        expect(loadCount, 2); // one loadMore triggered after debounce
        controller.dispose();
      });
    });
  });
}
