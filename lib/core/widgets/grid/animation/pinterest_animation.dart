import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Pinterest-style animation configuration with staggered fade, scale, and slide effects.
///
/// This creates the signature Pinterest appearance animation:
/// - Items fade in from 0 to 1 opacity
/// - Subtle scale from 0.94 to 1.0
/// - Slide up from below
/// - Staggered timing based on index
///
/// **Performance optimized:**
/// - Uses RenderLayer animations (FadeTransition, ScaleTransition, SlideTransition)
/// - Minimal widget rebuilds via AnimatedBuilder
/// - Automatic disposal to prevent memory leaks
class PinterestGridAnimationConfig {
  const PinterestGridAnimationConfig._({
    required this.builder,
    this.mode = PinterestAnimationMode.staggeredFade,
  });

  final Widget Function(BuildContext context, int index, Widget child) builder;
  final PinterestAnimationMode mode;

  Widget wrap(BuildContext context, int index, Widget child) =>
      builder(context, index, child);

  /// No animation - items appear immediately
  factory PinterestGridAnimationConfig.none() =>
      const PinterestGridAnimationConfig._(
        builder: _noAnimation,
        mode: PinterestAnimationMode.none,
      );

  /// Classic Pinterest animation: staggered fade + scale + slide
  ///
  /// **Parameters:**
  /// - [duration]: Animation duration per item (default: 280ms, Pinterest-like)
  /// - [curve]: Easing curve (default: easeOutCubic for natural deceleration)
  /// - [staggerDelay]: Base delay between items (default: 25ms)
  /// - [maxStagger]: Maximum stagger delay (default: 200ms to avoid long waits)
  /// - [fadeFrom]: Initial opacity (default: 0.0)
  /// - [scaleFrom]: Initial scale (default: 0.94 for subtle effect)
  /// - [slideOffset]: Vertical slide distance (default: 24px)
  factory PinterestGridAnimationConfig.staggeredFade({
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
    Duration staggerDelay = const Duration(milliseconds: 25),
    Duration maxStagger = const Duration(milliseconds: 200),
    double fadeFrom = 0.0,
    double scaleFrom = 0.94,
    double slideOffset = 24.0,
  }) {
    return PinterestGridAnimationConfig._(
      mode: PinterestAnimationMode.staggeredFade,
      builder: (context, index, child) => _PinterestItemAnimator(
        duration: duration,
        curve: curve,
        delay: Duration(
          milliseconds: math.min(
            maxStagger.inMilliseconds,
            (index % 20) * staggerDelay.inMilliseconds,
          ),
        ),
        fadeFrom: fadeFrom,
        scaleFrom: scaleFrom,
        slideOffset: slideOffset,
        child: child,
      ),
    );
  }

  /// Fade-only animation (faster, less CPU usage)
  factory PinterestGridAnimationConfig.fadeOnly({
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOut,
    Duration staggerDelay = const Duration(milliseconds: 20),
    double fadeFrom = 0.0,
  }) {
    return PinterestGridAnimationConfig._(
      mode: PinterestAnimationMode.fadeOnly,
      builder: (context, index, child) => _PinterestItemAnimator(
        duration: duration,
        curve: curve,
        delay: Duration(
          milliseconds: (index % 20) * staggerDelay.inMilliseconds,
        ),
        fadeFrom: fadeFrom,
        scaleFrom: 1.0, // No scale
        slideOffset: 0.0, // No slide
        child: child,
      ),
    );
  }

  /// Scale-only animation (subtle, modern feel)
  factory PinterestGridAnimationConfig.scaleOnly({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
    Duration staggerDelay = const Duration(milliseconds: 30),
    double scaleFrom = 0.85,
  }) {
    return PinterestGridAnimationConfig._(
      mode: PinterestAnimationMode.scaleOnly,
      builder: (context, index, child) => _PinterestItemAnimator(
        duration: duration,
        curve: curve,
        delay: Duration(
          milliseconds: (index % 20) * staggerDelay.inMilliseconds,
        ),
        fadeFrom: 1.0, // No fade
        scaleFrom: scaleFrom,
        slideOffset: 0.0, // No slide
        child: child,
      ),
    );
  }

  /// Slide-only animation (directional, spatial awareness)
  factory PinterestGridAnimationConfig.slideOnly({
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeOutCubic,
    Duration staggerDelay = const Duration(milliseconds: 25),
    double slideOffset = 32.0,
  }) {
    return PinterestGridAnimationConfig._(
      mode: PinterestAnimationMode.slideOnly,
      builder: (context, index, child) => _PinterestItemAnimator(
        duration: duration,
        curve: curve,
        delay: Duration(
          milliseconds: (index % 20) * staggerDelay.inMilliseconds,
        ),
        fadeFrom: 1.0, // No fade
        scaleFrom: 1.0, // No scale
        slideOffset: slideOffset,
        child: child,
      ),
    );
  }
}

enum PinterestAnimationMode {
  none,
  staggeredFade,
  fadeOnly,
  scaleOnly,
  slideOnly,
}

Widget _noAnimation(BuildContext context, int index, Widget child) => child;

/// Internal animator widget that manages Pinterest-style entrance animations.
///
/// **Performance optimizations:**
/// - SingleTickerProviderStateMixin for single animation controller
/// - AutomaticKeepAliveClientMixin to preserve state during scrolling
/// - Render layer animations (no widget rebuilds)
/// - Proper disposal to prevent leaks
class _PinterestItemAnimator extends StatefulWidget {
  const _PinterestItemAnimator({
    required this.duration,
    required this.curve,
    required this.delay,
    required this.fadeFrom,
    required this.scaleFrom,
    required this.slideOffset,
    required this.child,
  });

  final Duration duration;
  final Curve curve;
  final Duration delay;
  final double fadeFrom;
  final double scaleFrom;
  final double slideOffset;
  final Widget child;

  @override
  State<_PinterestItemAnimator> createState() => _PinterestItemAnimatorState();
}

class _PinterestItemAnimatorState extends State<_PinterestItemAnimator>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _curve = CurvedAnimation(parent: _controller, curve: widget.curve);

    // Create interpolations for each animation type
    _opacity = Tween<double>(begin: widget.fadeFrom, end: 1.0).animate(_curve);

    _scale = Tween<double>(begin: widget.scaleFrom, end: 1.0).animate(_curve);

    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100), // Normalized offset
      end: Offset.zero,
    ).animate(_curve);

    // Start animation after delay
    _scheduleAnimation();
  }

  void _scheduleAnimation() {
    if (widget.delay.inMilliseconds > 0) {
      Future<void>.delayed(widget.delay, () {
        if (mounted && !_hasStarted) {
          _hasStarted = true;
          _controller.forward();
        }
      });
    } else {
      _hasStarted = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Compose animations (order matters for visual quality)
    Widget result = widget.child;

    // 1. Slide (innermost - affects position)
    if (widget.slideOffset > 0) {
      result = SlideTransition(position: _slide, child: result);
    }

    // 2. Scale (middle - affects size)
    if (widget.scaleFrom < 1.0) {
      result = ScaleTransition(scale: _scale, child: result);
    }

    // 3. Fade (outermost - affects visibility)
    if (widget.fadeFrom < 1.0) {
      result = FadeTransition(opacity: _opacity, child: result);
    }

    return result;
  }

  @override
  bool get wantKeepAlive => true;
}

/// Disappearing animation for items being removed from the grid.
///
/// **Use case:** When items are deleted or filtered out.
/// Provides smooth exit animation instead of instant removal.
class PinterestItemDisappearAnimation extends StatefulWidget {
  const PinterestItemDisappearAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInCubic,
    this.onComplete,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onComplete;

  @override
  State<PinterestItemDisappearAnimation> createState() =>
      _PinterestItemDisappearAnimationState();
}

class _PinterestItemDisappearAnimationState
    extends State<PinterestItemDisappearAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    final curve = CurvedAnimation(parent: _controller, curve: widget.curve);

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(curve);
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(curve);

    // Auto-start
    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
