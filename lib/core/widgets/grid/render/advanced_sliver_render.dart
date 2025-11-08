import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../internal/grid_session.dart';
import '../layout/grid_layout_config.dart';
import '../layout/layout_strategies.dart';

class AdvancedSliverGridParentData extends SliverGridParentData {
  double crossAxisExtent = 0;
  AlignmentGeometry alignment = AlignmentDirectional.topStart;

  @override
  String toString() {
    return 'crossAxisExtent=$crossAxisExtent; alignment=$alignment; '
        '${super.toString()}';
  }
}

class RenderSliverAdvancedGrid extends RenderSliverMultiBoxAdaptor {
  RenderSliverAdvancedGrid({
    required GridLayoutConfig layout,
    required super.childManager,
    required TextDirection textDirection,
  }) : _layoutConfig = layout,
       _textDirection = textDirection,
       _strategy = createLayoutStrategy(layout, textDirection);

  GridLayoutConfig _layoutConfig;
  TextDirection _textDirection;
  GridLayoutStrategy _strategy;
  GridLayoutSession? _session;
  List<int> _pendingLeadingGarbage = const <int>[];
  List<int> _pendingTrailingGarbage = const <int>[];

  GridLayoutConfig get layoutConfig => _layoutConfig;

  set layoutConfig(GridLayoutConfig value) {
    if (identical(value, _layoutConfig)) {
      return;
    }
    _layoutConfig = value;
    _strategy = createLayoutStrategy(value, _textDirection);
    _session?.reset();
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    _strategy = createLayoutStrategy(_layoutConfig, _textDirection);
    _session?.reset();
    markNeedsLayout();
  }

  GridLayoutSession get _activeSession {
    final context = GridLayoutContext(
      constraints: constraints,
      textDirection: _textDirection,
      axisDirection: constraints.axisDirection,
      growthDirection: constraints.growthDirection,
    );
    if (_session == null) {
      _session = _strategy.startSession(context);
    }
    _session!.ensureForLayout(context);
    return _session!;
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! AdvancedSliverGridParentData) {
      child.parentData = AdvancedSliverGridParentData();
    }
  }

  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final session = _activeSession;
    final double scrollOffset = math.max(
      0.0,
      constraints.scrollOffset + constraints.cacheOrigin,
    );
    final double remainingExtent =
        constraints.remainingPaintExtent - constraints.overlap;
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    final int firstIndexEstimate = session.estimateMinIndexForScrollOffset(
      scrollOffset,
    );

    final int? childCount = childManager.childCount;
    if (childCount != null && childCount == 0) {
      collectGarbage(childCount, childCount);
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }

    final List<int> leadingGarbageIndexes = <int>[];
    RenderBox? child = firstChild;
    while (child != null) {
      final SliverMultiBoxAdaptorParentData data =
          child.parentData! as SliverMultiBoxAdaptorParentData;
      if (data.index! >= firstIndexEstimate) {
        break;
      }
      leadingGarbageIndexes.add(data.index!);
      child = childAfter(child);
    }
    final int leadingGarbage = leadingGarbageIndexes.length;
    _pendingLeadingGarbage = leadingGarbageIndexes;

    RenderBox? previousChild;
    if (firstChild == null) {
      if (!addInitialChild(index: firstIndexEstimate)) {
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    } else {
      while (indexOf(firstChild!) > firstIndexEstimate) {
        final int index = indexOf(firstChild!) - 1;
        final BoxConstraints childConstraints = session
            .resolveConstraintsForIndex(index);
        final RenderBox? inserted = insertAndLayoutLeadingChild(
          childConstraints,
          parentUsesSize: true,
        );
        if (inserted == null) {
          break;
        }
      }
    }

    RenderBox? currentChild = firstChild;
    double maxScrollExtent = 0;
    double leadingLayoutOffset = double.nan;
    int trailingVisibleIndex = indexOf(firstChild!);
    bool didReachEnd = false;

    while (currentChild != null) {
      final AdvancedSliverGridParentData childParentData =
          currentChild.parentData! as AdvancedSliverGridParentData;
      final int index = childParentData.index!;
      final BoxConstraints childConstraints = session
          .resolveConstraintsForIndex(index);
      currentChild.layout(childConstraints, parentUsesSize: true);
      final Size size = currentChild.size;
      final GridChildPlacement placement = session.recordChildLayout(
        index,
        size,
      );

      childParentData
        ..layoutOffset = placement.layoutOffset
        ..crossAxisOffset = placement.crossAxisOffset
        ..crossAxisExtent = placement.crossAxisExtent
        ..alignment = placement.alignment;

      if (!leadingLayoutOffset.isFinite) {
        leadingLayoutOffset = placement.layoutOffset;
      }
      // mainAxisPaintOffset is tracked for paint offset assignment above; no
      // additional accumulation required beyond scroll extent updates.
      maxScrollExtent = math.max(maxScrollExtent, placement.trailingOffset);
      trailingVisibleIndex = index;

      final bool reachedEnd = placement.layoutOffset >= targetEndScrollOffset;
      previousChild = currentChild;
      currentChild = childAfter(currentChild);
      if (reachedEnd) {
        break;
      }
      if (currentChild == null) {
        final int nextIndex = index + 1;
        if (childCount != null && nextIndex >= childCount) {
          didReachEnd = true;
          break;
        }
        final BoxConstraints nextConstraints = session
            .resolveConstraintsForIndex(nextIndex);
        currentChild = insertAndLayoutChild(
          nextConstraints,
          after: previousChild,
          parentUsesSize: true,
        );
        if (currentChild == null) {
          didReachEnd = true;
          break;
        }
      }
    }

    final List<int> trailingGarbageIndexes = <int>[];
    RenderBox? trailingChild = lastChild;
    while (trailingChild != null) {
      final SliverMultiBoxAdaptorParentData data =
          trailingChild.parentData! as SliverMultiBoxAdaptorParentData;
      if (data.index! <= trailingVisibleIndex) {
        break;
      }
      trailingGarbageIndexes.add(data.index!);
      trailingChild = childBefore(trailingChild);
    }
    final int trailingGarbage = trailingGarbageIndexes.length;
    _pendingTrailingGarbage = trailingGarbageIndexes;

    final double fromOffset = leadingLayoutOffset.isFinite
        ? leadingLayoutOffset
        : constraints.scrollOffset;
    final double paintExtent = calculatePaintOffset(
      constraints,
      from: fromOffset,
      to: maxScrollExtent,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: fromOffset,
      to: maxScrollExtent,
    );

    final double estimatedMaxScrollExtent = session.estimateMaxScrollOffset(
      childCount,
    );

    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollExtent,
      paintExtent: paintExtent,
      maxPaintExtent: math.max(maxScrollExtent, estimatedMaxScrollExtent),
      cacheExtent: cacheExtent,
      hasVisualOverflow:
          maxScrollExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0,
    );

    session.updateItemCount(childCount);
    collectGarbage(leadingGarbage, trailingGarbage);

    if (!didReachEnd && childCount != null) {
      didReachEnd = trailingVisibleIndex >= childCount - 1;
    }
    childManager.setDidUnderflow(didReachEnd);
    childManager.didFinishLayout();
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final ParentData? rawParentData = child.parentData;
    if (rawParentData is AdvancedSliverGridParentData) {
      return rawParentData.crossAxisOffset ?? 0;
    }
    assert(() {
      debugPrint(
        'RenderSliverAdvancedGrid encountered unexpected parentData '
        '${rawParentData.runtimeType} when resolving cross axis position.',
      );
      return true;
    }());
    return 0;
  }

  @override
  void dispose() {
    _session?.reset();
    super.dispose();
  }

  @override
  void collectGarbage(int leadingGarbage, int trailingGarbage) {
    final List<int> leading = _pendingLeadingGarbage;
    final List<int> trailing = _pendingTrailingGarbage;
    _pendingLeadingGarbage = const <int>[];
    _pendingTrailingGarbage = const <int>[];
    super.collectGarbage(leadingGarbage, trailingGarbage);
    if (_session == null) {
      return;
    }
    if (leading.isNotEmpty) {
      _session!.dropCache(leading.reduce(math.min), leading.reduce(math.max));
    }
    if (trailing.isNotEmpty) {
      _session!.dropCache(trailing.reduce(math.min), trailing.reduce(math.max));
    }
  }
}
