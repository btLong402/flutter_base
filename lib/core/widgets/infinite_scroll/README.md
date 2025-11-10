# Infinite Scroll Widgets

A modular, high-performance infinite scrolling system that works in both Material and Cupertino UI stacks. It supports huge datasets (5,000+ items), smooth animations, refresh controls, and paging helpers while remaining memory conscious.

## Modules

- `infinite_scroll.dart` – umbrella export for the widget suite.
- `pagination_controller.dart` – load/refresh/retry logic with debouncing, deduplication, and page caching.
- `infinite_scroll_view.dart` – renders list/advanced grid layouts as either `ListView` or `CustomScrollView` slivers.
- `refresh_controls.dart` – material (`RefreshIndicator`) and Cupertino (`CupertinoSliverRefreshControl`) pull-to-refresh wrappers.
- `load_more_footer.dart` – animated loading/error/end-of-list footer.
- `performance_utils.dart` – tuning constants and helpers (`shouldTriggerLoadMore`, `resolveCacheExtent`).
- `performance_overlay.dart` – frame timing HUD for quick jank diagnostics.
- `separator_builder.dart` – shared separator logic so list, grid, and sliver modes stay in sync.
- `examples/` – runnable samples for REST backends and media-heavy feeds.

## Quick Start

```dart
final controller = PaginationController<Post>(
  pageSize: 20,
  preloadFraction: 0.8,
  debounceDuration: const Duration(milliseconds: 320),
  loadPage: ({required int page, required int pageSize}) async {
    return api.fetchPosts(page: page, pageSize: pageSize);
  },
  onPageLoaded: cache.prefetchPosts,
);

InfiniteScrollView<Post>(
  controller: controller,
  layout: InfiniteScrollLayout.list,
  padding: const EdgeInsets.all(16),
  itemExtent: 120,
  separatorBuilder: (context, index) => const Divider(height: 0, thickness: 1),
  itemBuilder: (context, index, post) => PostTile(post: post),
  emptyBuilder: (context) => const EmptyState(),
  errorBuilder: (context, error, retry) => ErrorState(error: error, onRetry: retry),
);
```

For sliver usage with a `SliverAppBar`:

```dart
InfiniteScrollView<MediaItem>(
  controller: mediaController,
  useSlivers: true,
  layout: InfiniteScrollLayout.grid,
  gridConfig: InfiniteGridConfig(
    layout: ResponsiveGridLayout(
      breakpoints: const [
        ResponsiveGridBreakpoint(
          breakpoint: 480,
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        ResponsiveGridBreakpoint(
          breakpoint: 840,
          crossAxisCount: 3,
          childAspectRatio: 0.8,
        ),
      ],
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
    ),
    animation: GridAnimationConfig.staggered(),
  ),
  sliverAppBar: SliverAppBar(
    pinned: true,
    floating: false,
    expandedHeight: 120,
    flexibleSpace: FlexibleSpaceBar(title: const Text('Gallery')),
  ),
  separatorBuilder: (context, index) => const SizedBox.shrink(), // Optional row spacing cell.
  itemBuilder: (context, index, item) => MediaTile(item: item),
  itemKeyBuilder: (item, index) => ValueKey(item.id),
);
```

## Tuning Tips

- **Page size**: start with 20–30 items for text lists, 12–24 for media-heavy grids.
- **Cache extent**: default multiplies the viewport by 1.5; increase for aggressive prefetch, reduce to save memory.
- **Item extent**: supply when rows have fixed height to keep layout passes O(1).
- **Separators**: implement once via `separatorBuilder`; works for list/sliver/grid. In grid mode separators render as lightweight placeholder tiles—use a `SizedBox.shrink()` to disable per row, or an animated widget to create custom dividers.
- **Advanced grids**: plug in `AutoPlacementGridLayout`, `MasonryGridLayout`, `AsymmetricGridLayout`, or any `GridLayoutConfig` via `InfiniteGridConfig` to reuse virtualization, caching, and refresh flows.
- **Stable recycling**: supply `itemKeyBuilder` for deterministic widget reuse and set `enableItemRepaintBoundary` to isolate heavy paint costs (enabled by default).
- **Debounce**: raise `debounceDuration` if your backend enforces rate limits.
- **Keep-pages**: `keepPagesInMemory` drops oldest pages to cap RAM usage (default: 6 pages).
- **Prefetch**: use `onPageLoaded` to queue image/video thumbnail caching.

## Performance & Instrumentation

- Wrap demo screens with `ScrollPerformanceOverlay` to monitor build/raster time averages and jank rate without leaving the app.
- `InfiniteScrollBenchmarkScreen` (see `lib/features/infinity_scroll/presentation/screens/infinite_scroll_benchmark_screen.dart`) exposes sliders for page size, cache extent multiplier, preload threshold, animation toggles, and HUD visibility so you can quickly profile different configurations.
- Recommended mobile defaults:
  - `pageSize`: 24–30 items for media-rich grids.
  - `preloadFraction`: 0.7–0.8 (triggers the next page before reaching the end).
  - `cacheExtent`: `viewportHeight * 1.6` for handheld devices.
  - `keepPagesInMemory`: 6–8 to balance smooth backscrolling and memory.
- Recommended tablet / desktop tweaks:
  - Increase `pageSize` to 36–48 to reduce request frequency on large screens.
  - Raise `cacheExtentMultiplier` to 2.0–2.4 and lower `preloadFraction` to ~0.6 for long viewports.
  - Enable animations sparingly; use `GridAnimationConfig.none()` for strict performance testing.

## Testing & Stress Harness

- `test/core/widgets/infinite_scroll/pagination_controller_test.dart` now covers in-flight deduplication and scroll debouncing edge cases.
- `test/core/widgets/infinite_scroll/infinite_scroll_view_test.dart` validates stable key usage when `itemKeyBuilder` is provided.
- Use `InfiniteScrollBenchmarkScreen` for manual stress checks (5k+ dataset). Pair it with `ScrollPerformanceOverlay` to verify ≥90% frames under 16ms.

## Error & Retry

`PaginationController.retry()` repeats the last failed request. `LoadMoreFooter` exposes a retry CTA and the view renders a dedicated empty/error state while keeping existing items intact.

## Testing & Accessibility

- The controller is fully testable without the UI (`pagination_controller_test.dart`).
- Provide `semanticsLabelBuilder` for screen readers and keyboard focus.
- `InfiniteScrollView` listens to `ScrollNotification`, making it compatible with mouse, trackpad, and touch input.

## Examples

- `examples/rest_repository_example.dart` – REST pagination with failure retries and image prefetch hints.
- `examples/media_gallery_example.dart` – media feed showcasing grid layout, shimmer placeholders, cached thumbnails, and sliver-based scrolling.

## Performance Considerations

- Use lightweight item widgets; reserve `AutomaticKeepAliveClientMixin` for truly stateful children.
- Avoid storing the entire dataset: the controller caches a sliding window (`keepPagesInMemory`).
- For media feeds, warm caches using `onPageLoaded` and disable expensive shadows/effects inside list items.
- Consider providing `scrollController` to plug into outer layout (e.g., `ScrollNotificationObserver`, `draggable_scrollbar`).

## Integration Checklist

- Wire `onPickFiles` / repository calls with actual APIs.
- Inject analytics hooks or logging via the controller listeners.
- Monitor memory in profile builds; adjust `pageSize`, `keepPagesInMemory`, and `cacheExtent` accordingly.
- Write widget tests for your concrete item builder to ensure empties/errors render as expected.
