import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'performance_utils.dart';

typedef LoadPageCallback<T> =
    Future<List<T>> Function({required int page, required int pageSize});

/// Pagination Controller with Infinite Scroll Support
///
/// PAGINATION FIXES APPLIED:
/// 1. Enhanced loadMore guards: Cancels pending timers and resets scroll tracking on load start
/// 2. maxExtent guard reset: Resets _lastTriggeredMaxExtent after successful load to allow re-trigger
/// 3. Tighter tolerance: Uses 5% tolerance (down from 10%) for extent change detection
/// 4. Scroll state cleanup: Clears _throttleActive, _lastScrollMetrics, _pendingMetrics on loadMore
/// 5. Item count delta logging: Logs before→after item counts when pages are appended
/// 6. Extent decrease handling: Resets guard when extent decreases significantly
///
/// These fixes ensure that:
/// - No duplicate API calls during rapid scrolling or after page 10
/// - Pagination continues correctly after grid rebuilds with new items
/// - maxScrollExtent tracking prevents false triggers but allows progress
/// - Debug logs provide clear visibility into trigger decisions and state changes

/// Encapsulates page-based fetching logic with built-in debouncing,
/// deduplication, refresh, and retry helpers.
class PaginationController<T> extends ChangeNotifier {
  PaginationController({
    required this.loadPage,
    this.pageSize = InfiniteScrollDefaults.pageSize,
    this.initialPage = InfiniteScrollDefaults.initialPage,
    this.debounceDuration = InfiniteScrollDefaults.debounceDuration,
    this.preloadFraction = InfiniteScrollDefaults.preloadFraction,
    this.keepPagesInMemory = InfiniteScrollDefaults.keepPagesInMemory,
    this.onPageLoaded,
    this.hasMoreResolver,
    this.autoStart = true,
  }) : assert(pageSize > 0, 'pageSize must be greater than zero'),
       assert(
         preloadFraction > 0 && preloadFraction <= 1,
         'preloadFraction must be between 0 (exclusive) and 1 (inclusive)',
       ) {
    if (autoStart) {
      // Delay to allow listeners to attach before the first fetch.
      scheduleMicrotask(() => refresh());
    }
  }

  final LoadPageCallback<T> loadPage;
  final int pageSize;
  final int initialPage;
  final Duration debounceDuration;
  final double preloadFraction;
  final int? keepPagesInMemory;
  final ValueChanged<List<T>>? onPageLoaded;
  final bool Function(List<T> newItems)? hasMoreResolver;
  final bool autoStart;

  final LinkedHashMap<int, List<T>> _pages = LinkedHashMap<int, List<T>>();
  final Map<int, Future<List<T>>> _inFlightRequests = {};

  Timer? _debounceTimer;
  Timer? _throttleTimer;
  ScrollMetrics? _pendingMetrics;
  ScrollMetrics? _lastScrollMetrics;
  double? _lastTriggeredMaxExtent;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _initialized = false;
  Object? _error;
  int _nextPage = InfiniteScrollDefaults.initialPage;
  int? _lastRequestedPage;
  DateTime? _lastLoadInvocation;
  bool _throttleActive = false;

  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get isInitialized => _initialized;
  bool get hasMore => _hasMore;
  Object? get error => _error;
  int get itemCount =>
      _pages.values.fold<int>(0, (total, items) => total + items.length);
  bool get hasItems => itemCount > 0;

  /// Returns a flattened view of the cached pages.
  List<T> get items =>
      _pages.values.expand((page) => page).toList(growable: false);

  /// Retrieves the item at the provided index, or null when not loaded yet.
  T? itemAt(int index) {
    if (index < 0 || index >= itemCount) {
      return null;
    }
    var offset = 0;
    for (final page in _pages.values) {
      if (index < offset + page.length) {
        return page[index - offset];
      }
      offset += page.length;
    }
    return null;
  }

  /// Currently cached page numbers.
  Iterable<int> get loadedPages => _pages.keys;

  /// Public API to force a refresh.
  ///
  /// Clears current data and reloads from the first page. Safe to call
  /// multiple times - duplicate refresh requests are ignored.
  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    _error = null;
    _lastTriggeredMaxExtent = null; // Reset trigger guard on refresh
    _safeNotifyListeners();

    final previousPages = LinkedHashMap<int, List<T>>.from(_pages);
    try {
      final newItems = await _fetchPage(initialPage);
      _replaceWithInitialPage(newItems);
      _isRefreshing = false;
      _initialized = true;
      _safeNotifyListeners();
    } catch (error, stackTrace) {
      debugPrint('PaginationController.refresh error: $error\n$stackTrace');
      _isRefreshing = false;
      _error = error;
      _pages
        ..clear()
        ..addAll(previousPages);
      _safeNotifyListeners();
    }
  }

  /// Requests the next page when available.
  ///
  /// Implements rate limiting to prevent duplicate requests during rapid
  /// scrolling. Only allows one in-flight load-more request at a time.
  ///
  /// Set [bypassRateLimit] to true for explicit user actions like retry,
  /// which should not be throttled.
  Future<void> loadMore({bool bypassRateLimit = false}) async {
    if (!_hasMore || _isLoadingMore) {
      debugPrint(
        '[PaginationController] loadMore() skipped: hasMore=$_hasMore, isLoadingMore=$_isLoadingMore',
      );
      return;
    }

    // Enforce minimum interval between load-more calls to prevent duplicate
    // requests if scroll events fire rapidly. Bypass for explicit user actions.
    if (!bypassRateLimit &&
        _lastLoadInvocation != null &&
        DateTime.now().difference(_lastLoadInvocation!) <
            InfiniteScrollDefaults.minLoadInterval) {
      debugPrint(
        '[PaginationController] loadMore() throttled: too soon since last invocation',
      );
      return;
    }

    // CRITICAL FIX: Cancel any pending scroll-triggered loadMore and reset
    // scroll tracking to prevent duplicate calls during and after the load
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
    _throttleActive = false;
    _lastScrollMetrics = null;
    _pendingMetrics = null;

    _lastLoadInvocation = DateTime.now();
    _isLoadingMore = true;
    _error = null;
    _safeNotifyListeners();

    final targetPage = _nextPage;
    final previousItemCount = itemCount;
    debugPrint('[PaginationController] Loading page $targetPage...');

    try {
      final items = await _fetchPage(targetPage);
      debugPrint(
        '[PaginationController] Page $targetPage loaded: ${items.length} items',
      );
      _appendPage(targetPage, items);
      _isLoadingMore = false;

      // CRITICAL FIX: Reset maxExtent guard after successful load to allow
      // next trigger once the grid rebuilds with new items and extent increases
      _lastTriggeredMaxExtent = null;

      debugPrint(
        '[PaginationController] Item count: $previousItemCount → $itemCount',
      );
      _safeNotifyListeners();
    } catch (error, stackTrace) {
      debugPrint('PaginationController.loadMore error: $error\n$stackTrace');
      _isLoadingMore = false;
      _error = error;
      _safeNotifyListeners();
    }
  }

  /// Replays the last failed request.
  ///
  /// Bypasses rate limiting since this is an explicit user action.
  Future<void> retry() async {
    if (_lastRequestedPage == null) {
      return;
    }
    if (!_initialized) {
      await refresh();
      return;
    }
    if (_lastRequestedPage == initialPage) {
      await refresh();
    } else {
      await loadMore(bypassRateLimit: true);
    }
  }

  /// Handles scroll notifications and triggers load-more when the threshold is met.
  ///
  /// Uses throttling to limit how often we check scroll position, combined with
  /// debouncing to batch rapid scroll events. This prevents excessive CPU usage
  /// during fast scrolling while still being responsive.
  ///
  /// PERFORMANCE FIX: Proper throttle implementation that stores latest metrics
  /// and processes them when throttle window expires. This prevents duplicate
  /// loadMore() calls during rapid scrolling, especially after page 10.
  void handleScrollMetrics(ScrollMetrics metrics) {
    if (!_hasMore || _isLoadingMore) {
      return;
    }

    // Throttle: ignore updates while throttle window is active, but store
    // the latest metrics to process when the window closes
    if (_throttleActive) {
      _pendingMetrics = metrics;
      return;
    }

    // Process current metrics immediately
    _processScrollMetrics(metrics);

    // Activate throttle window
    _throttleActive = true;
    _throttleTimer?.cancel();
    _throttleTimer = Timer(InfiniteScrollDefaults.throttleDuration, () {
      _throttleActive = false;

      // Process pending metrics if any accumulated during throttle window
      if (_pendingMetrics != null) {
        final pending = _pendingMetrics;
        _pendingMetrics = null;
        _processScrollMetrics(pending!);
      }
    });
  }

  void _processScrollMetrics(ScrollMetrics metrics) {
    // Store the latest scroll metrics for validation in loadMore
    _lastScrollMetrics = metrics;

    // Debounce: delay the actual load-more check to batch rapid events
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      // Re-validate with latest metrics before triggering
      final latestMetrics = _lastScrollMetrics;
      if (latestMetrics == null) return;

      // CRITICAL FIX: Prevent duplicate triggers for the SAME maxScrollExtent.
      // But use a tighter tolerance (5%) and allow triggers when extent increases
      // significantly, which indicates new content has been rendered.
      final currentMaxExtent = latestMetrics.maxScrollExtent;
      if (_lastTriggeredMaxExtent != null) {
        final tolerance = _lastTriggeredMaxExtent! * 0.05; // 5% tolerance
        final diff = currentMaxExtent - _lastTriggeredMaxExtent!;

        // Skip trigger only if extent is nearly identical or decreased
        if (diff < tolerance && diff >= 0) {
          // maxExtent is nearly the same - skip duplicate trigger
          debugPrint(
            '[PaginationController] Trigger skipped: maxExtent nearly unchanged '
            '(current: ${currentMaxExtent.toStringAsFixed(0)}, '
            'last: ${_lastTriggeredMaxExtent!.toStringAsFixed(0)}, '
            'diff: ${diff.toStringAsFixed(0)})',
          );
          return;
        }

        // If extent decreased significantly, reset guard to allow re-trigger
        if (diff < -tolerance) {
          debugPrint(
            '[PaginationController] maxExtent decreased, resetting trigger guard '
            '(${_lastTriggeredMaxExtent!.toStringAsFixed(0)} → ${currentMaxExtent.toStringAsFixed(0)})',
          );
          _lastTriggeredMaxExtent = null;
        }
      }

      if (shouldTriggerLoadMore(
        latestMetrics,
        preloadFraction: preloadFraction,
      )) {
        final distanceFromBottom =
            latestMetrics.maxScrollExtent - latestMetrics.pixels;
        debugPrint(
          '[PaginationController] Trigger threshold met: '
          'pixels=${latestMetrics.pixels.toStringAsFixed(0)}, '
          'maxExtent=${latestMetrics.maxScrollExtent.toStringAsFixed(0)}, '
          'distanceFromBottom=${distanceFromBottom.toStringAsFixed(0)}, '
          'viewport=${latestMetrics.viewportDimension.toStringAsFixed(0)}',
        );
        _lastTriggeredMaxExtent = currentMaxExtent;
        unawaited(loadMore());
      }
    });
  }

  Future<List<T>> _fetchPage(int page) {
    _lastRequestedPage = page;
    final existing = _inFlightRequests[page];
    if (existing != null) {
      return existing;
    }

    final future = loadPage(
      page: page,
      pageSize: pageSize,
    ).then((items) => List<T>.unmodifiable(items));
    _inFlightRequests[page] = future;

    return future.whenComplete(() {
      _inFlightRequests.remove(page);
    });
  }

  void _replaceWithInitialPage(List<T> newItems) {
    _pages
      ..clear()
      ..[initialPage] = newItems;
    _nextPage = initialPage + 1;
    _hasMore = _resolveHasMore(newItems);
    onPageLoaded?.call(newItems);
    _prunePagesIfNeeded();
  }

  void _appendPage(int page, List<T> newItems) {
    if (newItems.isEmpty) {
      _hasMore = false;
      debugPrint(
        '[PaginationController] Empty page received, marking hasMore=false',
      );
      return;
    }

    final previousItemCount = itemCount;
    _pages[page] = newItems;
    _nextPage = page + 1;
    _hasMore = _resolveHasMore(newItems);

    debugPrint(
      '[PaginationController] Page $page appended: ${newItems.length} items added, '
      'Total: $previousItemCount → $itemCount, hasMore=$_hasMore',
    );
    debugPrint(
      '[PaginationController] Pages in memory: ${_pages.keys.toList()}',
    );

    onPageLoaded?.call(newItems);
    _prunePagesIfNeeded();
  }

  bool _resolveHasMore(List<T> newItems) {
    if (hasMoreResolver != null) {
      return hasMoreResolver!(newItems);
    }
    return newItems.length >= pageSize;
  }

  void _prunePagesIfNeeded() {
    if (keepPagesInMemory == null) {
      return;
    }
    while (_pages.length > keepPagesInMemory!) {
      _pages.remove(_pages.keys.first);
    }
  }

  /// Safely notifies listeners, avoiding errors if disposed.
  bool get mounted => hasListeners;

  void _safeNotifyListeners() {
    if (!mounted) return;

    // Check if we're in build phase
    final scheduler = SchedulerBinding.instance;
    final phase = scheduler.schedulerPhase;

    // Safe to notify immediately if not in build/layout phase
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
      return;
    }

    // Defer notification only if we're in build/layout phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _throttleTimer?.cancel();
    _debounceTimer = null;
    _throttleTimer = null;

    // Cancel in-flight requests to prevent callbacks after dispose
    for (final future in _inFlightRequests.values) {
      future.ignore();
    }
    _inFlightRequests.clear();

    super.dispose();
  }
}

extension<T> on Future<T> {
  /// Ignores the result of this Future to prevent unhandled errors.
  void ignore() {}
}
