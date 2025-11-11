import 'package:flutter/material.dart';
import 'dart:async';
import 'feature_intro_models.dart';
import 'feature_tooltip_widget.dart';
import 'feature_highlight_painter.dart';

/// Main feature intro widget that shows tooltips for UI elements
class FeatureIntroWidget extends StatefulWidget {
  const FeatureIntroWidget({
    super.key,
    required this.features,
    required this.onComplete,
    this.onSkip,
    this.config = const FeatureIntroConfig(),
  }) : assert(features.length > 0, 'At least one feature must be provided');

  final List<FeatureIntroData> features;
  final VoidCallback onComplete;
  final VoidCallback? onSkip;
  final FeatureIntroConfig config;

  @override
  State<FeatureIntroWidget> createState() => _FeatureIntroWidgetState();
}

class _FeatureIntroWidgetState extends State<FeatureIntroWidget>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Rect? _targetRect;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: widget.config.pulseDuration,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.config.pulseAnimation) {
      _pulseController.repeat(reverse: true);
    }

    // Wait for the frame to complete before getting target rect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetRect();
      if (widget.config.autoPlayDuration != null) {
        _startAutoPlay();
      }
    });
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer(widget.config.autoPlayDuration!, () {
      if (mounted) {
        _nextFeature();
      }
    });
  }

  void _updateTargetRect() {
    final currentFeature = widget.features[_currentIndex];
    final renderBox =
        currentFeature.targetKey.currentContext?.findRenderObject()
            as RenderBox?;

    if (renderBox != null && mounted) {
      final offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      setState(() {
        _targetRect = Rect.fromLTWH(
          offset.dx,
          offset.dy,
          size.width,
          size.height,
        );
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _nextFeature() {
    if (_currentIndex < widget.features.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _updateTargetRect();
      if (widget.config.autoPlayDuration != null) {
        _startAutoPlay();
      }
    } else {
      _complete();
    }
  }

  void _complete() {
    _autoPlayTimer?.cancel();
    widget.onComplete();
  }

  void _skip() {
    _autoPlayTimer?.cancel();
    if (widget.onSkip != null) {
      widget.onSkip!();
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null) {
      return const SizedBox.shrink();
    }

    final currentFeature = widget.features[_currentIndex];
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: widget.config.enableTapToDismiss ? _skip : null,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Overlay with highlight
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: screenSize,
                  painter: FeatureHighlightPainter(
                    targetRect: _targetRect!,
                    shape: currentFeature.shape,
                    overlayColor: widget.config.overlayColor,
                    highlightColor:
                        currentFeature.highlightColor ??
                        Theme.of(context).primaryColor,
                    padding: widget.config.highlightPadding,
                    pulseAnimation: widget.config.pulseAnimation
                        ? _pulseAnimation.value
                        : 1.0,
                  ),
                );
              },
            ),

            // Tooltip
            _buildTooltip(context, currentFeature, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(
    BuildContext context,
    FeatureIntroData feature,
    Size screenSize,
  ) {
    // Create a temporary widget to measure tooltip size
    final tooltipWidget = FeatureTooltipWidget(
      data: feature,
      currentStep: _currentIndex,
      totalSteps: widget.features.length,
      onNext: _nextFeature,
      onSkip: _skip,
      config: widget.config,
    );

    // Estimate tooltip size (you might want to measure this more accurately)
    const estimatedTooltipSize = Size(280, 200);

    final tooltipPosition = TooltipPositionCalculator.calculate(
      targetRect: _targetRect!,
      tooltipSize: estimatedTooltipSize,
      screenSize: screenSize,
      position: feature.position,
    );

    return Positioned(
      left: tooltipPosition.dx,
      top: tooltipPosition.dy,
      child: tooltipWidget,
    );
  }
}

/// Helper function to show feature intro
Future<void> showFeatureIntro({
  required BuildContext context,
  required List<FeatureIntroData> features,
  VoidCallback? onComplete,
  VoidCallback? onSkip,
  FeatureIntroConfig config = const FeatureIntroConfig(),
}) async {
  return showDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: config.enableTapToDismiss,
    builder: (context) => FeatureIntroWidget(
      features: features,
      config: config,
      onComplete: () {
        Navigator.of(context).pop();
        onComplete?.call();
      },
      onSkip: () {
        Navigator.of(context).pop();
        onSkip?.call();
      },
    ),
  );
}
