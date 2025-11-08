import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../internal/grid_session.dart';
import 'grid_layout_config.dart';

GridLayoutStrategy createLayoutStrategy(
  GridLayoutConfig config,
  TextDirection direction,
) {
  if (config is FixedGridLayout) {
    return _FixedGridStrategy(config, direction);
  }
  if (config is ResponsiveGridLayout) {
    return _ResponsiveGridStrategy(config, direction);
  }
  if (config is MasonryGridLayout) {
    return _MasonryGridStrategy(config, direction);
  }
  if (config is RatioGridLayout) {
    return _RatioGridStrategy(config, direction);
  }
  if (config is AsymmetricGridLayout) {
    return _AsymmetricGridStrategy(config, direction);
  }
  if (config is AutoPlacementGridLayout) {
    return _AutoPlacementGridStrategy(config, direction);
  }
  if (config is NestedGridLayout) {
    return createLayoutStrategy(config.innerLayout, direction);
  }
  throw UnsupportedError(
    'Unsupported grid configuration ${config.runtimeType}',
  );
}

abstract class GridLayoutStrategy {
  const GridLayoutStrategy();

  GridLayoutSession startSession(GridLayoutContext context);

  BoxGridLayoutDescriptor describeBoxLayout(double crossAxisExtent);
}

class BoxGridLayoutDescriptor {
  const BoxGridLayoutDescriptor({
    required this.columnCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.spanResolver,
    required this.reverseCrossAxis,
    required this.expandToFit,
    required this.fixedColumnWidth,
  });

  final int columnCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final GridSpanResolver spanResolver;
  final bool reverseCrossAxis;
  final bool expandToFit;
  final double? fixedColumnWidth;
}

abstract class _BaseColumnStrategy extends GridLayoutStrategy {
  _BaseColumnStrategy(this.direction);
  final TextDirection direction;

  GridSpanResolver spanResolverForIndex();
  double mainAxisSpacing();
  double crossAxisSpacing();
  bool reverseCrossAxis();
  bool expandToFit();
  double? fixedColumnWidth();
  int resolveColumnCountForExtent(double crossAxisExtent);

  @override
  GridLayoutSession startSession(GridLayoutContext context) {
    final columnCount = math.max(
      1,
      resolveColumnCountForExtent(context.crossAxisExtent),
    );
    return ColumnarGridSession(
      context: context,
      columnCount: columnCount,
      mainAxisSpacing: mainAxisSpacing(),
      crossAxisSpacing: crossAxisSpacing(),
      spanResolver: spanResolverForIndex(),
      reverseCrossAxis: reverseCrossAxis(),
      expandToFit: expandToFit(),
      fixedColumnWidth: fixedColumnWidth(),
    );
  }

  @override
  BoxGridLayoutDescriptor describeBoxLayout(double crossAxisExtent) {
    final columnCount = math.max(
      1,
      resolveColumnCountForExtent(crossAxisExtent),
    );
    return BoxGridLayoutDescriptor(
      columnCount: columnCount,
      mainAxisSpacing: mainAxisSpacing(),
      crossAxisSpacing: crossAxisSpacing(),
      spanResolver: spanResolverForIndex(),
      reverseCrossAxis: reverseCrossAxis(),
      expandToFit: expandToFit(),
      fixedColumnWidth: fixedColumnWidth(),
    );
  }
}

class _FixedGridStrategy extends _BaseColumnStrategy {
  _FixedGridStrategy(this.layout, TextDirection direction) : super(direction);

  final FixedGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() {
    return (int _) => GridSpanConfiguration(
      columnSpan: 1,
      mainAxisExtent: layout.mainAxisExtent,
      aspectRatio: layout.mainAxisExtent == null
          ? layout.childAspectRatio
          : null,
    );
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() => direction == TextDirection.rtl;

  @override
  bool expandToFit() => true;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) =>
      layout.crossAxisCount;
}

class _ResponsiveGridStrategy extends _BaseColumnStrategy {
  _ResponsiveGridStrategy(this.layout, TextDirection direction)
    : super(direction);

  final ResponsiveGridLayout layout;
  ResponsiveGridBreakpoint? _activeBreakpoint;

  @override
  GridSpanResolver spanResolverForIndex() {
    return (int index) {
      final breakpoint = _activeBreakpoint ?? layout.breakpoints.first;
      return GridSpanConfiguration(
        columnSpan: 1,
        mainAxisExtent: breakpoint.mainAxisExtent,
        aspectRatio: breakpoint.mainAxisExtent == null
            ? breakpoint.childAspectRatio
            : null,
      );
    };
  }

  int _resolveColumns(double extent) {
    final sorted = layout.breakpoints.toList()
      ..sort((a, b) => a.breakpoint.compareTo(b.breakpoint));
    ResponsiveGridBreakpoint candidate = sorted.first;
    for (final breakpoint in sorted) {
      if (extent <= breakpoint.breakpoint) {
        candidate = breakpoint;
        break;
      }
      candidate = breakpoint;
    }
    _activeBreakpoint = candidate;
    final count = candidate.crossAxisCount;
    final minCount = layout.minCrossAxisCount;
    final maxCount = layout.maxCrossAxisCount ?? count;
    return count.clamp(minCount, maxCount);
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() => direction == TextDirection.rtl;

  @override
  bool expandToFit() => layout.expandToFit;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) =>
      math.max(_resolveColumns(crossAxisExtent), layout.minCrossAxisCount);
}

class _MasonryGridStrategy extends _BaseColumnStrategy {
  _MasonryGridStrategy(this.layout, TextDirection direction) : super(direction);

  final MasonryGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() {
    if (layout.spanResolver != null) {
      return layout.spanResolver!;
    }
    return (int _) => const GridSpanConfiguration(columnSpan: 1);
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() =>
      layout.reverseCrossAxis ? true : direction == TextDirection.rtl;

  @override
  bool expandToFit() => layout.columnWidth == null;

  @override
  double? fixedColumnWidth() => layout.columnWidth;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) {
    if (layout.columnCount != null) {
      return layout.columnCount!;
    }
    final double targetColumnWidth = layout.columnWidth ?? crossAxisExtent;
    final available = math.max(
      1,
      ((crossAxisExtent + layout.crossAxisSpacing) /
              (targetColumnWidth + layout.crossAxisSpacing))
          .floor(),
    );
    return available;
  }
}

class _RatioGridStrategy extends _BaseColumnStrategy {
  _RatioGridStrategy(this.layout, TextDirection direction) : super(direction);

  final RatioGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() {
    return (int _) =>
        GridSpanConfiguration(columnSpan: 1, aspectRatio: layout.aspectRatio);
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() => direction == TextDirection.rtl;

  @override
  bool expandToFit() => true;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) => layout.columnCount;
}

class _AsymmetricGridStrategy extends _BaseColumnStrategy {
  _AsymmetricGridStrategy(this.layout, TextDirection direction)
    : super(direction);

  final AsymmetricGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() => layout.spanResolver;

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() =>
      layout.reverseCrossAxis ? true : direction == TextDirection.rtl;

  @override
  bool expandToFit() => true;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) => layout.columnCount;
}

class _AutoPlacementGridStrategy extends _BaseColumnStrategy {
  _AutoPlacementGridStrategy(this.layout, TextDirection direction)
    : super(direction);

  final AutoPlacementGridLayout layout;

  @override
  GridSpanResolver spanResolverForIndex() {
    return (int index) {
      final resolved =
          layout.rule.spanResolver(index) ?? const GridSpanConfiguration();
      final int maxSpan = layout.rule.maxSpan ?? layout.columnCount;
      final clampedSpan = resolved.columnSpan.clamp(1, maxSpan);
      return GridSpanConfiguration(
        columnSpan: clampedSpan,
        aspectRatio: resolved.aspectRatio,
        mainAxisExtent: resolved.mainAxisExtent,
        alignment: resolved.alignment,
      );
    };
  }

  @override
  double mainAxisSpacing() => layout.mainAxisSpacing;

  @override
  double crossAxisSpacing() => layout.crossAxisSpacing;

  @override
  bool reverseCrossAxis() =>
      layout.reverseCrossAxis ? true : direction == TextDirection.rtl;

  @override
  bool expandToFit() => true;

  @override
  double? fixedColumnWidth() => null;

  @override
  int resolveColumnCountForExtent(double crossAxisExtent) => layout.columnCount;
}
