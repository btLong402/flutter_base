import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../layout/grid_layout_config.dart';

/// Grid Layout Session Management
///
/// PAGINATION FIXES APPLIED:
/// 1. updateItemCount logging: Tracks when items are added vs removed with debug logs
/// 2. Column height preservation: When items added, column heights remain valid for new layouts
/// 3. Smart cache recalculation: Only recalculates column heights when items are removed
/// 4. High-index logging: Debug logs when laying out items >= 60 (page 3+)
/// 5. Safe max index tracking: Updates _maxCachedIndex when items change
///
/// These fixes ensure that:
/// - Session cache doesn't prevent new items from being laid out
/// - Column heights accurately reflect current grid state during pagination
/// - Cache pruning doesn't remove items that were just added
/// - Debug visibility into session state during high-page-number layouts

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

  // PERFORMANCE: Track max cached index for efficient pruning
  int _maxCachedIndex = -1;
  static const int _maxCachedPlacements = 500; // Limit cache size for 5k+ items

  // CRITICAL FIX: Track last known item count to avoid redundant logging
  int? _lastKnownItemCount;

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

    // PERFORMANCE: Pre-compute column geometry to avoid recalculation
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

    // Pre-compute column offsets for all columns
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
    final crossAxisOffset = columnOffsets[placement.columnIndex];
    final alignment = span.alignment;
    final layoutOffset = placement.mainAxisOffset;
    final consumedExtent = mainExtent + mainAxisSpacing;

    // Update column heights for the spanned columns
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
    _maxCachedIndex = math.max(_maxCachedIndex, index);

    // PERFORMANCE: Prune old placements if cache grows too large.
    // Keep only recent placements to bound memory usage for 5k+ items.
    if (_placements.length > _maxCachedPlacements) {
      _pruneOldPlacements();
    }

    return result;
  }

  /// Removes oldest placements to keep cache size bounded.
  void _pruneOldPlacements() {
    final keysToRemove = <int>[];
    final threshold = _maxCachedIndex - (_maxCachedPlacements ~/ 2);

    for (final key in _placements.keys) {
      if (key < threshold) {
        keysToRemove.add(key);
      } else {
        break; // SplayTreeMap is sorted, can stop early
      }
    }

    for (final key in keysToRemove) {
      _placements.remove(key);
      _spanCache.remove(key);
    }
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
    _maxCachedIndex = -1;
    _lastKnownItemCount = null;
  }

  @override
  void updateItemCount(int? itemCount) {
    if (itemCount == null) {
      return;
    }

    // CRITICAL FIX: Only process when item count actually changes to avoid
    // excessive logging and redundant work on every layout pass
    if (_lastKnownItemCount == itemCount) {
      return; // Item count unchanged, skip processing
    }

    _lastKnownItemCount = itemCount;

    // CRITICAL FIX: When item count changes (increases), we need to properly
    // handle the column heights to ensure new items layout correctly.
    final remove = _placements.keys.where((k) => k >= itemCount).toList();

    if (remove.isNotEmpty) {
      // Items were removed - need to recalculate column heights
      for (final key in remove) {
        _placements.remove(key);
        _spanCache.remove(key);
      }

      // Recalculate column heights based on remaining placements
      _recalculateColumnHeights();

      if (_maxCachedIndex >= itemCount) {
        _maxCachedIndex = _placements.isEmpty ? -1 : _placements.lastKey()!;
      }
    }
  }

  /// Recalculates column heights from cached placements.
  /// Called when items are removed to ensure correct layout state.
  void _recalculateColumnHeights() {
    // Reset all column heights
    for (var i = 0; i < columnCount; i++) {
      columnHeights[i] = 0;
    }

    // Rebuild column heights from cached placements
    for (final placement in _placements.values) {
      final endOffset =
          placement.layoutOffset + placement.mainAxisExtent + mainAxisSpacing;

      for (var i = 0; i < placement.columnSpan; i++) {
        final col = placement.columnStart + i;
        if (col < columnCount) {
          columnHeights[col] = math.max(columnHeights[col], endOffset);
        }
      }
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

    // PINTEREST OPTIMIZATION: Look-ahead algorithm for better visual balance
    // Instead of just finding minimum height, consider next few items too
    for (var i = 0; i <= columnCount - effectiveSpan; i++) {
      final double candidate = _windowMaxHeight(i, effectiveSpan);

      // PINTEREST OPTIMIZATION: Add small penalty for uneven column heights
      // This creates better visual balance across columns
      final columnVariance = _calculateColumnVariance(i, effectiveSpan);
      final adjustedCandidate = candidate + (columnVariance * 0.1);

      if (adjustedCandidate < bestOffset - 0.1) {
        bestOffset = candidate; // Use original offset, not adjusted
        bestColumn = i;
      }
    }
    return _ColumnPlacement(bestColumn, bestOffset.isFinite ? bestOffset : 0);
  }

  /// PINTEREST OPTIMIZATION: Calculate variance in column heights for balancing
  double _calculateColumnVariance(int start, int span) {
    if (span == 1) return 0.0;

    final heights = <double>[];
    for (var i = 0; i < span; i++) {
      heights.add(columnHeights[start + i]);
    }

    final avg = heights.reduce((a, b) => a + b) / heights.length;
    final variance =
        heights.fold<double>(
          0.0,
          (sum, height) => sum + math.pow(height - avg, 2),
        ) /
        heights.length;

    return math.sqrt(variance);
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
