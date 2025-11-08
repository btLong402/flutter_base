import 'package:flutter/material.dart';

/// Builds a reusable gallery page route with a fade/scale effect resembling
/// the native Photos experience.
PageRoute<T> buildGalleryPageRoute<T>({
  required WidgetBuilder builder,
  Duration transitionDuration = const Duration(milliseconds: 260),
  Duration reverseTransitionDuration = const Duration(milliseconds: 220),
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return buildFadeScaleTransition(animation: animation, child: child);
    },
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
    opaque: true,
    barrierDismissible: false,
    settings: const RouteSettings(name: 'gallery_fullscreen'),
  );
}

/// Combines an ease-out fade with a subtle scale-up animation.
Widget buildFadeScaleTransition({
  required Animation<double> animation,
  required Widget child,
}) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  return FadeTransition(
    opacity: curved,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
      child: child,
    ),
  );
}
