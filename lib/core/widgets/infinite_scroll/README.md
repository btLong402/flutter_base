# Infinite Scroll Widgets

A modular, high-performance infinite scrolling system that works in both Material and Cupertino UI stacks. It supports huge datasets (5,000+ items), smooth animations, refresh controls, and paging helpers while remaining memory conscious.

## Modules

- `infinite_scroll.dart` – umbrella export for the widget suite.
- `pagination_controller.dart` – load/refresh/retry logic with debouncing, deduplication, and page caching.
- `infinite_scroll_view.dart` – renders list/grid layouts as either `ListView`/`GridView` or a `CustomScrollView` with slivers.
- `refresh_controls.dart` – material (`RefreshIndicator`) and Cupertino (`CupertinoSliverRefreshControl`) pull-to-refresh wrappers.
- `load_more_footer.dart` – animated loading/error/end-of-list footer.
- `performance_utils.dart` – tuning constants and helpers (`shouldTriggerLoadMore`, `resolveCacheExtent`).
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
  sliverAppBar: SliverAppBar(
    pinned: true,
    floating: false,
    expandedHeight: 120,
    flexibleSpace: FlexibleSpaceBar(title: const Text('Gallery')),
  ),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.75,
  ),
  separatorBuilder: (context, index) => const SizedBox.shrink(), // Optional row spacing cell.
  itemBuilder: (context, index, item) => MediaTile(item: item),
);
```

## Tuning Tips

- **Page size**: start with 20–30 items for text lists, 12–24 for media-heavy grids.
- **Cache extent**: default multiplies the viewport by 1.5; increase for aggressive prefetch, reduce to save memory.
- **Item extent**: supply when rows have fixed height to keep layout passes O(1).
- **Separators**: implement once via `separatorBuilder`; works for list/sliver/grid. In grid mode separators render as lightweight placeholder tiles—use a `SizedBox.shrink()` to disable per row, or an animated widget to create custom dividers.
- **Debounce**: raise `debounceDuration` if your backend enforces rate limits.
- **Keep-pages**: `keepPagesInMemory` drops oldest pages to cap RAM usage (default: 6 pages).
- **Prefetch**: use `onPageLoaded` to queue image/video thumbnail caching.

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
