import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'custom_transition.dart';
import 'platform_adaptive.dart';
import 'presets.dart';

typedef GoRouterWidgetBuilder =
    Widget Function(BuildContext context, GoRouterState state);

/// Builds a [GoRoute] with a declarative transition configuration.
GoRoute buildGoRoute({
  required String path,
  String? name,
  GoRouterWidgetBuilder? builder,
  GoRouterPageBuilder? pageBuilder,
  TransitionPreset? preset,
  CustomRouteTransition? transition,
  bool adaptive = true,
  bool forceTransition = false,
  List<RouteBase> routes = const [],
  GlobalKey<NavigatorState>? parentNavigatorKey,
  FutureOr<String?> Function(BuildContext, GoRouterState)? redirect,
}) {
  assert(
    builder != null || pageBuilder != null,
    'Either builder or pageBuilder must be provided.',
  );

  return GoRoute(
    path: path,
    name: name,
    parentNavigatorKey: parentNavigatorKey,
    routes: routes,
    redirect: redirect,
    pageBuilder:
        pageBuilder ??
        (context, state) {
          final child = builder!(context, state);
          return buildTransitionPage(
            context: context,
            state: state,
            child: child,
            preset: preset,
            transition: transition,
            adaptive: adaptive,
            forceTransition: forceTransition,
          );
        },
  );
}

/// Creates a [Page] that wires the supplied [transition] into a
/// [CustomTransitionPage].
Page<T> buildTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  TransitionPreset? preset,
  CustomRouteTransition? transition,
  bool adaptive = true,
  bool forceTransition = false,
}) {
  final baseTransition =
      transition ??
      (preset != null
          ? transitionForPreset(preset)
          : PlatformAdaptiveTransitions.defaultForPlatform(context));
  final accessibleTransition = PlatformAdaptiveTransitions.resolveAccessibility(
    context,
    baseTransition,
  );

  if (!accessibleTransition.enableAccessibilityAnimations &&
      accessibleTransition.duration == Duration.zero) {
    return NoTransitionPage<T>(
      key: state.pageKey,
      name: state.name,
      arguments: state.extra,
      child: child,
    );
  }

  if (adaptive &&
      PlatformAdaptiveTransitions.useCupertinoNavigation(context) &&
      !forceTransition) {
    return CupertinoPage<T>(
      key: state.pageKey,
      name: state.name,
      arguments: state.extra,
      child: child,
    );
  }

  final resolvedTransition = PlatformAdaptiveTransitions.resolveForPlatform(
    context,
    accessibleTransition,
    forceTransition: forceTransition,
  );

  return CustomTransitionPage<T>(
    key: state.pageKey,
    name: state.name,
    arguments: state.extra,
    maintainState: resolvedTransition.maintainState,
    opaque: resolvedTransition.opaque,
    barrierDismissible: !resolvedTransition.opaque,
    transitionDuration: resolvedTransition.duration,
    reverseTransitionDuration: resolvedTransition.reverseDuration,
    child: child,
    transitionsBuilder: resolvedTransition.toBuilder(),
  );
}

/// Returns a [NoTransitionPage] for scenarios where animations should be
/// skipped entirely (e.g. onboarding splash pages).
Page<T> noTransitionPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<T>(
    key: state.pageKey,
    name: state.name,
    arguments: state.extra,
    child: child,
  );
}
