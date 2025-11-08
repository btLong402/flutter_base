import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Provides a dedicated cache bucket for the image widget so other features
/// can tune their own cache policies independently.
class CustomImageCacheManager extends CacheManager {
  CustomImageCacheManager._()
    : super(
        Config(
          'custom_image_widget_cache',
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 200,
        ),
      );

  static final CustomImageCacheManager instance = CustomImageCacheManager._();
}
