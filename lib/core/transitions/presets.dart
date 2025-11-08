import 'package:flutter/material.dart';

import 'custom_transition.dart';

/// Built-in transition presets tuned for smooth Material and Cupertino flows.
enum TransitionPreset {
  fade,
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  scale,
  scaleAnchored,
  sharedAxisX,
  sharedAxisY,
  sharedAxisZ,
  fadeScale,
  modalSheet,
  heroFriendly,
  cupertinoPush,
}

/// Resolves [TransitionPreset] to a configured [CustomRouteTransition].
CustomRouteTransition transitionForPreset(
  TransitionPreset preset, {
  Alignment alignment = Alignment.center,
}) {
  switch (preset) {
    case TransitionPreset.fade:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 220),
        reverseDuration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [TransitionPrimitives.fade()],
      );
    case TransitionPreset.slideFromRight:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 260),
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.easeInCubic,
        primitives: [
          TransitionPrimitives.slide(
            alignment: alignment,
            begin: const Offset(1, 0),
          ),
          TransitionPrimitives.fade(begin: 0.1, end: 1.0),
        ],
      );
    case TransitionPreset.slideFromLeft:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 300),
        reverseDuration: const Duration(milliseconds: 260),
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.easeInCubic,
        primitives: [
          TransitionPrimitives.slide(
            alignment: alignment,
            begin: const Offset(-1, 0),
          ),
          TransitionPrimitives.fade(begin: 0.1, end: 1.0),
        ],
      );
    case TransitionPreset.slideFromBottom:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 320),
        reverseDuration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [
          TransitionPrimitives.slide(
            alignment: alignment,
            begin: const Offset(0, 1),
          ),
          TransitionPrimitives.fade(begin: 0.0, end: 1.0),
        ],
      );
    case TransitionPreset.slideFromTop:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 320),
        reverseDuration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [
          TransitionPrimitives.slide(
            alignment: alignment,
            begin: const Offset(0, -1),
          ),
          TransitionPrimitives.fade(begin: 0.0, end: 1.0),
        ],
      );
    case TransitionPreset.scale:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 260),
        reverseDuration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [
          TransitionPrimitives.scale(alignment: alignment, begin: 0.92, end: 1),
          TransitionPrimitives.fade(begin: 0.0, end: 1.0),
        ],
      );
    case TransitionPreset.scaleAnchored:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 240),
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
        primitives: [
          TransitionPrimitives.scale(alignment: alignment, begin: 0.85, end: 1),
          TransitionPrimitives.fade(begin: 0.0, end: 1.0),
        ],
      );
    case TransitionPreset.sharedAxisX:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [TransitionPrimitives.sharedAxis(axis: Axis.horizontal)],
      );
    case TransitionPreset.sharedAxisY:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [TransitionPrimitives.sharedAxis(axis: Axis.vertical)],
      );
    case TransitionPreset.sharedAxisZ:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 320),
        reverseDuration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [TransitionPrimitives.scale(begin: 0.9, end: 1.0)],
      );
    case TransitionPreset.fadeScale:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 260),
        reverseDuration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [TransitionPrimitives.fadeScale(alignment: alignment)],
      );
    case TransitionPreset.modalSheet:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 320),
        reverseDuration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        opaque: false,
        primitives: [TransitionPrimitives.modalSheet()],
      );
    case TransitionPreset.heroFriendly:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 260),
        reverseDuration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [TransitionPrimitives.fade(begin: 0.0, end: 1.0)],
        useCompositor: true,
      );
    case TransitionPreset.cupertinoPush:
      return CustomRouteTransition(
        duration: const Duration(milliseconds: 330),
        reverseDuration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
        primitives: [
          TransitionPrimitives.slide(begin: const Offset(1, 0)),
          TransitionPrimitives.fade(begin: 0.1, end: 1.0),
        ],
      );
  }
}
