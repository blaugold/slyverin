import 'package:flutter/rendering.dart';

abstract class RenderSliverChildrenWithPaintOffset {
  double childMainAxisPosition(RenderObject child);

  double childPaintExtent(RenderObject child);

  void setChildParentData(
    RenderObject child,
    SliverConstraints constraints,
    SliverGeometry geometry,
  ) {
    final SliverPhysicalParentData childParentData =
        child.parentData as SliverPhysicalParentData;
    assert(constraints.axisDirection != null);
    assert(constraints.growthDirection != null);
    switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      case AxisDirection.up:
        childParentData.paintOffset = Offset(
          0.0,
          geometry.paintExtent -
              childMainAxisPosition(child) -
              childPaintExtent(child),
        );
        break;
      case AxisDirection.right:
        childParentData.paintOffset = Offset(childMainAxisPosition(child), 0.0);
        break;
      case AxisDirection.down:
        childParentData.paintOffset = Offset(0.0, childMainAxisPosition(child));
        break;
      case AxisDirection.left:
        childParentData.paintOffset = Offset(
          geometry.paintExtent -
              childMainAxisPosition(child) -
              childPaintExtent(child),
          0.0,
        );
        break;
    }
    assert(childParentData.paintOffset != null);
  }
}
