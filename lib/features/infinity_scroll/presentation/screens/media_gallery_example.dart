import 'dart:math';

import 'package:code_base_riverpod/core/context/context_extenstion.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_image_widget/custom_image_widget.dart';
import '../../../../core/widgets/infinite_scroll/infinite_scroll.dart';

class MediaRepository {
  const MediaRepository();

  Future<List<MediaItem>> fetch({
    required int page,
    required int pageSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final random = Random(page);
    return List.generate(pageSize, (index) {
      final id = (page - 1) * pageSize + index + 1;
      final isVideo = random.nextBool();
      return MediaItem(
        id: id,
        title: 'Memory #$id',
        isVideo: isVideo,
        previewUrl: 'https://picsum.photos/seed/media$id/600/900',
        heroTag: 'media-$id',
      );
    });
  }

  Future<void> prefetchThumbnails(List<MediaItem> items) async {
    // Hook for cached images (e.g. CachedNetworkImageProvider().resolve());
    await Future<void>.delayed(const Duration(milliseconds: 12));
  }
}

class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.isVideo,
    required this.previewUrl,
    required this.heroTag,
  });

  final int id;
  final String title;
  final bool isVideo;
  final String previewUrl;
  final String heroTag;
}

class MediaInfiniteGridExample extends StatefulWidget {
  const MediaInfiniteGridExample({super.key});

  @override
  State<MediaInfiniteGridExample> createState() =>
      _MediaInfiniteGridExampleState();
}

class _MediaInfiniteGridExampleState extends State<MediaInfiniteGridExample> {
  late final PaginationController<MediaItem> _controller;
  final MediaRepository _repository = const MediaRepository();

  @override
  void initState() {
    super.initState();
    _controller = PaginationController<MediaItem>(
      pageSize: 30,
      preloadFraction: 0.7,
      debounceDuration: const Duration(milliseconds: 260),
      keepPagesInMemory: 10,
      loadPage: ({required int page, required int pageSize}) =>
          _repository.fetch(page: page, pageSize: pageSize),
      onPageLoaded: _repository.prefetchThumbnails,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InfiniteScrollView<MediaItem>(
      controller: _controller,
      useSlivers: true,
      layout: InfiniteScrollLayout.grid,
      sliverAppBar: SliverAppBar(
        pinned: true,
        floating: false,
        title: const Text('Memories'),
        expandedHeight: 120,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '5,000+ media items with thumbnail caching and smooth scrolling.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index, item) {
        return _MediaTile(item: item);
      },
      semanticsLabelBuilder: (item, index) => item.title,
      loadingBuilder: (context) => const _GalleryLoading(),
      emptyBuilder: (context) => const _GalleryEmptyState(),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Hero(
      tag: item.heroTag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: CustomImageWidget(
                source: CustomImageSource.network(item.previewUrl),
                fit: BoxFit.cover,
                placeholder: const _ShimmerPlaceholder(),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.isVideo
                            ? Icons.play_circle_filled
                            : Icons.photo_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder();

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFF202020),
                Color(0xFF303030),
                Color(0xFF202020),
              ],
              stops: [
                (_controller.value - 0.2).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.2).clamp(0.0, 1.0),
              ],
              begin: Alignment(-1, -0.3),
              end: Alignment(1, 0.3),
            ),
          ),
        );
      },
    );
  }
}

class _GalleryLoading extends StatelessWidget {
  const _GalleryLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: context.colorScheme.onPrimary,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _GalleryEmptyState extends StatelessWidget {
  const _GalleryEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.photo_size_select_actual_outlined,
          size: 48,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: 12),
        Text('No memories yet', style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Pull to refresh and load the latest highlights.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
