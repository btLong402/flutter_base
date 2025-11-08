# Custom go_router Transitions Toolkit

A production-ready set of page transition presets, helpers, and demos tuned for `go_router`. The toolkit keeps animations fast, platform-appropriate, and accessible while remaining easy to wire into existing route tables.

## Highlights
- **Batteries-included presets**: fade, slide (all directions), scale, fade-scale, shared-axis (x/y/z), modal sheets, and hero-friendly fades.
- **Platform adaptivity**: automatic Cupertino navigation on iOS (edge-swipe support) and Material easing elsewhere, plus explicit opt-in/out flags.
- **Accessibility-aware**: respects reduced motion and `disableAnimations` by default; toggle-able per route.
- **Composable primitives**: build bespoke transitions with lightweight primitives (`fade`, `slide`, `scale`, `modalSheet`, etc.).
- **Hero tooling**: consistent tagging helpers, placeholder sizing, and sample shared-element gallery.
- **Demo router**: copy the example routes to see push/pop, modal bottom sheet, hero gallery, and nested shell navigation in action.

## Getting Started
```dart
import 'package:code_base_riverpod/transitions/transitions.dart';

final router = GoRouter(
  routes: [
    buildGoRoute(
      path: '/inbox',
      builder: (context, state) => const InboxPage(),
      preset: TransitionPreset.fadeScale,
    ),
  ],
);
```

The helper picks a preset, handles platform adaptivity, and emits a `CustomTransitionPage`. iOS defaults to `CupertinoPage` with interactive back-swipe unless `forceTransition: true` is set.

## Presets
Use `transitionForPreset` when you need a reusable `CustomRouteTransition` instance:
```dart
final modalTransition = transitionForPreset(TransitionPreset.modalSheet)
    .copyWith(enableAccessibilityAnimations: true);
```

### Custom Composition
Compose primitives when the presets do not fit:
```dart
final custom = CustomRouteTransition(
  primitives: [
    TransitionPrimitives.slide(begin: const Offset(0, 0.12)),
    TransitionPrimitives.fade(begin: 0.0, end: 1.0),
  ],
  duration: const Duration(milliseconds: 260),
);
```

## Accessibility & Performance
- Animations opt-out automatically when `MediaQuery.disableAnimations` or `accessibleNavigation` is true. Set `enableAccessibilityAnimations: true` to override.
- Only transform opacity and transforms; avoid animating layout. `CustomRouteTransition` wraps transitions in a `RepaintBoundary` by default via `useCompositor`.
- For expensive routes, load heavy widgets offstage or lazy-load within the new page.

## Hero & Shared Elements
```dart
HeroUtils.hero(
  tag: HeroUtils.tag('gallery', item.id),
  child: Image(...),
);
```

Pair with `HeroUtils.createHeroController()` inside nested navigators to keep animations smooth. Use `precacheHeroImage` to avoid flashes.

## Demo Router
`lib/transitions/examples/examples_router.dart` exposes `transitionsDemoRouter` featuring:
1. Push/pop: slide + fade-scale with hero cards.
2. Modal sheet: custom bottom sheet with drag-to-dismiss.
3. Shared-element gallery: hero grid to detail with precaching.
4. Nested tabs: shell route where only inner content animates.

## Testing
Widget tests live under `test/transitions/` validating timing, curves, and adaptive fallbacks. Run them with:
```
flutter test test/transitions
```

## Tuning Cheat Sheet
See `lib/transitions/examples/go_router_cheatsheet.md` for copy-paste route snippets showing how to wire presets, force transitions on iOS, or disable animations entirely.
