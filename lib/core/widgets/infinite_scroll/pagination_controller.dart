import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'performance_utils.dart';

typedef LoadPageCallback<T> =
    Future<List<T>> Function({required int page, required int pageSize});

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
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _initialized = false;
  Object? _error;
  int _nextPage = InfiniteScrollDefaults.initialPage;
  int? _lastRequestedPage;
  DateTime? _lastLoadInvocation;

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
  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    _error = null;
    notifyListeners();

    final previousPages = LinkedHashMap<int, List<T>>.from(_pages);
    try {
      final newItems = await _fetchPage(initialPage);
      _replaceWithInitialPage(newItems);
      _isRefreshing = false;
      _initialized = true;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('PaginationController.refresh error: $error\n$stackTrace');
      _isRefreshing = false;
      _error = error;
      _pages
        ..clear()
        ..addAll(previousPages);
      notifyListeners();
    }
  }

  /// Requests the next page when available.
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) {
      return;
    }
    if (_lastLoadInvocation != null &&
        DateTime.now().difference(_lastLoadInvocation!) < debounceDuration) {
      return;
    }
    _lastLoadInvocation = DateTime.now();
    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    final targetPage = _nextPage;
    try {
      final items = await _fetchPage(targetPage);
      _appendPage(targetPage, items);
      _isLoadingMore = false;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('PaginationController.loadMore error: $error\n$stackTrace');
      _isLoadingMore = false;
      _error = error;
      notifyListeners();
    }
  }

  /// Replays the last failed request.
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
      await loadMore();
    }
  }

  /// Handles scroll notifications and triggers load-more when the threshold is met.
  void handleScrollMetrics(ScrollMetrics metrics) {
    if (!_hasMore || _isLoadingMore) {
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      if (shouldTriggerLoadMore(metrics, preloadFraction: preloadFraction)) {
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
      return;
    }
    _pages[page] = newItems;
    _nextPage = page + 1;
    _hasMore = _resolveHasMore(newItems);
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (final future in _inFlightRequests.values) {
      future.ignore();
    }
    super.dispose();
  }
}

extension<T> on Future<T> {
  void ignore() {}
}
