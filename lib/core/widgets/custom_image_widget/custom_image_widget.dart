import 'package:flutter/material.dart';

import 'image_loader.dart';
import 'svg_handler.dart';

export 'image_loader.dart' show CustomImageSource;

/// Composable image widget that gracefully handles multiple input types with
/// caching, placeholders, and fade transitions.
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
      );
    }

    final decorated = DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor ?? Colors.transparent),
      child: image,
    );

    final sized = SizedBox(width: width, height: height, child: decorated);

    if (borderRadius == null) {
      return sized;
    }

    return ClipRRect(borderRadius: borderRadius!, child: sized);
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
