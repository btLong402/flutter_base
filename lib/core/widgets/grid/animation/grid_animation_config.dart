import 'dart:math' as math;

import 'package:flutter/widgets.dart';

typedef GridItemAnimationBuilder =
    Widget Function(BuildContext context, int index, Widget child);

class GridAnimationConfig {
  const GridAnimationConfig._(this._builder);

  final GridItemAnimationBuilder _builder;

  Widget wrap(BuildContext context, int index, Widget child) =>
      _builder(context, index, child);

  factory GridAnimationConfig.none() =>
      GridAnimationConfig._((_, __, child) => child);

  factory GridAnimationConfig.staggered({
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeOutCubic,
    Duration maxDelay = const Duration(milliseconds: 220),
    double initialOffset = 32,
    double initialScale = 0.95,
  }) {
    return GridAnimationConfig._(
      (context, index, child) => _StaggeredGridAnimator(
        duration: duration,
        curve: curve,
        delay: Duration(
          milliseconds: math.min(maxDelay.inMilliseconds, (index % 12) * 18),
        ),
        offset: initialOffset,
        scale: initialScale,
        child: child,
      ),
    );
  }

  /// Pinterest-style staggered animation with fade, scale, and slide
  factory GridAnimationConfig.pinterest({
    Duration duration = const Duration(milliseconds: 280),
    Curve curve = Curves.easeOutCubic,
    Duration staggerDelay = const Duration(milliseconds: 25),
    Duration maxStagger = const Duration(milliseconds: 200),
    double fadeFrom = 0.0,
    double scaleFrom = 0.94,
    double slideOffset = 24.0,
  }) {
    return GridAnimationConfig._(
      (context, index, child) => _PinterestGridAnimator(
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

  /// Fade-only Pinterest animation
  factory GridAnimationConfig.pinterestFadeOnly({
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOut,
    Duration staggerDelay = const Duration(milliseconds: 20),
  }) {
    return GridAnimationConfig.pinterest(
      duration: duration,
      curve: curve,
      staggerDelay: staggerDelay,
      fadeFrom: 0.0,
      scaleFrom: 1.0,
      slideOffset: 0.0,
    );
  }

  /// Scale-only Pinterest animation
  factory GridAnimationConfig.pinterestScaleOnly({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutBack,
    Duration staggerDelay = const Duration(milliseconds: 30),
    double scaleFrom = 0.85,
  }) {
    return GridAnimationConfig.pinterest(
      duration: duration,
      curve: curve,
      staggerDelay: staggerDelay,
      fadeFrom: 1.0,
      scaleFrom: scaleFrom,
      slideOffset: 0.0,
    );
  }

  /// Slide-only Pinterest animation
  factory GridAnimationConfig.pinterestSlideOnly({
    Duration duration = const Duration(milliseconds: 320),
    Curve curve = Curves.easeOutCubic,
    Duration staggerDelay = const Duration(milliseconds: 25),
    double slideOffset = 32.0,
  }) {
    return GridAnimationConfig.pinterest(
      duration: duration,
      curve: curve,
      staggerDelay: staggerDelay,
      fadeFrom: 1.0,
      scaleFrom: 1.0,
      slideOffset: slideOffset,
    );
  }
}

class _StaggeredGridAnimator extends StatefulWidget {
  const _StaggeredGridAnimator({
    required this.duration,
    required this.curve,
    required this.delay,
    required this.offset,
    required this.scale,
    required this.child,
  });

  final Duration duration;
  final Curve curve;
  final Duration delay;
  final double offset;
  final double scale;
  final Widget child;

  @override
  State<_StaggeredGridAnimator> createState() => _StaggeredGridAnimatorState();
}

class _StaggeredGridAnimatorState extends State<_StaggeredGridAnimator>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted && !_controller.isAnimating) {
        _controller.forward();
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
    super.build(context);
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        final double t = _curve.value;
        final double dy = (1 - t) * widget.offset;
        final double scale = widget.scale + (1 - widget.scale) * t;
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Pinterest-style animator with fade, scale, and slide effects
class _PinterestGridAnimator extends StatefulWidget {
  const _PinterestGridAnimator({
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
  State<_PinterestGridAnimator> createState() => _PinterestGridAnimatorState();
}

class _PinterestGridAnimatorState extends State<_PinterestGridAnimator>
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

    // Create interpolations
    _opacity = Tween<double>(begin: widget.fadeFrom, end: 1.0).animate(_curve);

    _scale = Tween<double>(begin: widget.scaleFrom, end: 1.0).animate(_curve);

    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset / 100),
      end: Offset.zero,
    ).animate(_curve);

    // Start animation after delay
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
    super.build(context);

    Widget result = widget.child;

    // Compose animations (order matters)
    if (widget.slideOffset > 0) {
      result = SlideTransition(position: _slide, child: result);
    }

    if (widget.scaleFrom < 1.0) {
      result = ScaleTransition(scale: _scale, child: result);
    }

    if (widget.fadeFrom < 1.0) {
      result = FadeTransition(opacity: _opacity, child: result);
    }

    return result;
  }

  @override
  bool get wantKeepAlive => true;
}
