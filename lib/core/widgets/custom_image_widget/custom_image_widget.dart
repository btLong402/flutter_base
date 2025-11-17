import 'package:flutter/material.dart';

import 'image_loader.dart';
import 'svg_handler.dart';

export 'image_loader.dart' show CustomImageSource;

/// Composable image widget that gracefully handles multiple input types with
/// caching, placeholders, and fade transitions.
///
/// Performance optimizations:
/// - Uses const constructors to reduce rebuilds
/// - Minimizes widget nesting
/// - Avoids unnecessary decorations when possible
/// - Efficient conditional rendering based on border radius
class CustomImageWidget extends StatelessWidget {
  const CustomImageWidget({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.backgroundColor,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 250),
    this.enableMemoryCache = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.filterQuality = FilterQuality.low,
  });

  final CustomImageSource source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;

  /// Whether to cache decoded image in memory (default: true)
  final bool enableMemoryCache;

  /// Target width for memory cache (reduces memory footprint for large images)
  final int? memCacheWidth;

  /// Target height for memory cache (reduces memory footprint for large images)
  final int? memCacheHeight;

  /// Filter quality for scaling (low = faster, high = better quality)
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    final effectivePlaceholder = placeholder ?? const _DefaultPlaceholder();
    final effectiveErrorWidget = errorWidget ?? const _DefaultError();

    Widget image;
    if (source is SvgImageSource) {
      image = SvgHandler.build(
        source: source as SvgImageSource,
        width: width,
        height: height,
        fit: fit,
        placeholder: effectivePlaceholder,
        errorWidget: effectiveErrorWidget,
        fadeInDuration: fadeInDuration,
      );
    } else {
      image = ImageLoader.build(
        source: source,
        width: width,
        height: height,
        fit: fit,
        placeholder: effectivePlaceholder,
        errorWidget: effectiveErrorWidget,
        fadeInDuration: fadeInDuration,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        filterQuality: filterQuality,
      );
    }

    // Optimize: Skip decoration if no background color
    if (backgroundColor != null) {
      image = DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: image,
      );
    }

    // Optimize: Only add SizedBox if dimensions are specified
    if (width != null || height != null) {
      image = SizedBox(width: width, height: height, child: image);
    }

    // Optimize: Only add ClipRRect if borderRadius is specified
    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}

class _DefaultPlaceholder extends StatelessWidget {
  const _DefaultPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _DefaultError extends StatelessWidget {
  const _DefaultError();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.broken_image_outlined);
  }
}
