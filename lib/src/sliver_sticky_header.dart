import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A sliver with sticky [header] which stays at the top of the viewport until
/// the sliver scrolls of completely. The [header] must be a box and the [body]
/// a sliver.
class SliverStickyHeader extends MultiChildRenderObjectWidget {
  SliverStickyHeader({
    Key key,
    this.reverse = false,
    this.overlayHeader = false,
    this.header,
    this.body,
  })  : assert(reverse != null),
        assert(overlayHeader != null),
        assert(header != null),
        assert(body != null),
        super(key: key, children: [header, body]);

  /// Setting [reverse] to `true` places [header] at the opposite end of the
  /// sliver than normal. This is most useful when a [SliverStickyHeader] is
  /// above [ScrollView.center] and you want to place the header at the top.
  /// Above the center slivers grow in the opposite direction and this option
  /// counteracts this behaviour. When [reverse] is `false` (default) and
  /// [ScrollView.reverse] is `false`, headers in slivers above
  /// [ScrollView.center] appear at the bottom.
  final bool reverse;

  /// When `true` the [header] is overlaid over the [body], even when the sliver
  /// has not been scrolled. This is in contrast to the default behaviour, where
  /// the header takes up space along the scroll axis.
  final bool overlayHeader;

  /// The widget which is sticking to viewport edges. Must be a box.
  final Widget header;

  /// The widget which is scrolling normally. Must be a sliver.
  final Widget body;

  @override
  RenderSliverStickyHeader createRenderObject(BuildContext context) {
    return RenderSliverStickyHeader()
      ..reverse = reverse
      ..overlayHeader = overlayHeader;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverStickyHeader renderObject) {
    renderObject
      ..reverse = reverse
      ..overlayHeader = overlayHeader;
  }
}

/// Parent data for children of [RenderSliverStickyHeader].
class SliverStickyHeaderParentData extends SliverPhysicalParentData
    with ContainerParentDataMixin<RenderObject> {}

/// [RenderSliver] which lays out a [RenderBox] and a [RenderSliver] so that the
/// box stays visible at the leading visible edge of this sliver until the
/// sliver completely scrolls of. The box and the sliver are laid out one after
/// the other like in a list.
class RenderSliverStickyHeader extends RenderSliver
    with
        RenderSliverHelpers,
        ContainerRenderObjectMixin<RenderObject, SliverStickyHeaderParentData> {
  bool _reverse = false;

  bool get reverse {
    return _reverse;
  }

  set reverse(bool reverse) {
    if (_reverse != reverse) {
      _reverse = reverse;
      markNeedsLayout();
    }
  }

  bool _overlayHeader = false;

  bool get overlayHeader {
    return _overlayHeader;
  }

  set overlayHeader(bool overlayHeader) {
    if (_overlayHeader != overlayHeader) {
      _overlayHeader = overlayHeader;
      markNeedsLayout();
    }
  }

  RenderBox get _header {
    assert(
      firstChild is RenderBox,
      'The header must be rendered by RenderBox.',
    );
    return firstChild as RenderBox;
  }

  RenderSliver get _body {
    assert(
      lastChild is RenderSliver,
      'The body must be rendered by RenderSliver.',
    );
    return lastChild as RenderSliver;
  }

  /// Scroll extent of the [header].
  double _headerExtent;

  /// Scroll extent of the [body].
  double _bodyExtent;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverStickyHeaderParentData)
      child.parentData = SliverStickyHeaderParentData();
  }

  @override
  void performLayout() {
    if (reverse) {
      _performReversedLayout();
    } else {
      _performNormalLayout();
    }

    _updateGeometry();

    _updateChildParentData(_header);
    _updateChildParentData(_body);
  }

  void _performNormalLayout() {
    _header.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    _updateHeaderExtent();

    _body.layout(
      overlayHeader
          ? constraints
          : _adjustConstraintsForLeadingBox(
              constraints: constraints,
              extent: _headerExtent,
            ),
      parentUsesSize: true,
    );
    _bodyExtent = _body.geometry.scrollExtent;
  }

  void _performReversedLayout() {
    _body.layout(constraints, parentUsesSize: true);
    _bodyExtent = _body.geometry.scrollExtent;

    _header.layout(
      // We could use the body geometry to derive more accurate
      // constraints, but we use this simpler approach while sufficient.
      overlayHeader
          ? constraints.asBoxConstraints()
          : _adjustConstraintsForLeadingBox(
              constraints: constraints,
              extent: _bodyExtent,
            ).asBoxConstraints(),
      parentUsesSize: true,
    );
    _updateHeaderExtent();
  }

  void _updateHeaderExtent() {
    switch (constraints.axis) {
      case Axis.horizontal:
        _headerExtent = _header.size.width;
        break;
      case Axis.vertical:
        _headerExtent = _header.size.height;
        break;
    }
  }

  void _updateGeometry() {
    final scrollExtent = overlayHeader
        ? max(_headerExtent, _bodyExtent)
        : _headerExtent + _bodyExtent;

    geometry = SliverGeometry(
      scrollExtent: scrollExtent,
      maxPaintExtent: scrollExtent,
      hasVisualOverflow: true, // This could be optimized.
      paintExtent: min(
        constraints.remainingPaintExtent,
        max(0, scrollExtent - constraints.scrollOffset),
      ),
    );
  }

  /// This method implements a general way to compute the paint offset for
  /// a [child], which is used to implement [_paintChild] and
  /// [applyPaintTransform].
  void _updateChildParentData(RenderObject child) {
    final parentData = child.parentData as SliverStickyHeaderParentData;
    final childExtent = _childPaintExtent(child);
    final childMainAxisPosition = this.childMainAxisPosition(child);

    switch (applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    )) {
      case AxisDirection.up:
        parentData.paintOffset = Offset(
          0.0,
          geometry.paintExtent - childMainAxisPosition - childExtent,
        );
        break;
      case AxisDirection.down:
        parentData.paintOffset = Offset(0.0, childMainAxisPosition);
        break;
      case AxisDirection.left:
        parentData.paintOffset = Offset(
          geometry.paintExtent - childMainAxisPosition - childExtent,
          0.0,
        );
        break;
      case AxisDirection.right:
        parentData.paintOffset = Offset(childMainAxisPosition, 0.0);
        break;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintChild(_body, context, offset);
    _paintChild(_header, context, offset);
  }

  void _paintChild(RenderObject child, PaintingContext context, Offset offset) {
    if (geometry.visible) {
      final parentData = child.parentData as SliverStickyHeaderParentData;
      context.paintChild(child, offset + parentData.paintOffset);
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final parentData = child.parentData as SliverStickyHeaderParentData;
    parentData.applyPaintTransform(transform);
  }

  // ignore: missing_return
  double _childPaintExtent(RenderObject child) {
    if (child == _header) {
      return _headerExtent;
    } else if (child == _body) {
      return _body.geometry.paintExtent;
    }
  }

  /// The math in this method is a the heart of positioning the children.
  /// It is important to realize that the [body] sliver is doing its own
  /// scrolling and needs to be positioned like a window.
  @override
  // ignore: missing_return
  double childMainAxisPosition(RenderObject child) {
    if (reverse) {
      if (child == _header) {
        return min(
          max(0, constraints.remainingPaintExtent - _headerExtent),
          (overlayHeader ? _bodyExtent - _headerExtent : _bodyExtent) -
              constraints.scrollOffset,
        );
      } else if (child == _body) {
        return 0;
      }
    } else {
      if (child == _header) {
        return min(
            0,
            (overlayHeader ? _bodyExtent - _headerExtent : _bodyExtent) -
                constraints.scrollOffset);
      } else if (child == _body) {
        return overlayHeader
            ? 0
            : max(0, _headerExtent - constraints.scrollOffset);
      }
    }
  }

  @override
  // ignore: missing_return
  double childScrollOffset(RenderObject child) {
    // Computes the scroll offsets as if the position of the header is static.

    if (reverse) {
      if (child == _header) {
        return overlayHeader ? _bodyExtent - _headerExtent : _bodyExtent;
      } else {
        return 0;
      }
    } else {
      if (child == _header) {
        return 0;
      } else {
        return overlayHeader ? 0 : _headerExtent;
      }
    }
  }

  @override
  bool hitTestChildren(SliverHitTestResult result,
      {double mainAxisPosition, double crossAxisPosition}) {
    return hitTestBoxChild(
          BoxHitTestResult.wrap(result),
          _header,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition,
        ) ||
        _body.hitTest(
          result,
          mainAxisPosition: mainAxisPosition - childMainAxisPosition(_body),
          crossAxisPosition: crossAxisPosition,
        );
  }
}

/// Adjusts [constraints] to layout a sliver behind a box, which has a size of
/// [extent] in the main axis.
SliverConstraints _adjustConstraintsForLeadingBox({
  @required SliverConstraints constraints,
  @required double extent,
}) {
  final scrollOffset = max(0.0, constraints.scrollOffset - extent);
  final nonCacheExtent = constraints.scrollOffset + constraints.cacheOrigin;
  final cacheExtent = max(0.0, extent - nonCacheExtent);
  return constraints.copyWith(
    scrollOffset: scrollOffset,
    overlap: 0,
    precedingScrollExtent: constraints.precedingScrollExtent + extent,
    remainingPaintExtent: max(
      0,
      constraints.remainingPaintExtent - (extent - constraints.scrollOffset),
    ),
    cacheOrigin: max(-scrollOffset, constraints.cacheOrigin),
    remainingCacheExtent:
        max(0, constraints.remainingCacheExtent - cacheExtent),
  );
}
