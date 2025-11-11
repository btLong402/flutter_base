import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ## Refresh Control Wrappers
///
/// Provides platform-appropriate pull-to-refresh implementations:
/// - **Material**: RefreshIndicator for Android/Web/Desktop
/// - **Cupertino**: CupertinoSliverRefreshControl for iOS (sliver-based)
///
/// ### Usage Patterns:
///
/// **Material (ListView/GridView):**
/// ```dart
/// MaterialRefreshWrapper(
///   onRefresh: controller.refresh,
///   child: ListView(...),
/// )
/// ```
///
/// **Cupertino (CustomScrollView):**
/// ```dart
/// CustomScrollView(
///   slivers: [
///     CupertinoSliverRefreshWrapper(onRefresh: controller.refresh),
///     SliverList(...),
///   ],
/// )
/// ```

/// Material-style refresh control used for non-sliver lists.
///
/// Wraps [RefreshIndicator] with consistent styling and semantics.
class MaterialRefreshWrapper extends StatelessWidget {
  const MaterialRefreshWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.semanticsLabel,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: color,
      backgroundColor: backgroundColor,
      semanticsLabel: semanticsLabel,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

/// Cupertino-style pull-to-refresh control for sliver usage.
class CupertinoSliverRefreshWrapper extends StatelessWidget {
  const CupertinoSliverRefreshWrapper({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(onRefresh: onRefresh);
  }
}
