import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../custom_image_widget/custom_image_widget.dart';

/// Determines how the gallery should lay out its content by default.
enum GalleryDisplayMode { grid, carousel }

/// Categorises the type of media a gallery item represents.
enum GalleryMediaType { image, video }

/// Reusable model that encapsulates an image or video entry for the gallery.
class GalleryMediaItem {
  const GalleryMediaItem.image({
    required this.imageSource,
    this.thumbnailSource,
    this.heroTag,
    this.metadata,
  }) : type = GalleryMediaType.image,
       videoSource = null;

  const GalleryMediaItem.video({
    required this.videoSource,
    this.thumbnailSource,
    this.heroTag,
    this.metadata,
  }) : type = GalleryMediaType.video,
       imageSource = null;

  final GalleryMediaType type;
  final CustomImageSource? imageSource;
  final CustomImageSource? thumbnailSource;
  final GalleryVideoSource? videoSource;
  final String? heroTag;
  final Map<String, Object?>? metadata;

  bool get isVideo => type == GalleryMediaType.video;
}

/// Shared cache manager dedicated to gallery media downloads.
class GalleryCacheManager extends CacheManager {
  GalleryCacheManager._()
    : super(
        Config(
          'custom_gallery_widget_cache',
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 150,
        ),
      );

  static final GalleryCacheManager instance = GalleryCacheManager._();
}

/// Unified description of where a video should be loaded from.
abstract class GalleryVideoSource {
  const GalleryVideoSource();

  const factory GalleryVideoSource.network(
    String url, {
    Map<String, String>? headers,
    BaseCacheManager? cacheManager,
  }) = NetworkGalleryVideoSource;

  const factory GalleryVideoSource.asset(String assetPath, {String? package}) =
      AssetGalleryVideoSource;

  const factory GalleryVideoSource.file(File file) = FileGalleryVideoSource;
}

class NetworkGalleryVideoSource extends GalleryVideoSource {
  const NetworkGalleryVideoSource(this.url, {this.headers, this.cacheManager})
    : super();

  final String url;
  final Map<String, String>? headers;
  final BaseCacheManager? cacheManager;
}

class AssetGalleryVideoSource extends GalleryVideoSource {
  const AssetGalleryVideoSource(this.assetPath, {this.package}) : super();

  final String assetPath;
  final String? package;
}

class FileGalleryVideoSource extends GalleryVideoSource {
  const FileGalleryVideoSource(this.file) : super();

  final File file;
}
