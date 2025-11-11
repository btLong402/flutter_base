import 'dart:math' as math;

import 'package:code_base_riverpod/core/widgets/grid/pinterest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'load_more_footer.dart';
import 'pagination_controller.dart';
import 'performance_utils.dart';
import 'refresh_controls.dart';
import 'separator_builder.dart';

/// ## InfiniteScrollView - Performance-Optimized Infinite Scrolling Widget
///
/// ### Architecture & Performance Optimizations:
///
/// **1. Scroll Physics Consolidation**
/// - Unified physics resolution in `_resolveScrollPhysics()`
/// - Eliminates duplicate conditionals across list/grid builders
/// - Pinterest physics support for natural scrolling behavior
///
/// **2. Cache Extent Optimization**
/// - Smart cache extent calculation with grid-aware prefetching
/// - Uses constants from `InfiniteScrollDefaults` for consistency
/// - Grid mode: Prefetches 3 rows of tiles automatically
/// - List mode: 2x viewport multiplier for smooth scrolling
///
/// **3. Entrance Animations**
/// - Lightweight fade + scale animation using explicit controllers
/// - Constants-driven (opacity: 0.6→1.0, scale: 0.94→1.0)
/// - Single-pass animation, disposed after completion
/// - Optional via `enableImplicitEntranceAnimation`
///
/// **4. State Management**
/// - Post-frame callbacks prevent "setState during build" errors
/// - Controller listener updates scheduled intelligently
/// - Stable key generation for grid rebuilds with new items
///
/// **5. Grid Layout Integration**
/// - Advanced grid support: masonry, asymmetric, auto-placement
/// - Dynamic cache extent based on estimated tile dimensions
/// - Proper key management forces rebuild on item count changes
///
/// **6. Scroll Event Handling**
/// - Processes only `ScrollUpdateNotification` to prevent duplicates
/// - Delegates to `PaginationController.handleScrollMetrics()`
/// - Throttle + debounce in controller prevents excessive API calls
///
/// ### Usage Patterns:
/// ```dart
/// // List mode with separators
/// InfiniteScrollView<Post>(
///   controller: paginationController,
///   layout: InfiniteScrollLayout.list,
///   itemBuilder: (context, index, post) => PostTile(post),
///   separatorBuilder: (context, index) => Divider(),
/// )
///
/// // Grid mode with advanced layout
/// InfiniteScrollView<Photo>(
///   controller: mediaController,
///   layout: InfiniteScrollLayout.grid,
///   gridConfig: InfiniteGridConfig(
///     layout: MasonryGridLayout(...),
///     animation: GridAnimationConfig.staggered(),
///   ),
///   itemBuilder: (context, index, photo) => PhotoTile(photo),
/// )
/// ```

enum InfiniteScrollLayout { list, grid }

/// Configuration for integrating the advanced grid system with
/// [InfiniteScrollView]. Supply a [GridLayoutConfig] alongside optional
/// animation parameters to enable fixed, responsive, masonry, asymmetric, or
/// auto-placement grids.
class InfiniteGridConfig {
  const InfiniteGridConfig({required this.layout, this.animation});

  final GridLayoutConfig layout;
  final GridAnimationConfig? animation;
}

/// High-level view that renders an infinite scrolling list or grid with built-in
/// pull-to-refresh and load-more behaviour. Supports both CustomScrollView
/// (Sliver) and ListView/GridView (material) variants.
class InfiniteScrollView<T> extends StatefulWidget {
  const InfiniteScrollView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.layout = InfiniteScrollLayout.list,
    this.useSlivers = false,
    this.scrollController,
    this.physics,
    this.padding,
    this.gridConfig,
    this.gridDelegate,
    this.itemExtent,
    this.cacheExtent,
    this.separatorBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.footerBuilder,
    this.sliverAppBar,
    this.semanticsLabelBuilder,
    this.refreshSemanticsLabel,
    this.itemKeyBuilder,
    this.enableItemRepaintBoundary = true,
    this.enableImplicitEntranceAnimation = true,
    this.usePinterestPhysics = false,
  }) : assert(
         layout != InfiniteScrollLayout.grid ||
             gridDelegate != null ||
             gridConfig != null,
         'Provide gridConfig or gridDelegate when using grid layout',
       ),
       assert(
         layout != InfiniteScrollLayout.grid ||
             gridDelegate == null ||
             gridConfig == null,
         'gridDelegate and gridConfig are mutually exclusive',
       );

  final PaginationController<T> controller;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final InfiniteScrollLayout layout;
  final bool useSlivers;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final InfiniteGridConfig? gridConfig;
  final SliverGridDelegate? gridDelegate;
  final double? itemExtent;
  final double? cacheExtent;
  final InfiniteSeparatorBuilder? separatorBuilder;
  final WidgetBuilder? emptyBuilder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  errorBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? footerBuilder;
  final SliverAppBar? sliverAppBar;
  final String Function(T item, int index)? semanticsLabelBuilder;
  final String? refreshSemanticsLabel;
  final Key Function(T item, int index)? itemKeyBuilder;
  final bool enableItemRepaintBoundary;
  final bool enableImplicitEntranceAnimation;

  /// Enable Pinterest-style scroll physics for smooth, natural scrolling
  final bool usePinterestPhysics;

  @override
  State<InfiniteScrollView<T>> createState() => _InfiniteScrollViewState<T>();
}

class _InfiniteScrollViewState<T> extends State<InfiniteScrollView<T>> {
  ScrollController? _internalController;
  bool _hasPendingControllerUpdate = false;
  final Set<int> _animatedIndices = {};
  int _lastItemCount = 0;

  PaginationController<T> get controller => widget.controller;

  ScrollController get _effectiveController =>
      widget.scrollController ?? (_internalController ??= ScrollController());

  /// Resolves and caches scroll physics to avoid repeated conditionals
  ScrollPhysics _resolveScrollPhysics() {
    if (widget.physics != null) return widget.physics!;

    // CRITICAL: Always use AlwaysScrollableScrollPhysics as parent for pull-to-refresh
    const basePhysics = AlwaysScrollableScrollPhysics();

    if (widget.usePinterestPhysics) {
      return const PinterestScrollPhysics(parent: basePhysics);
    }

    return const BouncingScrollPhysics(parent: basePhysics);
  }

  /// Resolves cache extent with viewport dimension
  double _resolveCacheExtent(double viewportDimension) {
    return resolveCacheExtent(widget.cacheExtent, viewportDimension);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerUpdated);
  }

  @override
  void didUpdateWidget(covariant InfiniteScrollView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_onControllerUpdated);
      widget.controller.addListener(_onControllerUpdated);
      // Clear animation tracking when controller changes
      _animatedIndices.clear();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerUpdated);
    _internalController?.dispose();
    super.dispose();
  }

  void _onControllerUpdated() {
    if (!mounted) return;

    // Clear animation tracking when item count decreases significantly
    // This indicates a refresh has occurred with new data
    final currentItemCount = controller.itemCount;
    if (currentItemCount < _lastItemCount) {
      _animatedIndices.clear();
      debugPrint(
        '[InfiniteScrollView] Refresh detected: itemCount $_lastItemCount → $currentItemCount, '
        'clearing animation state',
      );
    }
    _lastItemCount = currentItemCount;

    // PERFORMANCE: Avoid setState during build or layout phase.
    // Schedule update for post-frame to prevent "setState during build" errors
    // and layout thrashing during rapid scroll events.
    final scheduler = SchedulerBinding.instance;
    final phase = scheduler.schedulerPhase;

    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      // Safe to update immediately
      setState(() {});
      return;
    }

    // Already have a pending update scheduled
    if (_hasPendingControllerUpdate) {
      return;
    }

    _hasPendingControllerUpdate = true;
    scheduler.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _hasPendingControllerUpdate = false;
      setState(() {});
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    // PERFORMANCE FIX: Only process ScrollUpdateNotification to prevent duplicate
    // handling. OverscrollNotification is a subclass of ScrollNotification but
    // doesn't provide meaningful position changes for pagination triggers.
    // Processing both causes duplicate loadMore() calls especially after page 10.
    if (notification is ScrollUpdateNotification) {
      controller.handleScrollMetrics(notification.metrics);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: widget.useSlivers
          ? _buildSliverView(context)
          : _buildListView(context),
    );
  }

  Widget _buildListView(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final cacheExtent = _resolveCacheExtent(screenSize.height);
    final physics = _resolveScrollPhysics();
    final separators = SeparatorManager(builder: widget.separatorBuilder);
    final hasFooter = controller.itemCount > 0;
    final bodyCount = separators.childCount(controller.itemCount);
    final totalCount = bodyCount + (hasFooter ? 1 : 0);

    debugPrint(
      '[InfiniteScrollView] Building grid/list: itemCount=${controller.itemCount}, '
      'totalCount=$totalCount, layout=${widget.layout}',
    );

    Widget list;
    if (widget.layout == InfiniteScrollLayout.list) {
      list = ListView.builder(
        controller: _effectiveController,
        physics: physics,
        padding: widget.padding,
        cacheExtent: cacheExtent,
        itemExtent: widget.separatorBuilder == null ? widget.itemExtent : null,
        itemBuilder: (context, index) {
          if (hasFooter && index == totalCount - 1) {
            return _buildFooter(context);
          }
          return separators.buildChild(
            context: context,
            index: index,
            itemCount: controller.itemCount,
            itemBuilder: (ctx, itemIndex) {
              final item = controller.itemAt(itemIndex);
              if (item == null) {
                return const SizedBox.shrink();
              }
              return _buildItem(ctx, itemIndex, item);
            },
          );
        },
        itemCount: totalCount,
      );
    } else {
      final InfiniteGridConfig? gridConfig = widget.gridConfig;
      if (gridConfig != null) {
        final bool animateItems = gridConfig.animation == null;
        // PERFORMANCE FIX: Use stable key based on layout config only
        // Let Flutter's element tree handle incremental updates when items change
        final Key gridKey = ValueKey<int>(gridConfig.layout.hashCode);
        final gridCacheExtent = _gridCacheExtentFor(context, gridConfig);
        list = AdvancedGridView.builder(
          key: gridKey,
          controller: _effectiveController,
          physics: physics,
          padding: widget.padding,
          cacheExtent: gridCacheExtent,
          layout: gridConfig.layout,
          animation: gridConfig.animation,
          itemCount: totalCount,
          itemBuilder: (context, index) {
            return _buildGridTile(
              context,
              index: index,
              totalCount: totalCount,
              hasFooter: hasFooter,
              separators: separators,
              animateItems: animateItems,
            );
          },
        );
      } else {
        list = GridView.builder(
          controller: _effectiveController,
          physics: physics,
          padding: widget.padding,
          cacheExtent: cacheExtent,
          gridDelegate: widget.gridDelegate!,
          itemBuilder: (context, index) {
            return _buildGridTile(
              context,
              index: index,
              totalCount: totalCount,
              hasFooter: hasFooter,
              separators: separators,
              animateItems: true,
            );
          },
          itemCount: totalCount,
        );
      }
    }

    return MaterialRefreshWrapper(
      onRefresh: controller.refresh,
      semanticsLabel: widget.refreshSemanticsLabel ?? 'Pull to refresh',
      child: _buildContentWrapper(theme, list),
    );
  }

  Widget _buildSliverView(BuildContext context) {
    final physics = _resolveScrollPhysics();
    final slivers = <Widget>[
      if (widget.sliverAppBar != null) widget.sliverAppBar!,
      CupertinoSliverRefreshWrapper(onRefresh: controller.refresh),
      if (!controller.isInitialized && controller.isRefreshing)
        SliverToBoxAdapter(child: _buildLoading(context))
      else if (controller.itemCount == 0 && controller.error == null)
        SliverToBoxAdapter(child: _buildEmpty(context))
      else if (controller.itemCount == 0 && controller.error != null)
        SliverToBoxAdapter(child: _buildError(context))
      else
        _buildSliverContent(),
      if (controller.itemCount > 0)
        SliverToBoxAdapter(child: _buildFooter(context)),
    ];

    return CustomScrollView(
      controller: _effectiveController,
      physics: physics,
      slivers: slivers,
    );
  }

  Widget _buildSliverContent() {
    final separators = SeparatorManager(builder: widget.separatorBuilder);
    final childCount = separators.childCount(controller.itemCount);

    if (widget.layout == InfiniteScrollLayout.grid) {
      final InfiniteGridConfig? gridConfig = widget.gridConfig;
      if (gridConfig != null) {
        Widget buildChild(BuildContext context, int index) {
          return separators.buildChild(
            context: context,
            index: index,
            itemCount: controller.itemCount,
            itemBuilder: (ctx, itemIndex) {
              final item = controller.itemAt(itemIndex);
              if (item == null) {
                return const SizedBox.shrink();
              }
              return _buildItem(
                ctx,
                itemIndex,
                item,
                animate: gridConfig.animation == null,
              );
            },
          );
        }

        final SliverChildBuilderDelegate delegate = SliverChildBuilderDelegate(
          gridConfig.animation == null
              ? buildChild
              : (context, index) => gridConfig.animation!.wrap(
                  context,
                  index,
                  buildChild(context, index),
                ),
          childCount: childCount,
          addAutomaticKeepAlives: gridConfig.layout.addAutomaticKeepAlives,
          addRepaintBoundaries: gridConfig.layout.addRepaintBoundaries,
          addSemanticIndexes: gridConfig.layout.addSemanticIndexes,
        );

        // PERFORMANCE FIX: Use stable key based on layout config only
        // Let Flutter's element tree handle incremental updates when items change
        final AdvancedSliverGrid sliver = AdvancedSliverGrid(
          key: ValueKey<int>(gridConfig.layout.hashCode),
          layout: gridConfig.layout,
          delegate: delegate,
        );

        final EdgeInsetsGeometry? padding =
            widget.padding ?? gridConfig.layout.padding;
        if (padding != null) {
          return SliverPadding(padding: padding, sliver: sliver);
        }
        return sliver;
      }

      return SliverPadding(
        padding: widget.padding ?? EdgeInsets.zero,
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return separators.buildChild(
                context: context,
                index: index,
                itemCount: controller.itemCount,
                itemBuilder: (ctx, itemIndex) {
                  final item = controller.itemAt(itemIndex);
                  if (item == null) {
                    return const SizedBox.shrink();
                  }
                  return _buildItem(ctx, itemIndex, item);
                },
              );
            },
            childCount: childCount,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
          ),
          gridDelegate: widget.gridDelegate!,
        ),
      );
    }

    return SliverPadding(
      padding: widget.padding ?? EdgeInsets.zero,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return separators.buildChild(
              context: context,
              index: index,
              itemCount: controller.itemCount,
              itemBuilder: (ctx, itemIndex) {
                final item = controller.itemAt(itemIndex);
                if (item == null) {
                  return const SizedBox.shrink();
                }
                return _buildItem(ctx, itemIndex, item);
              },
            );
          },
          childCount: childCount,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
        ),
      ),
    );
  }

  Widget _buildContentWrapper(ThemeData theme, Widget child) {
    if (!controller.isInitialized && controller.isRefreshing) {
      return _buildLoading(context);
    }

    if (controller.itemCount == 0 &&
        controller.isInitialized &&
        controller.error == null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(child: _buildEmpty(context)),
        ),
      );
    }

    if (controller.itemCount == 0 && controller.error != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(child: _buildError(context)),
        ),
      );
    }

    return child;
  }

  double? _gridCacheExtentFor(BuildContext context, InfiniteGridConfig config) {
    // Return explicit value if provided
    final explicit = widget.cacheExtent ?? config.layout.cacheExtent;
    if (explicit != null) return explicit;

    // Calculate cross-axis extent
    final crossAxisExtent = _resolvedCrossAxisExtent(context, config);
    if (!crossAxisExtent.isFinite || crossAxisExtent <= 0) {
      return config.layout.prefetchExtent;
    }

    // Estimate main-axis extent for prefetch calculation
    final descriptor = describeGridLayout(
      config.layout,
      crossAxisExtent,
      Directionality.of(context),
    );
    final mainAxisExtent = _estimateMainAxisExtent(descriptor, crossAxisExtent);

    // Prefetch roughly 3 rows worth of tiles
    if (mainAxisExtent != null &&
        mainAxisExtent.isFinite &&
        mainAxisExtent > 0) {
      return mainAxisExtent * InfiniteScrollDefaults.gridCacheExtentMultiplier;
    }

    return config.layout.prefetchExtent;
  }

  double _resolvedCrossAxisExtent(
    BuildContext context,
    InfiniteGridConfig config,
  ) {
    final EdgeInsetsGeometry combinedPadding =
        widget.padding ?? config.layout.padding ?? EdgeInsets.zero;
    final EdgeInsets resolved = combinedPadding.resolve(
      Directionality.of(context),
    );
    final double width = MediaQuery.of(context).size.width;
    final double crossAxisExtent = width - resolved.horizontal;
    return math.max(crossAxisExtent, 0);
  }

  double? _estimateMainAxisExtent(
    BoxGridLayoutDescriptor descriptor,
    double crossAxisExtent,
  ) {
    final span = descriptor.spanResolver(0);
    if (span == null) return null;

    // Use explicit main-axis extent if available
    if (span.mainAxisExtent != null && span.mainAxisExtent! > 0) {
      return span.mainAxisExtent;
    }

    // Calculate column width
    final columnWidth =
        descriptor.fixedColumnWidth ??
        _computeFlexibleColumnWidth(descriptor, crossAxisExtent);
    if (columnWidth <= 0) return null;

    // Calculate total width for this span
    final spanColumns = span.columnSpan.clamp(1, descriptor.columnCount);
    final totalWidth =
        columnWidth * spanColumns +
        descriptor.crossAxisSpacing * (spanColumns - 1);

    // Apply aspect ratio if available
    if (span.aspectRatio != null && span.aspectRatio! > 0) {
      return totalWidth / span.aspectRatio!;
    }

    return null;
  }

  double _computeFlexibleColumnWidth(
    BoxGridLayoutDescriptor descriptor,
    double crossAxisExtent,
  ) {
    if (descriptor.columnCount <= 0) return 0;
    if (descriptor.fixedColumnWidth != null)
      return descriptor.fixedColumnWidth!;

    final spacing =
        descriptor.crossAxisSpacing * math.max(descriptor.columnCount - 1, 0);
    final usable = math.max(0, crossAxisExtent - spacing);
    return usable / descriptor.columnCount;
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    T item, {
    bool animate = true,
  }) {
    final semanticsLabel = widget.semanticsLabelBuilder?.call(item, index);

    // PERFORMANCE: Stable keys prevent unnecessary rebuilds during scroll.
    // Using ValueKey with index as fallback if no custom key provided.
    final Key itemKey =
        widget.itemKeyBuilder?.call(item, index) ?? ValueKey<int>(index);

    Widget child = widget.itemBuilder(context, index, item);

    // PERFORMANCE: Lightweight entrance animation using AnimatedOpacity.
    // Only animate items that haven't been animated before to prevent
    // re-animation on rebuild when new pages are loaded.
    if (widget.enableImplicitEntranceAnimation && animate) {
      final bool shouldAnimate = _animatedIndices.add(index);
      if (shouldAnimate) {
        child = _LightweightEntranceAnimation(child: child);
      }
    }

    // PERFORMANCE: RepaintBoundary isolates item repaints, preventing
    // unnecessary repaints of neighboring items during animations or updates.
    if (widget.enableItemRepaintBoundary) {
      child = RepaintBoundary(child: child);
    }

    // Wrap with stable key to maintain item identity during scroll
    child = KeyedSubtree(key: itemKey, child: child);

    if (semanticsLabel != null) {
      return Semantics(label: semanticsLabel, child: child);
    }
    return child;
  }

  Widget _buildGridTile(
    BuildContext context, {
    required int index,
    required int totalCount,
    required bool hasFooter,
    required SeparatorManager separators,
    required bool animateItems,
  }) {
    if (hasFooter && index == totalCount - 1) {
      return Center(child: _buildFooter(context));
    }
    return separators.buildChild(
      context: context,
      index: index,
      itemCount: controller.itemCount,
      itemBuilder: (ctx, itemIndex) {
        final item = controller.itemAt(itemIndex);
        if (item == null) {
          return const SizedBox.shrink();
        }
        return _buildItem(ctx, itemIndex, item, animate: animateItems);
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (controller.itemCount == 0) {
      return const SizedBox.shrink();
    }
    if (widget.footerBuilder != null) {
      return widget.footerBuilder!(context);
    }
    return LoadMoreFooter(
      isLoading: controller.isLoadingMore,
      hasMore: controller.hasMore,
      error: controller.error,
      onRetry: controller.retry,
      emptyLabel: 'Nothing here yet',
      endLabel: 'End of results',
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    }
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Loading…', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    if (widget.emptyBuilder != null) {
      return widget.emptyBuilder!(context);
    }
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_outlined, size: 48, color: theme.colorScheme.outline),
        const SizedBox(height: 12),
        Text('No data yet', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Pull to refresh or check back later.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    if (controller.error == null) {
      return const SizedBox.shrink();
    }
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, controller.error!, controller.retry);
    }
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: 48,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 12),
        Text(
          'Connection issue',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to retry loading.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: controller.retry, child: const Text('Retry')),
      ],
    );
  }
}

/// Lightweight entrance animation for list/grid items.
///
/// PERFORMANCE: Uses StatefulWidget with SingleTickerProviderStateMixin
/// for efficient animation lifecycle. Animates only opacity and scale
/// with minimal overhead. Animation is run once on mount and disposed.
class _LightweightEntranceAnimation extends StatefulWidget {
  const _LightweightEntranceAnimation({required this.child});

  final Widget child;

  @override
  State<_LightweightEntranceAnimation> createState() =>
      _LightweightEntranceAnimationState();
}

class _LightweightEntranceAnimationState
    extends State<_LightweightEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: InfiniteScrollDefaults.entranceAnimationDuration,
    );

    _opacity = Tween<double>(
      begin: InfiniteScrollDefaults.entranceOpacityStart,
      end: InfiniteScrollDefaults.entranceOpacityEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scale = Tween<double>(
      begin: InfiniteScrollDefaults.entranceScaleStart,
      end: InfiniteScrollDefaults.entranceScaleEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation immediately on mount
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
