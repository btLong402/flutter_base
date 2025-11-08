import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../layout/grid_layout_config.dart';

class GridLayoutContext {
  GridLayoutContext({
    required this.constraints,
    required this.textDirection,
    required this.axisDirection,
    required this.growthDirection,
  }) : crossAxisExtent = constraints.crossAxisExtent,
       isAxisVertical =
           axisDirection == AxisDirection.down ||
           axisDirection == AxisDirection.up;

  final SliverConstraints constraints;
  final TextDirection textDirection;
  final AxisDirection axisDirection;
  final GrowthDirection growthDirection;
  final double crossAxisExtent;
  final bool isAxisVertical;
}

class GridChildPlacement {
  const GridChildPlacement({
    required this.index,
    required this.layoutOffset,
    required this.mainAxisExtent,
    required this.crossAxisOffset,
    required this.crossAxisExtent,
    required this.alignment,
    required this.columnStart,
    required this.columnSpan,
  });

  final int index;
  final double layoutOffset;
  final double mainAxisExtent;
  final double crossAxisOffset;
  final double crossAxisExtent;
  final AlignmentGeometry alignment;
  final int columnStart;
  final int columnSpan;

  double get trailingOffset => layoutOffset + mainAxisExtent;
}

abstract class GridLayoutSession {
  GridLayoutSession(this.context);

  GridLayoutContext context;

  /// Ensures the session is aligned with the current constraints prior to
  /// layout, resetting caches if necessary.
  void ensureForLayout(GridLayoutContext nextContext);

  /// Provides constraints for the child at [index]. Implementations may cache
  /// span information for reuse in [recordChildLayout].
  BoxConstraints resolveConstraintsForIndex(int index);

  /// Records the laid out [childSize] for [index] and returns placement data
  /// used by the render object. Implementations must update internal column
  /// heights or offsets here.
  GridChildPlacement recordChildLayout(int index, Size childSize);

  /// Returns the best candidate index to start layout given the current scroll
  /// offset. Implementations typically consult cached placements.
  int estimateMinIndexForScrollOffset(double scrollOffset);

  /// Computes the estimated max scroll extent for the sliver.
  double estimateMaxScrollOffset(int? itemCount);

  /// Removes cached placements in the provided inclusive range.
  void dropCache(int leadingIndex, int trailingIndex);

  /// Clears all caches, forcing a fresh layout pass on next build.
  void reset();

  /// Called when the item count changes so caches can be truncated.
  void updateItemCount(int? itemCount);

  /// Called after layout to expose column state for diagnostics.
  double get maxColumnExtent;

  Iterable<GridChildPlacement> get cachedPlacements;
}

class ColumnarGridSession extends GridLayoutSession {
  ColumnarGridSession({
    required GridLayoutContext context,
    required this.columnCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.spanResolver,
    required this.reverseCrossAxis,
    required this.expandToFit,
    this.fixedColumnWidth,
  }) : columnHeights = List<double>.filled(columnCount, 0, growable: false),
       columnOffsets = List<double>.filled(columnCount, 0, growable: false),
       super(context);

  final int columnCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final GridSpanResolver spanResolver;
  final bool reverseCrossAxis;
  final bool expandToFit;
  final double? fixedColumnWidth;

  late double _columnWidth;
  double _crossAxisInset = 0;
  final List<double> columnHeights;
  final List<double> columnOffsets;
  final SplayTreeMap<int, GridChildPlacement> _placements =
      SplayTreeMap<int, GridChildPlacement>();
  final Map<int, GridSpanConfiguration> _spanCache =
      <int, GridSpanConfiguration>{};

  @override
  void ensureForLayout(GridLayoutContext nextContext) {
    final bool hasCrossExtentChanged =
        context.crossAxisExtent != nextContext.crossAxisExtent;
    if (!identical(context.constraints, nextContext.constraints) ||
        hasCrossExtentChanged ||
        nextContext.constraints.crossAxisExtent <= 0) {
      reset();
    }
    context = nextContext;
    if (fixedColumnWidth != null) {
      _columnWidth = fixedColumnWidth!;
    } else {
      final usableExtent = math.max(
        0.0,
        nextContext.crossAxisExtent -
            crossAxisSpacing * math.max(columnCount - 1, 0),
      );
      final double rawWidth = usableExtent / columnCount;
      _columnWidth = rawWidth.isFinite ? rawWidth : 0;
    }
    if (!expandToFit) {
      final totalWidth = _crossAxisExtentForSpan(columnCount);
      _crossAxisInset = math.max(
        0,
        (nextContext.crossAxisExtent - totalWidth) / 2,
      );
    } else {
      _crossAxisInset = 0;
    }
    for (var i = 0; i < columnCount; i++) {
      columnOffsets[i] = _crossAxisOffsetForColumn(i);
    }
  }

  @override
  BoxConstraints resolveConstraintsForIndex(int index) {
    final span = _resolveSpan(index);
    final crossExtent = _crossAxisExtentForSpan(span.columnSpan);
    final double? mainExtent =
        span.mainAxisExtent ??
        (span.aspectRatio != null && span.aspectRatio! > 0
            ? crossExtent / span.aspectRatio!
            : null);
    final double minHeight = mainExtent ?? 0;
    final double maxHeight = mainExtent ?? double.infinity;
    return BoxConstraints(
      minWidth: crossExtent,
      maxWidth: crossExtent,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  GridChildPlacement recordChildLayout(int index, Size childSize) {
    final span = _resolveSpan(index);
    final placement = _resolveColumnPlacement(span.columnSpan);
    final crossExtent = _crossAxisExtentForSpan(span.columnSpan);
    final mainExtent = span.mainAxisExtent ?? childSize.height;
    final crossAxisOffset = _crossAxisOffsetForColumn(placement.columnIndex);
    final alignment = span.alignment;
    final layoutOffset = placement.mainAxisOffset;
    final consumedExtent = mainExtent + mainAxisSpacing;
    for (var i = 0; i < span.columnSpan; i++) {
      columnHeights[placement.columnIndex + i] = layoutOffset + consumedExtent;
    }
    final result = GridChildPlacement(
      index: index,
      layoutOffset: layoutOffset,
      mainAxisExtent: mainExtent,
      crossAxisOffset: crossAxisOffset,
      crossAxisExtent: crossExtent,
      alignment: alignment,
      columnStart: placement.columnIndex,
      columnSpan: span.columnSpan,
    );
    _placements[index] = result;
    return result;
  }

  @override
  int estimateMinIndexForScrollOffset(double scrollOffset) {
    if (_placements.isEmpty) {
      return 0;
    }
    int candidate = _placements.firstKey()!;
    for (final entry in _placements.entries) {
      if (entry.value.trailingOffset <= scrollOffset) {
        candidate = entry.key;
      } else {
        break;
      }
    }
    return candidate;
  }

  @override
  double estimateMaxScrollOffset(int? itemCount) {
    if (columnHeights.isEmpty) {
      return 0;
    }
    final maxHeight = columnHeights.reduce(math.max);
    return math.max(0, maxHeight - mainAxisSpacing);
  }

  @override
  void dropCache(int leadingIndex, int trailingIndex) {
    final remove = <int>[];
    for (final key in _placements.keys) {
      if (key >= leadingIndex && key <= trailingIndex) {
        remove.add(key);
      }
    }
    for (final key in remove) {
      _placements.remove(key);
      _spanCache.remove(key);
    }
  }

  @override
  void reset() {
    for (var i = 0; i < columnCount; i++) {
      columnHeights[i] = 0;
      columnOffsets[i] = _crossAxisOffsetForColumn(i);
    }
    _placements.clear();
    _spanCache.clear();
  }

  @override
  void updateItemCount(int? itemCount) {
    if (itemCount == null) {
      return;
    }
    final remove = _placements.keys.where((k) => k >= itemCount).toList();
    for (final key in remove) {
      _placements.remove(key);
      _spanCache.remove(key);
    }
  }

  @override
  double get maxColumnExtent => columnHeights.fold<double>(0, math.max);

  @override
  Iterable<GridChildPlacement> get cachedPlacements => _placements.values;

  GridSpanConfiguration _resolveSpan(int index) {
    return _spanCache.putIfAbsent(
      index,
      () => spanResolver(index) ?? const GridSpanConfiguration(),
    );
  }

  _ColumnPlacement _resolveColumnPlacement(int span) {
    final effectiveSpan = math.min(span, columnCount);
    double bestOffset = double.infinity;
    int bestColumn = 0;
    for (var i = 0; i <= columnCount - effectiveSpan; i++) {
      final double candidate = _windowMaxHeight(i, effectiveSpan);
      if (candidate < bestOffset - 0.1) {
        bestOffset = candidate;
        bestColumn = i;
      }
    }
    return _ColumnPlacement(bestColumn, bestOffset.isFinite ? bestOffset : 0);
  }

  double _windowMaxHeight(int start, int span) {
    double maxHeight = 0;
    for (var i = 0; i < span; i++) {
      maxHeight = math.max(maxHeight, columnHeights[start + i]);
    }
    return maxHeight;
  }

  double _crossAxisOffsetForColumn(int column) {
    final baseOffset = column * (_columnWidth + crossAxisSpacing);
    if (!reverseCrossAxis) {
      return baseOffset + _crossAxisInset;
    }
    return context.crossAxisExtent -
        _crossAxisExtentForSpan(1) -
        baseOffset -
        _crossAxisInset;
  }

  double _crossAxisExtentForSpan(int span) {
    final effective = math.min(span, columnCount);
    final gaps = math.max(effective - 1, 0) * crossAxisSpacing;
    return _columnWidth * effective + gaps;
  }
}

class _ColumnPlacement {
  const _ColumnPlacement(this.columnIndex, this.mainAxisOffset);
  final int columnIndex;
  final double mainAxisOffset;
}
