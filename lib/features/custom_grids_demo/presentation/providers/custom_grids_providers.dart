import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/infinite_scroll/pagination_controller.dart';
import '../../../infinity_scroll/presentation/screens/media_gallery_example.dart';
import '../../data/grid_demo_repository.dart';

final gridDemoRepositoryProvider = Provider<GridDemoRepository>((ref) {
  return const GridDemoRepository();
});

final customGridPaginationControllerProvider =
    AutoDisposeChangeNotifierProvider<PaginationController<MediaItem>>((ref) {
      final repository = ref.watch(gridDemoRepositoryProvider);
      final controller = PaginationController<MediaItem>(
        pageSize: 24,
        preloadFraction: 0.72,
        debounceDuration: const Duration(milliseconds: 280),
        loadPage: ({required int page, required int pageSize}) =>
            repository.fetchPage(page: page, pageSize: pageSize),
        onPageLoaded: repository.prefetchThumbnails,
        hasMoreResolver: (_) => true,
      );
      ref.onDispose(controller.dispose);
      return controller;
    });
