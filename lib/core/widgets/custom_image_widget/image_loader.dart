import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'cache_manager.dart';

/// Describes how the widget should retrieve and render an image.
abstract class CustomImageSource {
  const CustomImageSource();

  const factory CustomImageSource.network(
    String url, {
    Map<String, String>? headers,
    BaseCacheManager? cacheManager,
  }) = NetworkImageSource;

  const factory CustomImageSource.asset(String assetPath, {String? package}) =
      AssetImageSource;

  const factory CustomImageSource.file(File file) = FileImageSource;

  const factory CustomImageSource.svgAsset(
    String assetPath, {
    String? package,
  }) = SvgAssetImageSource;
}

/// Source representation for network images.
class NetworkImageSource extends CustomImageSource {
  const NetworkImageSource(this.url, {this.headers, this.cacheManager})
    : super();

  final String url;
  final Map<String, String>? headers;
  final BaseCacheManager? cacheManager;
}

/// Source representation for raster assets bundled with the app.
class AssetImageSource extends CustomImageSource {
  const AssetImageSource(this.assetPath, {this.package}) : super();

  final String assetPath;
  final String? package;
}

/// Source representation for images stored in the local file system.
class FileImageSource extends CustomImageSource {
  const FileImageSource(this.file) : super();

  final File file;
}

/// Base type for SVG-backed sources.
abstract class SvgImageSource extends CustomImageSource {
  const SvgImageSource() : super();
}

/// Source representation for SVG assets bundled with the app.
class SvgAssetImageSource extends SvgImageSource {
  const SvgAssetImageSource(this.assetPath, {this.package}) : super();

  final String assetPath;
  final String? package;
}

/// Responsible for resolving the correct widget given a source type.
///
/// Performance optimizations:
/// - Memory cache width/height to reduce memory footprint
/// - FilterQuality control for performance/quality trade-off
/// - Efficient image decoding and caching
class ImageLoader {
  const ImageLoader._();

  static Widget build({
    required CustomImageSource source,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    required Widget placeholder,
    required Widget errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 250),
    int? memCacheWidth,
    int? memCacheHeight,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    if (source is NetworkImageSource) {
      return _buildNetwork(
        source: source,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
        fadeInDuration: fadeInDuration,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        filterQuality: filterQuality,
      );
    }

    if (source is AssetImageSource) {
      return _buildAsset(
        source: source,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
        fadeInDuration: fadeInDuration,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        filterQuality: filterQuality,
      );
    }

    if (source is FileImageSource) {
      return _buildFile(
        source: source,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
        fadeInDuration: fadeInDuration,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        filterQuality: filterQuality,
      );
    }

    throw UnsupportedError('Unsupported source type: ${source.runtimeType}');
  }

  static Widget _buildNetwork({
    required NetworkImageSource source,
    double? width,
    double? height,
    required BoxFit fit,
    required Widget placeholder,
    required Widget errorWidget,
    required Duration fadeInDuration,
    int? memCacheWidth,
    int? memCacheHeight,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return CachedNetworkImage(
      imageUrl: source.url,
      width: width,
      height: height,
      fit: fit,
      cacheManager: source.cacheManager ?? CustomImageCacheManager.instance,
      httpHeaders: source.headers,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 150),
      // Memory cache optimization: reduce memory footprint for large images
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      // FilterQuality.low is faster and sufficient for most cases
      filterQuality: filterQuality,
      // Optimize: use const placeholder wrapper
      placeholder: (_, __) =>
          buildSizedChild(width: width, height: height, child: placeholder),
      errorWidget: (_, __, ___) =>
          buildSizedChild(width: width, height: height, child: errorWidget),
    );
  }

  static Widget _buildAsset({
    required AssetImageSource source,
    double? width,
    double? height,
    required BoxFit fit,
    required Widget placeholder,
    required Widget errorWidget,
    required Duration fadeInDuration,
    int? memCacheWidth,
    int? memCacheHeight,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image.asset(
      source.assetPath,
      width: width,
      height: height,
      fit: fit,
      package: source.package,
      // Memory cache optimization
      cacheWidth: memCacheWidth,
      cacheHeight: memCacheHeight,
      filterQuality: filterQuality,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return FadeInWrapper(duration: fadeInDuration, child: child);
        }
        return buildSizedChild(
          width: width,
          height: height,
          child: placeholder,
        );
      },
      errorBuilder: (context, _, __) =>
          buildSizedChild(width: width, height: height, child: errorWidget),
    );
  }

  static Widget _buildFile({
    required FileImageSource source,
    double? width,
    double? height,
    required BoxFit fit,
    required Widget placeholder,
    required Widget errorWidget,
    required Duration fadeInDuration,
    int? memCacheWidth,
    int? memCacheHeight,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return Image.file(
      source.file,
      width: width,
      height: height,
      fit: fit,
      // Memory cache optimization
      cacheWidth: memCacheWidth,
      cacheHeight: memCacheHeight,
      filterQuality: filterQuality,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return FadeInWrapper(duration: fadeInDuration, child: child);
        }
        return buildSizedChild(
          width: width,
          height: height,
          child: placeholder,
        );
      },
      errorBuilder: (context, _, __) =>
          buildSizedChild(width: width, height: height, child: errorWidget),
    );
  }
}

/// Keeps placeholder, error, and result widgets within consistent bounds.
Widget buildSizedChild({double? width, double? height, required Widget child}) {
  return SizedBox(
    width: width,
    height: height,
    child: Center(child: child),
  );
}

/// Provides a simple fade-in effect once an image frame has been decoded.
///
/// Performance optimization: Uses TweenAnimationBuilder with child parameter
/// to avoid rebuilding the child widget during animation.
class FadeInWrapper extends StatelessWidget {
  const FadeInWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      // Optimize: child parameter prevents rebuilding child during animation
      child: child,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
    );
  }
}
