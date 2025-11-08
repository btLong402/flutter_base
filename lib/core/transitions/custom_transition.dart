import 'package:flutter/material.dart';

/// Signature for a transition primitive that decorates [child] using the supplied
/// animations.
typedef TransitionPrimitive =
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    );

/// Applies a sequence of transition primitives in order.
RouteTransitionsBuilder composeTransitions(
  List<TransitionPrimitive> primitives,
) {
  assert(primitives.isNotEmpty, 'Provide at least one transition primitive.');
  return (context, animation, secondary, child) {
    Widget current = child;
    for (final primitive in primitives.reversed) {
      current = primitive(context, animation, secondary, current);
    }
    return current;
  };
}

/// Factory helpers for common transition primitives.
class TransitionPrimitives {
  const TransitionPrimitives._();

  static TransitionPrimitive fade({double begin = 0, double end = 1}) {
    return (context, animation, secondary, child) {
      final tween = Tween<double>(begin: begin, end: end);
      return FadeTransition(opacity: animation.drive(tween), child: child);
    };
  }

  static TransitionPrimitive slide({
    Alignment alignment = Alignment.center,
    Offset begin = const Offset(0, 0.1),
    Offset end = Offset.zero,
  }) {
    return (context, animation, secondary, child) {
      final tween = Tween<Offset>(begin: begin, end: end);
      return Align(
        alignment: alignment,
        child: SlideTransition(position: animation.drive(tween), child: child),
      );
    };
  }

  static TransitionPrimitive scale({
    Alignment alignment = Alignment.center,
    double begin = 0.94,
    double end = 1,
  }) {
    return (context, animation, secondary, child) {
      final tween = Tween<double>(begin: begin, end: end);
      return ScaleTransition(
        alignment: alignment,
        scale: animation.drive(tween),
        child: child,
      );
    };
  }

  static TransitionPrimitive sharedAxis({
    Axis axis = Axis.horizontal,
    bool invert = false,
    double translateDistance = 0.2,
  }) {
    return (context, animation, secondary, child) {
      final direction = invert ? -1.0 : 1.0;
      final fade = animation.drive(Tween(begin: 0.0, end: 1.0));
      Widget result = FadeTransition(opacity: fade, child: child);
      if (axis == Axis.horizontal) {
        result = SlideTransition(
          position: animation.drive(
            Tween(
              begin: Offset(direction * translateDistance, 0),
              end: Offset.zero,
            ),
          ),
          child: result,
        );
      } else {
        result = SlideTransition(
          position: animation.drive(
            Tween(
              begin: Offset(0, direction * translateDistance),
              end: Offset.zero,
            ),
          ),
          child: result,
        );
      }
      result = ScaleTransition(
        scale: animation.drive(Tween(begin: 0.92, end: 1.0)),
        child: result,
      );
      return result;
    };
  }

  static TransitionPrimitive fadeScale({
    Alignment alignment = Alignment.center,
    double scaleBegin = 0.96,
  }) {
    return (context, animation, secondary, child) {
      final fade = animation.drive(Tween(begin: 0.0, end: 1.0));
      final scale = animation.drive(Tween(begin: scaleBegin, end: 1.0));
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(
          alignment: alignment,
          scale: scale,
          child: child,
        ),
      );
    };
  }

  static TransitionPrimitive modalSheet({double lift = 0.08}) {
    return (context, animation, secondary, child) {
      final slide = animation.drive(
        Tween(
          begin: Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      );
      final fade = animation.drive(Tween(begin: 0.0, end: 1.0));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    lift *
                        (1 - animation.value) *
                        MediaQuery.of(context).size.height,
                  ),
                  child: child,
                );
              },
              child: child,
            ),
          ),
        ),
      );
    };
  }
}

/// Encapsulates page transition configuration for go_router integrations.
class CustomRouteTransition {
  const CustomRouteTransition({
    this.duration = const Duration(milliseconds: 280),
    Duration? reverseDuration,
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    this.alignment = Alignment.center,
    this.offset = Offset.zero,
    this.scaleBegin = 1.0,
    this.scaleEnd = 1.0,
    this.useCompositor = true,
    this.maintainState = true,
    this.opaque = true,
    this.enableAccessibilityAnimations = false,
    this.transitionBuilder,
    this.primitives = const [],
  }) : reverseDuration = reverseDuration ?? const Duration(milliseconds: 240);

  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;
  final Alignment alignment;
  final Offset offset;
  final double scaleBegin;
  final double scaleEnd;
  final bool useCompositor;
  final bool maintainState;
  final bool opaque;
  final bool enableAccessibilityAnimations;
  final RouteTransitionsBuilder? transitionBuilder;
  final List<TransitionPrimitive> primitives;

  CustomRouteTransition copyWith({
    Duration? duration,
    Duration? reverseDuration,
    Curve? curve,
    Curve? reverseCurve,
    Alignment? alignment,
    Offset? offset,
    double? scaleBegin,
    double? scaleEnd,
    bool? useCompositor,
    bool? maintainState,
    bool? opaque,
    bool? enableAccessibilityAnimations,
    RouteTransitionsBuilder? transitionBuilder,
    List<TransitionPrimitive>? primitives,
  }) {
    return CustomRouteTransition(
      duration: duration ?? this.duration,
      reverseDuration: reverseDuration ?? this.reverseDuration,
      curve: curve ?? this.curve,
      reverseCurve: reverseCurve ?? this.reverseCurve,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      scaleBegin: scaleBegin ?? this.scaleBegin,
      scaleEnd: scaleEnd ?? this.scaleEnd,
      useCompositor: useCompositor ?? this.useCompositor,
      maintainState: maintainState ?? this.maintainState,
      opaque: opaque ?? this.opaque,
      enableAccessibilityAnimations:
          enableAccessibilityAnimations ?? this.enableAccessibilityAnimations,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
      primitives: primitives ?? this.primitives,
    );
  }

  RouteTransitionsBuilder toBuilder() {
    final baseBuilder = transitionBuilder ?? _buildDefault();
    return (context, animation, secondary, child) {
      final curved = animation.drive(CurveTween(curve: curve));
      final curvedSecondary = secondary.drive(CurveTween(curve: reverseCurve));
      Widget result = baseBuilder(context, curved, curvedSecondary, child);
      if (useCompositor) {
        result = RepaintBoundary(child: result);
      }
      return result;
    };
  }

  RouteTransitionsBuilder _buildDefault() {
    if (primitives.isNotEmpty) {
      return composeTransitions(primitives);
    }

    final resolvedPrimitives = <TransitionPrimitive>[];
    if (offset != Offset.zero) {
      resolvedPrimitives.add(
        TransitionPrimitives.slide(alignment: alignment, begin: offset),
      );
    }
    if (scaleBegin != 1.0 || scaleEnd != 1.0) {
      resolvedPrimitives.add(
        TransitionPrimitives.scale(
          alignment: alignment,
          begin: scaleBegin,
          end: scaleEnd,
        ),
      );
    }
    resolvedPrimitives.add(TransitionPrimitives.fade());
    return composeTransitions(resolvedPrimitives);
  }
}
