import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_transition.dart';
import 'presets.dart';

/// Platform-aware helpers for choosing transitions and respecting accessibility
/// settings.
class PlatformAdaptiveTransitions {
  const PlatformAdaptiveTransitions._();

  /// Returns true when Cupertino-style navigation (with edge-swipe gesture)
  /// should be preferred.
  static bool useCupertinoNavigation(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (kIsWeb) {
      return false;
    }
    if (platform == TargetPlatform.iOS) {
      return true;
    }
    return false;
  }

  /// Whether system-wide reduced-motion preferences ask for simplified
  /// animations.
  static bool shouldReduceMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    if (media == null) {
      return false;
    }
    return media.disableAnimations || media.accessibleNavigation;
  }

  /// Applies accessibility preferences to the supplied [transition].
  static CustomRouteTransition resolveAccessibility(
    BuildContext context,
    CustomRouteTransition transition,
  ) {
    if (transition.enableAccessibilityAnimations) {
      return transition;
    }
    if (shouldReduceMotion(context)) {
      return transition.copyWith(
        duration: Duration.zero,
        reverseDuration: Duration.zero,
        transitionBuilder: (context, animation, secondary, child) => child,
        useCompositor: false,
      );
    }
    return transition;
  }

  /// Picks a platform-appropriate preset when none is specified.
  static CustomRouteTransition defaultForPlatform(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (useCupertinoNavigation(context)) {
      return transitionForPreset(TransitionPreset.cupertinoPush);
    }
    if (platform == TargetPlatform.android ||
        platform == TargetPlatform.fuchsia) {
      return transitionForPreset(TransitionPreset.fadeScale);
    }
    return transitionForPreset(TransitionPreset.fade);
  }

  /// Returns [transition] unless adaptive navigation suggests using a native
  /// platform transition. Set [forceTransition] to true to opt-out of the native
  /// override.
  static CustomRouteTransition resolveForPlatform(
    BuildContext context,
    CustomRouteTransition transition, {
    bool forceTransition = false,
  }) {
    if (forceTransition) {
      return transition;
    }
    if (useCupertinoNavigation(context)) {
      return transition.copyWith(
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: transition.primitives.isEmpty
            ? transitionForPreset(TransitionPreset.cupertinoPush).primitives
            : transition.primitives,
      );
    }
    return transition;
  }
}
