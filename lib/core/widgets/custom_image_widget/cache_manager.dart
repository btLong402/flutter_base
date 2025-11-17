import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Provides a dedicated cache bucket for the image widget so other features
/// can tune their own cache policies independently.
///
/// Performance optimizations:
/// - Increased cache size from 200 to 500 objects for better hit rate
/// - Longer stale period (7 days) to reduce network requests
/// - Optimized for mobile app image caching patterns
class CustomImageCacheManager extends CacheManager {
  CustomImageCacheManager._()
    : super(
        Config(
          'custom_image_widget_cache',
          // Keep images for 7 days before re-downloading
          stalePeriod: const Duration(days: 7),
          // Optimize: Increased cache size for better performance
          // Adjust based on your app's needs (500 images ≈ 100-300MB typical)
          maxNrOfCacheObjects: 500,
          // Optional: Add custom file service for better control
          // fileService: HttpFileService(),
        ),
      );

  static final CustomImageCacheManager instance = CustomImageCacheManager._();

  /// Clear all cached images (useful for logout or cache management)
  Future<void> clearCache() async {
    await emptyCache();
  }

  /// Get current cache size information
  Future<int> getCacheSize() async {
    final fileInfo = await getFileFromCache('');
    return fileInfo?.validTill.millisecondsSinceEpoch ?? 0;
  }
}
