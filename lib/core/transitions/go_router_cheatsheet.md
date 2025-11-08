# go_router Transition Cheat Sheet

Common wiring patterns using the custom transition toolkit.

## Fade-Scale (default Android-friendly)
```dart
buildGoRoute(
  path: '/dashboard',
  builder: (context, state) => const DashboardPage(),
  preset: TransitionPreset.fadeScale,
);
```

## Cupertino Push With Forced Custom Animation
```dart
buildGoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsPage(),
  preset: TransitionPreset.slideFromRight,
  forceTransition: true,
);
```

## Modal Bottom Sheet with Shared Navigator Key
```dart
final rootKey = GlobalKey<NavigatorState>();

GoRouter(
  navigatorKey: rootKey,
  routes: [
    buildGoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
      routes: [
        buildGoRoute(
          path: 'edit',
          builder: (context, state) => const EditProfileSheet(),
          preset: TransitionPreset.modalSheet,
          adaptive: false,
          forceTransition: true,
        ),
      ],
    ),
  ],
);
```

## Disable Animations for Accessibility-Critical Routes
```dart
buildGoRoute(
  path: '/onboarding',
  builder: (context, state) => const OnboardingPage(),
  transition: CustomRouteTransition(
    duration: Duration.zero,
    reverseDuration: Duration.zero,
    transitionBuilder: (context, animation, secondary, child) => child,
  ),
);
```

## Compose Custom Slide + Fade
```dart
final dramaticSlide = CustomRouteTransition(
  duration: const Duration(milliseconds: 340),
  curve: Curves.easeOutExpo,
  primitives: [
    TransitionPrimitives.slide(begin: const Offset(0.0, 0.2)),
    TransitionPrimitives.fade(begin: 0.0, end: 1.0),
  ],
);
```

## Nested ShellRoute Tabs
```dart
ShellRoute(
  builder: (context, state, child) => NestedTabsShell(
    location: state.uri.toString(),
    child: child,
  ),
  routes: [
    buildGoRoute(
      path: '/tabs/home',
      builder: (context, state) => const HomeTab(),
      preset: TransitionPreset.sharedAxisX,
      forceTransition: true,
    ),
    buildGoRoute(
      path: '/tabs/activity',
      builder: (context, state) => const ActivityTab(),
      preset: TransitionPreset.fade,
      forceTransition: true,
    ),
  ],
);
```
