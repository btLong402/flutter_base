import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:code_base_riverpod/core/widgets/grid/pinterest.dart';
import 'package:code_base_riverpod/core/widgets/infinite_scroll/load_more_footer.dart';
import 'package:code_base_riverpod/core/widgets/infinite_scroll/pagination_controller.dart';
import 'package:code_base_riverpod/features/custom_grids_demo/presentation/providers/custom_grids_providers.dart';
import 'package:code_base_riverpod/features/infinity_scroll/presentation/screens/media_gallery_example.dart';

class CustomGridsDemoScreen extends ConsumerWidget {
  const CustomGridsDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(customGridPaginationControllerProvider);
    final scenarios = _buildScenarios();

    final bool isLoading = !controller.isInitialized && controller.isRefreshing;
    final bool hasItems = controller.itemCount > 0;
    final Object? blockingError = controller.error;

    Widget body;
    if (isLoading) {
      body = const _GridLoadingState();
    } else if (!hasItems && blockingError != null) {
      body = _GridErrorState(error: blockingError, onRetry: controller.retry);
    } else if (!hasItems) {
      body = const _GridEmptyState();
    } else {
      body = TabBarView(
        children: [
          for (final scenario in scenarios)
            _ScenarioView(scenario: scenario, controller: controller),
        ],
      );
    }

    return DefaultTabController(
      length: scenarios.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Grid Strategies'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final scenario in scenarios)
                Tab(
                  text: scenario.title,
                  icon: scenario.icon == null ? null : Icon(scenario.icon),
                ),
            ],
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: body,
        ),
      ),
    );
  }
}

class _ScenarioView extends StatefulWidget {
  const _ScenarioView({required this.scenario, required this.controller});

  final _GridScenario scenario;
  final PaginationController<MediaItem> controller;

  @override
  State<_ScenarioView> createState() => _ScenarioViewState();
}

class _ScenarioViewState extends State<_ScenarioView> {
  FixedScrollMetrics? _pendingMetrics;
  bool _metricsScheduled = false;
  int _lastNotifiedItemCount = 0;

  @override
  void didUpdateWidget(covariant _ScenarioView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // CRITICAL FIX: Detect when items are added and schedule metrics update
    // This ensures scroll position is re-evaluated after grid rebuilds with new items
    final currentItemCount = widget.controller.itemCount;
    if (currentItemCount != _lastNotifiedItemCount) {
      debugPrint(
        '[_ScenarioView] Item count changed: $_lastNotifiedItemCount → $currentItemCount',
      );
      _lastNotifiedItemCount = currentItemCount;

      // Trigger scroll metrics update after grid rebuilds with new items
      // This allows pagination to continue if user is still near bottom
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Force metrics re-evaluation by checking current scroll position
        final scrollable = Scrollable.maybeOf(context);
        if (scrollable != null) {
          final metrics = scrollable.position;
          _scheduleHandleMetrics(metrics);
        }
      });
    }
  }

  void _scheduleHandleMetrics(ScrollMetrics metrics) {
    final FixedScrollMetrics snapshot = FixedScrollMetrics(
      minScrollExtent: metrics.minScrollExtent,
      maxScrollExtent: metrics.maxScrollExtent,
      pixels: metrics.pixels,
      viewportDimension: metrics.viewportDimension,
      axisDirection: metrics.axisDirection,
      devicePixelRatio: metrics.devicePixelRatio,
    );
    _pendingMetrics = snapshot;
    if (_metricsScheduled) {
      return;
    }
    _metricsScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _pendingMetrics = null;
        _metricsScheduled = false;
        return;
      }
      final FixedScrollMetrics? pending = _pendingMetrics;
      _pendingMetrics = null;
      _metricsScheduled = false;
      if (pending != null) {
        widget.controller.handleScrollMetrics(pending);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.items;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final GridLayoutConfig layout = widget.scenario.layoutBuilder(items);
    final GridAnimationConfig animation =
        widget.scenario.animation ?? GridAnimationConfig.none();
    final EdgeInsetsGeometry padding =
        widget.scenario.padding ?? EdgeInsets.zero;

    // Forward scroll metrics to the pagination controller after layout phase.
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0 &&
            (notification is ScrollUpdateNotification ||
                notification is OverscrollNotification)) {
          _scheduleHandleMetrics(notification.metrics);
        }
        return false;
      },
      child: CustomScrollView(
        physics: const PinterestScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        cacheExtent: layout.cacheExtent ?? layout.prefetchExtent,
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: widget.controller.refresh),
          SliverToBoxAdapter(child: _ScenarioHeader(scenario: widget.scenario)),
          if (widget.scenario.usesPanel)
            ..._buildPanelSlivers(items, layout, animation, padding)
          else
            SliverPadding(
              padding: padding,
              sliver: AdvancedSliverGridList(
                layout: layout,
                itemCount: items.length,
                animation: animation,
                itemBuilder: (context, index) => MediaTile(item: items[index]),
              ),
            ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: LoadMoreFooter(
                  isLoading: widget.controller.isLoadingMore,
                  hasMore: widget.controller.hasMore,
                  error: widget.controller.hasItems
                      ? widget.controller.error
                      : null,
                  onRetry: widget.controller.retry,
                  emptyLabel: 'No ideas yet',
                  endLabel: 'You’ve explored all ideas',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPanelSlivers(
    List<MediaItem> items,
    GridLayoutConfig layout,
    GridAnimationConfig animation,
    EdgeInsetsGeometry padding,
  ) {
    final int subsetLength = (widget.scenario.itemCountOverride ?? items.length)
        .clamp(0, items.length);
    final List<MediaItem> subset = items.take(subsetLength).toList();

    return <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Perfect for hero sections or detail views.',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
      if (subset.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: padding,
            child: AdvancedGridPanel.builder(
              layout: layout,
              itemBuilder: (context, index) => MediaTile(item: subset[index]),
              itemCount: subset.length,
              animation: animation,
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Above panel participates in a parent scroll view, demonstrating non-scroll grids.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
      SliverPadding(
        padding: padding,
        sliver: AdvancedSliverGridList(
          layout: layout,
          itemCount: items.length,
          animation: animation,
          itemBuilder: (context, index) => MediaTile(item: items[index]),
        ),
      ),
    ];
  }
}

class _ScenarioHeader extends StatelessWidget {
  const _ScenarioHeader({required this.scenario});

  final _GridScenario scenario;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(scenario.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            scenario.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridLoadingState extends StatelessWidget {
  const _GridLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _GridEmptyState extends StatelessWidget {
  const _GridEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_off, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('No tiles yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Pull to refresh to populate the gallery.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GridErrorState extends StatelessWidget {
  const _GridErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            'We could not load the grid',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

List<_GridScenario> _buildScenarios() {
  return <_GridScenario>[
    _GridScenario(
      title: 'Fixed Grid',
      description: 'Uniform tiles with predictable ratio — ideal for catalogs.',
      icon: Icons.grid_view,
      padding: const EdgeInsets.all(16),
      layoutBuilder: (_) => const FixedGridLayout(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        cacheExtent: 400,
      ),
      animation: GridAnimationConfig.pinterest(),
    ),
    _GridScenario(
      title: 'Responsive Grid',
      description: 'Adapts column count with breakpoints to maximize space.',
      icon: Icons.view_quilt,
      padding: const EdgeInsets.all(16),
      layoutBuilder: (_) => ResponsiveGridLayout(
        breakpoints: <ResponsiveGridBreakpoint>[
          const ResponsiveGridBreakpoint(
            breakpoint: 480,
            crossAxisCount: 2,
            childAspectRatio: 0.95,
          ),
          const ResponsiveGridBreakpoint(
            breakpoint: 768,
            crossAxisCount: 3,
            childAspectRatio: 0.9,
          ),
          const ResponsiveGridBreakpoint(
            breakpoint: 1024,
            crossAxisCount: 4,
            childAspectRatio: 1.05,
          ),
          const ResponsiveGridBreakpoint(
            breakpoint: 1600,
            crossAxisCount: 5,
            childAspectRatio: 1.05,
          ),
        ],
        minCrossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      animation: GridAnimationConfig.pinterestFadeOnly(),
    ),
    _GridScenario(
      title: 'Masonry',
      description: 'Pinterest-style waterfall layout with column balancing.',
      icon: Icons.auto_awesome_mosaic,
      padding: const EdgeInsets.all(16),
      layoutBuilder: (items) => MasonryGridLayout(
        columnCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        // CRITICAL FIX: Increase cacheExtent for masonry grids to ensure
        // enough items are laid out so maxScrollExtent reflects true content height.
        // Without this, only 7-8 items are laid out from 30, causing pagination
        // to trigger too early. Setting to 2000 ensures ~15-20 items are laid out.
        cacheExtent: 2000,
        spanResolver: (index) {
          if (index >= items.length) {
            return const GridSpanConfiguration();
          }
          final item = items[index];
          final double extent = (item.masonryHeight ?? 220).clamp(140, 280);
          return GridSpanConfiguration(
            columnSpan: 1,
            mainAxisExtent: extent,
            alignment: AlignmentDirectional.topStart,
          );
        },
      ),
      animation: GridAnimationConfig.pinterest(
        duration: const Duration(milliseconds: 300),
      ),
    ),
    _GridScenario(
      title: 'Aspect Ratio',
      description: 'Ratio-driven grid ensures consistent visual rhythm.',
      icon: Icons.aspect_ratio,
      padding: const EdgeInsets.all(16),
      layoutBuilder: (_) => const RatioGridLayout(
        columnCount: 3,
        aspectRatio: 0.9,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      animation: GridAnimationConfig.staggered(
        duration: const Duration(milliseconds: 280),
      ),
    ),
    _GridScenario(
      title: 'Asymmetric',
      description: 'Highlighted stories span multiple columns for emphasis.',
      icon: Icons.view_comfy_alt,
      padding: const EdgeInsets.all(16),
      layoutBuilder: (items) => AsymmetricGridLayout(
        columnCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        spanResolver: (index) {
          if (index >= items.length) {
            return const GridSpanConfiguration();
          }
          final item = items[index];
          final bool highlight = item.isFeatured;
          final double baseRatio = (item.aspectRatio ?? 1).clamp(0.7, 1.6);
          return GridSpanConfiguration(
            columnSpan: highlight ? 2 : 1,
            aspectRatio: highlight
                ? baseRatio
                : (baseRatio * 0.9).clamp(0.6, 1.4),
            alignment: AlignmentDirectional.topStart,
          );
        },
      ),
      animation: GridAnimationConfig.staggered(
        duration: const Duration(milliseconds: 360),
      ),
    ),
    _GridScenario(
      title: 'Auto placement',
      description: 'Dynamic span rules with auto placement across columns.',
      icon: Icons.auto_awesome_motion,
      padding: const EdgeInsets.all(16),
      layoutBuilder: (items) => AutoPlacementGridLayout(
        columnCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        rule: AutoPlacementRule(
          maxSpan: 3,
          spanResolver: (index) {
            if (index >= items.length) {
              return const GridSpanConfiguration();
            }
            final item = items[index];
            final bool highlight = index % 7 == 0 || item.isFeatured;
            final int span = highlight ? 2 : 1;
            final double baseRatio = (item.aspectRatio ?? 1).clamp(0.7, 1.5);
            return GridSpanConfiguration(
              columnSpan: span,
              aspectRatio: highlight
                  ? (baseRatio * 1.1).clamp(0.8, 1.6)
                  : baseRatio,
            );
          },
        ),
      ),
      animation: GridAnimationConfig.staggered(
        duration: const Duration(milliseconds: 360),
      ),
    ),
    _GridScenario(
      title: 'Nested',
      description: 'Embed non-scrollable panels within scroll views.',
      icon: Icons.layers,
      usesPanel: true,
      padding: const EdgeInsets.all(12),
      layoutBuilder: (_) => const FixedGridLayout(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      animation: GridAnimationConfig.staggered(
        duration: const Duration(milliseconds: 320),
      ),
      itemCountOverride: 6,
    ),
  ];
}

class _GridScenario {
  const _GridScenario({
    required this.title,
    required this.description,
    required this.layoutBuilder,
    this.icon,
    this.animation,
    this.padding,
    this.usesPanel = false,
    this.itemCountOverride,
  });

  final String title;
  final String description;
  final GridLayoutConfig Function(List<MediaItem> items) layoutBuilder;
  final IconData? icon;
  final GridAnimationConfig? animation;
  final EdgeInsetsGeometry? padding;
  final bool usesPanel;
  final int? itemCountOverride;
}
