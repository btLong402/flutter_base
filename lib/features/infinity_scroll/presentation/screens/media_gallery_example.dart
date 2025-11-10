import 'dart:math';

import 'package:code_base_riverpod/core/context/context_extenstion.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_image_widget/custom_image_widget.dart';
import '../../../../core/widgets/grid/grid.dart';
import '../../../../core/widgets/infinite_scroll/infinite_scroll.dart';
import '../../../../core/widgets/infinite_scroll/grid_layout_variants.dart';

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
      final isFeatured = id % 7 == 0;
      final aspectRatio =
          (0.65 + random.nextDouble() * 0.45); // 0.65 - 1.1 range
      final masonryHeight = 180 + random.nextDouble() * 220;
      return MediaItem(
        id: id,
        title: 'Memory #$id',
        isVideo: isVideo,
        previewUrl: 'https://picsum.photos/seed/media$id/600/900',
        heroTag: 'media-$id',
        aspectRatio: aspectRatio,
        isFeatured: isFeatured,
        masonryHeight: masonryHeight,
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
    this.subtitle,
    this.color,
    this.aspectRatio,
    this.masonryHeight,
    this.isFeatured = false,
  });

  final int id;
  final String title;
  final bool isVideo;
  final String previewUrl;
  final String heroTag;
  final String? subtitle;
  final Color? color;
  final double? aspectRatio;
  final double? masonryHeight;
  final bool isFeatured;
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
  GridLayoutVariant _layoutType = GridLayoutVariant.autoPlacement;

  @override
  void initState() {
    super.initState();
    _controller = PaginationController<MediaItem>(
      pageSize: 30,
      preloadFraction: 0.7,
      debounceDuration: const Duration(milliseconds: 260),
      keepPagesInMemory: null, // Keep 10 pages = 300 items in memory
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
    final InfiniteGridConfig gridConfig = _resolveGridConfig(context);
    final String layoutLabel = _layoutLabel(_layoutType);

    return InfiniteScrollView<MediaItem>(
      controller: _controller,
      useSlivers: true,
      usePinterestPhysics: true, // Enable Pinterest-style scrolling
      layout: InfiniteScrollLayout.grid,
      gridConfig: gridConfig,
      sliverAppBar: SliverAppBar(
        pinned: true,
        floating: false,
        expandedHeight: 156,
        title: Text('Memories • $layoutLabel'),
        actions: [
          IconButton(
            tooltip: 'Cycle layout',
            icon: const Icon(Icons.auto_awesome_mosaic_outlined),
            onPressed: _cycleLayout,
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '5,000+ media items.\nTesting $layoutLabel grid with infinite scrolling.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        bottom: _buildLayoutSelector(context),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemBuilder: (context, index, item) {
        return MediaTile(item: item);
      },
      itemKeyBuilder: (item, index) => ValueKey('media-${item.id}'),
      semanticsLabelBuilder: (item, index) => item.title,
      loadingBuilder: (context) => const _GalleryLoading(),
      emptyBuilder: (context) => const _GalleryEmptyState(),
    );
  }

  void _cycleLayout() {
    final values = GridLayoutVariant.values;
    final int currentIndex = values.indexOf(_layoutType);
    final int nextIndex = (currentIndex + 1) % values.length;
    setState(() => _layoutType = values[nextIndex]);
  }

  InfiniteGridConfig _resolveGridConfig(BuildContext context) {
    final int columns = _baseColumnCount(context);

    // Use Pinterest-style animations for better UX
    final GridAnimationConfig animation =
        _layoutType == GridLayoutVariant.masonry
        ? GridAnimationConfig.pinterest(
            duration: const Duration(milliseconds: 300),
            staggerDelay: const Duration(milliseconds: 25),
          )
        : GridAnimationConfig.pinterestFadeOnly(
            duration: const Duration(milliseconds: 250),
          );

    switch (_layoutType) {
      case GridLayoutVariant.fixed:
        final double aspect = context.isDesktopLayout
            ? 1.02
            : context.isTabletLayout
            ? 0.86
            : 0.72;
        return InfiniteGridConfig(
          layout: FixedGridLayout(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: aspect,
          ),
          animation: animation,
        );
      case GridLayoutVariant.flexible:
        return InfiniteGridConfig(
          layout: ResponsiveGridLayout(
            breakpoints: const [
              ResponsiveGridBreakpoint(
                breakpoint: 480,
                crossAxisCount: 2,
                childAspectRatio: 0.78,
              ),
              ResponsiveGridBreakpoint(
                breakpoint: 768,
                crossAxisCount: 3,
                childAspectRatio: 0.8,
              ),
              ResponsiveGridBreakpoint(
                breakpoint: 1120,
                crossAxisCount: 4,
                childAspectRatio: 0.82,
              ),
              ResponsiveGridBreakpoint(
                breakpoint: 1440,
                crossAxisCount: 5,
                childAspectRatio: 0.85,
              ),
            ],
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            minCrossAxisCount: 2,
            maxCrossAxisCount: 6,
          ),
          animation: animation,
        );
      case GridLayoutVariant.masonry:
        return InfiniteGridConfig(
          layout: MasonryGridLayout(
            columnCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            spanResolver: (index) {
              final item = _controller.itemAt(index);
              final bool spanTwo = (item?.isFeatured ?? false) && columns > 1;
              final double extent = item?.masonryHeight ?? 220;
              return GridSpanConfiguration(
                columnSpan: spanTwo ? min(columns, 2) : 1,
                mainAxisExtent: extent,
              );
            },
          ),
          animation: animation,
        );
      case GridLayoutVariant.ratio:
        final double ratio = context.isDesktopLayout
            ? 1.18
            : context.isTabletLayout
            ? 0.92
            : 0.74;
        return InfiniteGridConfig(
          layout: RatioGridLayout(
            columnCount: columns,
            aspectRatio: ratio,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          animation: animation,
        );
      case GridLayoutVariant.nested:
        final int innerColumns = max(1, columns - 1);
        final GridLayoutConfig innerLayout = AutoPlacementGridLayout(
          columnCount: innerColumns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          rule: AutoPlacementRule(
            maxSpan: innerColumns,
            spanResolver: (index) {
              final item = _controller.itemAt(index);
              final bool spanTwo =
                  (item?.isFeatured ?? false) && innerColumns > 1;
              final double aspect = item?.aspectRatio ?? 0.8;
              return GridSpanConfiguration(
                columnSpan: spanTwo ? min(innerColumns, 2) : 1,
                aspectRatio: aspect,
              );
            },
          ),
        );
        return InfiniteGridConfig(
          layout: NestedGridLayout(
            innerLayout: innerLayout,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            primary: false,
            scrollPhysics: const BouncingScrollPhysics(),
          ),
          animation: animation,
        );
      case GridLayoutVariant.asymmetric:
        return InfiniteGridConfig(
          layout: AsymmetricGridLayout(
            columnCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            spanResolver: (index) {
              final item = _controller.itemAt(index);
              final int pattern = index % 6;
              final bool spanTwo =
                  (pattern == 0 || pattern == 5) && columns > 1;
              final int span = spanTwo ? min(columns, 2) : 1;
              final double aspect = item?.aspectRatio ?? 0.82;
              final AlignmentGeometry alignment = pattern == 5
                  ? AlignmentDirectional.bottomCenter
                  : AlignmentDirectional.topStart;
              return GridSpanConfiguration(
                columnSpan: span,
                aspectRatio: aspect,
                alignment: alignment,
              );
            },
          ),
          animation: animation,
        );
      case GridLayoutVariant.autoPlacement:
        return InfiniteGridConfig(
          layout: AutoPlacementGridLayout(
            columnCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            crossAxisAlignment: AlignmentDirectional.topStart,
            rule: AutoPlacementRule(
              maxSpan: columns,
              spanResolver: (index) {
                final item = _controller.itemAt(index);
                final bool spanTwo = (item?.isFeatured ?? false) && columns > 1;
                final double aspect = item?.aspectRatio ?? 0.78;
                return GridSpanConfiguration(
                  columnSpan: spanTwo ? min(columns, 2) : 1,
                  aspectRatio: aspect,
                );
              },
            ),
          ),
          animation: animation,
        );
    }
  }

  int _baseColumnCount(BuildContext context) {
    if (context.isDesktopLayout) {
      return 5;
    }
    if (context.isTabletLayout) {
      return 3;
    }
    return 2;
  }

  String _layoutLabel(GridLayoutVariant type) {
    return type.displayLabel;
  }

  PreferredSizeWidget _buildLayoutSelector(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(52),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: GridLayoutVariant.values.map((type) {
              final bool selected = _layoutType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_layoutLabel(type)),
                  selected: selected,
                  onSelected: (value) {
                    if (!value) {
                      return;
                    }
                    setState(() => _layoutType = type);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class MediaTile extends StatelessWidget {
  const MediaTile({super.key, required this.item});

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
