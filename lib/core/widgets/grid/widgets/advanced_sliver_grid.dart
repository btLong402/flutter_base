import 'package:flutter/widgets.dart';

import '../animation/grid_animation_config.dart';
import '../layout/grid_layout_config.dart';
import '../render/advanced_sliver_render.dart';

class AdvancedSliverGrid extends SliverMultiBoxAdaptorWidget {
  const AdvancedSliverGrid({
    super.key,
    required GridLayoutConfig layout,
    required super.delegate,
  }) : _layout = layout;

  final GridLayoutConfig _layout;

  GridLayoutConfig get layout => _layout;

  @override
  RenderSliverAdvancedGrid createRenderObject(BuildContext context) {
    final textDirection = Directionality.of(context);
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverAdvancedGrid(
      layout: _layout,
      childManager: element,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSliverAdvancedGrid renderObject,
  ) {
    renderObject
      ..layoutConfig = _layout
      ..textDirection = Directionality.of(context);
  }
}

class AdvancedSliverGridList extends AdvancedSliverGrid {
  AdvancedSliverGridList({
    super.key,
    required GridLayoutConfig layout,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    GridAnimationConfig? animation,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    int semanticIndexOffset = 0,
    SemanticIndexCallback semanticIndexCallback = _defaultSemanticIndexCallback,
  }) : super(
         layout: layout,
         delegate: SliverChildBuilderDelegate(
           animation == null
               ? itemBuilder
               : (context, index) => animation.wrap(
                   context,
                   index,
                   itemBuilder(context, index),
                 ),
           childCount: itemCount,
           addAutomaticKeepAlives: addAutomaticKeepAlives,
           addRepaintBoundaries: addRepaintBoundaries,
           addSemanticIndexes: addSemanticIndexes,
           semanticIndexCallback: semanticIndexCallback,
           semanticIndexOffset: semanticIndexOffset,
         ),
       );

  static int? _defaultSemanticIndexCallback(Widget _, int index) => index;
}
