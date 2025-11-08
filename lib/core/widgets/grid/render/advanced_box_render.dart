import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../layout/grid_layout_config.dart';
import '../layout/layout_strategies.dart';

class AdvancedGridBoxParentData extends ContainerBoxParentData<RenderBox> {
  int index = 0;
  int columnSpan = 1;
  AlignmentGeometry alignment = AlignmentDirectional.topStart;
  double crossAxisExtent = 0;
}

class RenderAdvancedGridBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, AdvancedGridBoxParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, AdvancedGridBoxParentData> {
  RenderAdvancedGridBox({
    required GridLayoutConfig layout,
    required TextDirection textDirection,
  }) : _layout = layout,
       _textDirection = textDirection;

  GridLayoutConfig _layout;
  TextDirection _textDirection;

  GridLayoutConfig get layoutConfig => _layout;

  set layoutConfig(GridLayoutConfig value) {
    if (identical(value, _layout)) {
      return;
    }
    _layout = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection value) {
    if (value == _textDirection) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! AdvancedGridBoxParentData) {
      child.parentData = AdvancedGridBoxParentData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final double maxWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth();
    assert(
      maxWidth.isFinite && maxWidth > 0,
      'AdvancedGridPanel requires bounded width.',
    );

    final EdgeInsets resolvedPadding =
        _layout.padding?.resolve(_textDirection) ?? EdgeInsets.zero;
    final double innerWidth = math.max(
      0,
      maxWidth - resolvedPadding.horizontal,
    );

    final GridLayoutStrategy strategy = createLayoutStrategy(
      _layout,
      _textDirection,
    );
    final BoxGridLayoutDescriptor descriptor = strategy.describeBoxLayout(
      innerWidth,
    );
    final _BoxColumnEngine engine = _BoxColumnEngine(
      descriptor: descriptor,
      crossAxisExtent: innerWidth,
      textDirection: _textDirection,
    );

    RenderBox? child = firstChild;
    int index = 0;
    while (child != null) {
      final AdvancedGridBoxParentData childParentData =
          child.parentData! as AdvancedGridBoxParentData;
      final GridSpanConfiguration span =
          descriptor.spanResolver(index) ?? const GridSpanConfiguration();
      final double crossExtent = engine.crossAxisExtentForSpan(span.columnSpan);
      final double? mainExtent =
          span.mainAxisExtent ??
          (span.aspectRatio != null && span.aspectRatio! > 0
              ? crossExtent / span.aspectRatio!
              : null);
      final BoxConstraints childConstraints = BoxConstraints(
        minWidth: crossExtent,
        maxWidth: crossExtent,
        minHeight: mainExtent ?? 0,
        maxHeight: mainExtent ?? double.infinity,
      );
      child.layout(childConstraints, parentUsesSize: true);
      final _BoxChildPlacement placement = engine.placeChild(
        index,
        child.size,
        span,
      );

      final Alignment resolvedAlignment = span.alignment.resolve(
        _textDirection,
      );
      final Offset alignmentOffset = resolvedAlignment.alongSize(
        Size(
          placement.crossAxisExtent - child.size.width,
          placement.mainAxisExtent - child.size.height,
        ),
      );
      final double crossOffset =
          resolvedPadding.left + placement.crossAxisOffset + alignmentOffset.dx;
      final double mainOffset =
          resolvedPadding.top + placement.layoutOffset + alignmentOffset.dy;

      childParentData
        ..index = index
        ..columnSpan = placement.columnSpan
        ..crossAxisExtent = placement.crossAxisExtent
        ..alignment = span.alignment
        ..offset = Offset(crossOffset, mainOffset);

      child = childParentData.nextSibling;
      index++;
    }

    final double contentHeight =
        resolvedPadding.vertical + engine.maxColumnExtent;
    size = constraints.constrain(Size(maxWidth, contentHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final AdvancedGridBoxParentData parentData =
          child.parentData! as AdvancedGridBoxParentData;
      context.paintChild(child, offset + parentData.offset);
      child = parentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final AdvancedGridBoxParentData parentData =
          child.parentData! as AdvancedGridBoxParentData;
      final RenderBox target = child;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return target.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = parentData.previousSibling;
    }
    return false;
  }
}

class _BoxColumnEngine {
  _BoxColumnEngine({
    required this.descriptor,
    required this.crossAxisExtent,
    required this.textDirection,
  }) : columnHeights = List<double>.filled(
         descriptor.columnCount,
         0,
         growable: false,
       ) {
    _configure();
  }

  final BoxGridLayoutDescriptor descriptor;
  final double crossAxisExtent;
  final TextDirection textDirection;
  final List<double> columnHeights;
  late double _columnWidth;
  double _crossAxisInset = 0;

  void _configure() {
    if (descriptor.fixedColumnWidth != null) {
      _columnWidth = descriptor.fixedColumnWidth!;
      final double totalWidth = _crossAxisExtentForSpan(descriptor.columnCount);
      _crossAxisInset = descriptor.expandToFit
          ? 0
          : math.max(0, (crossAxisExtent - totalWidth) / 2);
    } else {
      final double gaps =
          descriptor.crossAxisSpacing * math.max(descriptor.columnCount - 1, 0);
      final double available = math.max(0, crossAxisExtent - gaps);
      _columnWidth = descriptor.columnCount > 0
          ? available / descriptor.columnCount
          : 0;
      _crossAxisInset = descriptor.expandToFit
          ? 0
          : math.max(0, (crossAxisExtent - available - gaps) / 2);
    }
  }

  _BoxChildPlacement placeChild(
    int index,
    Size childSize,
    GridSpanConfiguration span,
  ) {
    final int effectiveSpan = math.min(span.columnSpan, descriptor.columnCount);
    final _ColumnSlot placement = _resolveColumnPlacement(effectiveSpan);
    final double crossExtent = _crossAxisExtentForSpan(effectiveSpan);
    final double mainExtent = span.mainAxisExtent ?? childSize.height;
    final double crossOffset = _crossAxisOffsetForColumn(placement.columnIndex);
    final double layoutOffset = placement.mainAxisOffset;
    for (var i = 0; i < effectiveSpan; i++) {
      columnHeights[placement.columnIndex + i] =
          layoutOffset + mainExtent + descriptor.mainAxisSpacing;
    }
    return _BoxChildPlacement(
      layoutOffset: layoutOffset,
      crossAxisOffset: crossOffset,
      mainAxisExtent: mainExtent,
      crossAxisExtent: crossExtent,
      columnSpan: effectiveSpan,
    );
  }

  double get maxColumnExtent {
    if (columnHeights.isEmpty) {
      return 0;
    }
    final double maxExtent = columnHeights.reduce(math.max);
    return math.max(0, maxExtent - descriptor.mainAxisSpacing);
  }

  double _crossAxisExtentForSpan(int span) {
    final int effective = math.min(span, descriptor.columnCount);
    final double gaps =
        descriptor.crossAxisSpacing * math.max(effective - 1, 0);
    return _columnWidth * effective + gaps;
  }

  double _crossAxisOffsetForColumn(int column) {
    final double base = column * (_columnWidth + descriptor.crossAxisSpacing);
    final double offset = base + _crossAxisInset;
    if (!descriptor.reverseCrossAxis) {
      return offset;
    }
    return crossAxisExtent - _crossAxisExtentForSpan(1) - offset;
  }

  _ColumnSlot _resolveColumnPlacement(int span) {
    double bestOffset = double.infinity;
    int bestColumn = 0;
    for (int column = 0; column <= descriptor.columnCount - span; column++) {
      final double candidate = _windowMaxHeight(column, span);
      if (candidate < bestOffset - 0.1) {
        bestOffset = candidate;
        bestColumn = column;
      }
    }
    if (!bestOffset.isFinite) {
      bestOffset = 0;
    }
    return _ColumnSlot(bestColumn, bestOffset);
  }

  double _windowMaxHeight(int start, int span) {
    double height = 0;
    for (int offset = 0; offset < span; offset++) {
      height = math.max(height, columnHeights[start + offset]);
    }
    return height;
  }

  double crossAxisExtentForSpan(int span) => _crossAxisExtentForSpan(span);
}

class _BoxChildPlacement {
  const _BoxChildPlacement({
    required this.layoutOffset,
    required this.crossAxisOffset,
    required this.mainAxisExtent,
    required this.crossAxisExtent,
    required this.columnSpan,
  });

  final double layoutOffset;
  final double crossAxisOffset;
  final double mainAxisExtent;
  final double crossAxisExtent;
  final int columnSpan;

  double get trailingOffset => layoutOffset + mainAxisExtent;
}

class _ColumnSlot {
  const _ColumnSlot(this.columnIndex, this.mainAxisOffset);
  final int columnIndex;
  final double mainAxisOffset;
}
