import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Material-style refresh control used for non-sliver lists.
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
