import 'package:flutter/widgets.dart';

/// Shared performance tuning constants for the infinite scroll widgets.
class InfiniteScrollDefaults {
  static const int pageSize = 20;
  static const int initialPage = 1;
  static const int keepPagesInMemory = 6;
  static const double preloadFraction = 0.8;
  static const double cacheExtentMultiplier = 1.5;
  static const Duration debounceDuration = Duration(milliseconds: 350);
  static const Duration throttleDuration = Duration(milliseconds: 320);
}

/// Returns true when the scroll position is close enough to the end of the
/// content to trigger the next page load.
bool shouldTriggerLoadMore(
  ScrollMetrics metrics, {
  double preloadFraction = InfiniteScrollDefaults.preloadFraction,
}) {
  if (!metrics.hasPixels || metrics.maxScrollExtent == double.infinity) {
    return false;
  }
  if (metrics.maxScrollExtent == 0) {
    return true;
  }
  final threshold = metrics.maxScrollExtent * preloadFraction;
  return metrics.pixels >= threshold;
}

/// Convenience helper to clamp cache extent to positive values only.
double resolveCacheExtent(double? cacheExtent, double viewportDimension) {
  if (cacheExtent == null) {
    return viewportDimension * InfiniteScrollDefaults.cacheExtentMultiplier;
  }
  return cacheExtent.clamp(0, double.infinity);
}
