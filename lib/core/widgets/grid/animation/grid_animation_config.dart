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
