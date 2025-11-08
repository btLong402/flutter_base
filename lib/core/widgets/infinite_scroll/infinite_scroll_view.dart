import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'load_more_footer.dart';
import 'pagination_controller.dart';
import 'performance_utils.dart';
import 'refresh_controls.dart';
import 'separator_builder.dart';

enum InfiniteScrollLayout { list, grid }

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
  }) : assert(
         layout == InfiniteScrollLayout.grid ? gridDelegate != null : true,
         'gridDelegate is required for grid layout',
       );

  final PaginationController<T> controller;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final InfiniteScrollLayout layout;
  final bool useSlivers;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
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

  @override
  State<InfiniteScrollView<T>> createState() => _InfiniteScrollViewState<T>();
}

class _InfiniteScrollViewState<T> extends State<InfiniteScrollView<T>> {
  ScrollController? _internalController;

  PaginationController<T> get controller => widget.controller;

  ScrollController get _effectiveController =>
      widget.scrollController ?? (_internalController ??= ScrollController());

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
    setState(() {});
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      controller.handleScrollMetrics(metrics);
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
    final cacheExtent = resolveCacheExtent(
      widget.cacheExtent,
      MediaQuery.of(context).size.height,
    );
    final separators = SeparatorManager(builder: widget.separatorBuilder);
    final hasFooter = controller.itemCount > 0;
    final bodyCount = separators.childCount(controller.itemCount);
    final totalCount = bodyCount + (hasFooter ? 1 : 0);

    Widget list;
    if (widget.layout == InfiniteScrollLayout.list) {
      list = ListView.builder(
        controller: _effectiveController,
        physics:
            widget.physics ??
            const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
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
              return _buildAnimatedItem(ctx, itemIndex, item);
            },
          );
        },
        itemCount: totalCount,
      );
    } else {
      list = GridView.builder(
        controller: _effectiveController,
        physics:
            widget.physics ??
            const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
        padding: widget.padding,
        cacheExtent: cacheExtent,
        gridDelegate: widget.gridDelegate!,
        itemBuilder: (context, index) {
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
              return _buildAnimatedItem(ctx, itemIndex, item);
            },
          );
        },
        itemCount: totalCount,
      );
    }

    return MaterialRefreshWrapper(
      onRefresh: controller.refresh,
      semanticsLabel: widget.refreshSemanticsLabel ?? 'Pull to refresh',
      child: _buildContentWrapper(theme, list),
    );
  }

  Widget _buildSliverView(BuildContext context) {
    final physics =
        widget.physics ??
        const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
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
                  return _buildAnimatedItem(ctx, itemIndex, item);
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
                return _buildAnimatedItem(ctx, itemIndex, item);
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

  Widget _buildAnimatedItem(BuildContext context, int index, T item) {
    final semanticsLabel = widget.semanticsLabelBuilder?.call(item, index);
    final child = widget.itemBuilder(context, index, item);
    final animated = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.6, 1),
          child: Transform.scale(
            scale: value,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: child,
    );
    if (semanticsLabel != null) {
      return Semantics(label: semanticsLabel, child: animated);
    }
    return animated;
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
            color: theme.colorScheme.error.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: controller.retry, child: const Text('Retry')),
      ],
    );
  }
}
