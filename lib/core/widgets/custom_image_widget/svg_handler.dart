import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'image_loader.dart';

/// Handles loading and rendering logic for SVG-based sources.
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
      return _SvgAssetLoader(
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
}

class _SvgAssetLoader extends StatefulWidget {
  const _SvgAssetLoader({
    required this.assetPath,
    required this.package,
    required this.width,
    required this.height,
    required this.fit,
    required this.placeholder,
    required this.errorWidget,
    required this.fadeInDuration,
  });

  final String assetPath;
  final String? package;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget placeholder;
  final Widget errorWidget;
  final Duration fadeInDuration;

  @override
  State<_SvgAssetLoader> createState() => _SvgAssetLoaderState();
}

class _SvgAssetLoaderState extends State<_SvgAssetLoader> {
  late final Future<String> _svgFuture;

  @override
  void initState() {
    super.initState();
    final key = widget.package != null
        ? 'packages/${widget.package}/${widget.assetPath}'
        : widget.assetPath;

    _svgFuture = rootBundle.loadString(key);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _svgFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildSizedChild(
            width: widget.width,
            height: widget.height,
            child: widget.placeholder,
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return buildSizedChild(
            width: widget.width,
            height: widget.height,
            child: widget.errorWidget,
          );
        }

        return FadeInWrapper(
          duration: widget.fadeInDuration,
          child: SvgPicture.string(
            snapshot.data!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          ),
        );
      },
    );
  }
}
