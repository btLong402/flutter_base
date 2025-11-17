import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'image_loader.dart';

/// Handles loading and rendering logic for SVG-based sources.
///
/// Performance optimizations:
/// - Uses PictureProvider for efficient SVG caching
/// - Minimizes rebuilds with proper const usage
class SvgHandler {
  const SvgHandler._();

  static Widget build({
    required SvgImageSource source,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    required Widget placeholder,
    required Widget errorWidget,
    Duration fadeInDuration = const Duration(milliseconds: 250),
  }) {
    if (source is SvgAssetImageSource) {
      // Optimize: Use SvgPicture.asset directly for better performance
      return _buildSvgAsset(
        assetPath: source.assetPath,
        package: source.package,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
        fadeInDuration: fadeInDuration,
      );
    }

    throw UnsupportedError('Unsupported SVG source: ${source.runtimeType}');
  }

  static Widget _buildSvgAsset({
    required String assetPath,
    required String? package,
    required double? width,
    required double? height,
    required BoxFit fit,
    required Widget placeholder,
    required Widget errorWidget,
    required Duration fadeInDuration,
  }) {
    // Optimize: Use SvgPicture.asset which has built-in caching
    // and is more efficient than loading string and using SvgPicture.string
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      package: package,
      // Optimize: Use placeholderBuilder for better performance
      placeholderBuilder: (context) =>
          buildSizedChild(width: width, height: height, child: placeholder),
    );
  }
}
