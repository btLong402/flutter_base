import 'package:flutter/widgets.dart';

import '../animation/grid_animation_config.dart';
import '../layout/grid_layout_config.dart';
import '../render/advanced_box_render.dart';

class AdvancedGridPanel extends MultiChildRenderObjectWidget {
  AdvancedGridPanel.builder({
    super.key,
    required this.layout,
    required GridItemBuilder itemBuilder,
    required int itemCount,
    GridAnimationConfig? animation,
  }) : super(
         children: List<Widget>.generate(
           itemCount,
           (index) => _GridPanelChild(
             itemBuilder: itemBuilder,
             index: index,
             animation: animation,
           ),
           growable: false,
         ),
       );

  final GridLayoutConfig layout;

  @override
  RenderAdvancedGridBox createRenderObject(BuildContext context) {
    return RenderAdvancedGridBox(
      layout: layout,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderAdvancedGridBox renderObject,
  ) {
    renderObject
      ..layoutConfig = layout
      ..textDirection = Directionality.of(context);
  }
}

class _GridPanelChild extends StatelessWidget {
  const _GridPanelChild({
    required this.itemBuilder,
    required this.index,
    this.animation,
  });

  final GridItemBuilder itemBuilder;
  final int index;
  final GridAnimationConfig? animation;

  @override
  Widget build(BuildContext context) {
    final child = itemBuilder(context, index);
    if (animation == null) {
      return child;
    }
    return animation!.wrap(context, index, child);
  }
}
