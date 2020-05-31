import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'builder_data_layout_builder.dart';
import 'render_sliver.dart';

/// A Widget builder which is called every time the scroll position of the
/// sliver it was given to, changes.
typedef Widget SliverAnimatedBoxWidgetBuilder(
  BuildContext context,
  SliverAnimatedBoxMetrics metrics,
);

/// Metrics for a [SliverAnimatedBoxWidgetBuilder] which allow it to animate its
/// Widgets when the scroll position changes.
class SliverAnimatedBoxMetrics {
  /// Creates the metrics for a [SliverAnimatedBoxWidgetBuilder].
  SliverAnimatedBoxMetrics({
    @required this.scrollExtent,
    @required this.scrollOffset,
    @required this.viewportExtent,
    this.previousBoxExtent,
  })  : assert(scrollExtent > 0),
        assert(scrollOffset >= 0),
        assert(viewportExtent >= 0),
        assert(previousBoxExtent == null || previousBoxExtent >= 0),
        assert(previousBoxExtent == null || previousBoxExtent <= scrollExtent);

  /// The amount of scrolling the user has to do to completely scroll the
  /// animated box of the viewport.
  final double scrollExtent;

  /// The size of the viewport in the scroll direction.
  final double viewportExtent;

  /// The progress the user has made to scroll the animated box off the
  /// viewport, in terms of [scrollExtent].
  final double scrollOffset;

  /// The extent of the animated box during the last layout, in the scrolling
  /// axis.
  ///
  /// Is `null` during the first layout.
  final double previousBoxExtent;

  /// The percentage of scrolling the user has done to complete the animation.
  ///
  /// This assumes that the animation should start when the animated box
  /// reaches the top of the viewport and complete just before the animated
  /// box starts to scroll off the viewport.
  ///
  /// This value is inaccurate if the Widget returned by
  /// [SliverAnimatedBox.builder] changes its extent in the scroll axis, in
  /// response to scrolling.
  double get animationProgress => previousBoxExtent == null
      ? 0
      : min(1, scrollOffset / (scrollExtent - previousBoxExtent));

  /// The percentage of scrolling the user has done to scroll the animated box
  /// off the viewport.
  double get scrollProgress => min(scrollOffset, scrollExtent) / scrollExtent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SliverAnimatedBoxMetrics &&
          runtimeType == other.runtimeType &&
          scrollExtent == other.scrollExtent &&
          scrollOffset == other.scrollOffset &&
          previousBoxExtent == other.previousBoxExtent;

  @override
  int get hashCode =>
      scrollExtent.hashCode ^
      scrollOffset.hashCode ^
      previousBoxExtent.hashCode;

  @override
  String toString() {
    return 'SliverAnimatedBoxBuilderData('
        'animationProgress: $animationProgress, '
        'scrollProgress: $scrollProgress, '
        'scrollExtent: $scrollExtent, '
        'scrollOffset: $scrollOffset, '
        'previousBoxExtent: $previousBoxExtent'
        ')';
  }
}

/// A sliver which pins its child to the start of the viewport and animates it
/// over the duration of the [scrollExtent].
///
/// The [scrollExtent] is total amount a user has to scroll, to move the
/// sliver off the viewport. On the screen the the sliver only occupies the
/// extent of the widget built by [builder], which has to derive ist visual
/// representation from a RenderBox. The [builder] can use the
/// [SliverAnimatedBoxMetrics] it is given, to animate the returned Widget tree.
class SliverAnimatedBox
    extends BuilderDataLayoutBuilder<SliverAnimatedBoxMetrics> {
  const SliverAnimatedBox({
    Key key,
    @required this.scrollExtent,
    @required SliverAnimatedBoxWidgetBuilder builder,
  })  : assert(builder != null),
        super(key: key, builder: builder);

  /// The scroll extent this sliver occupies along the scroll axis. A higher
  /// number means the user has to scroll longer before the animation is
  /// complete and the sliver scrolls off.
  final double scrollExtent;

  @override
  SliverAnimatedBoxWidgetBuilder get builder => super.builder;

  @override
  RenderSliverAnimatedBox createRenderObject(BuildContext context) {
    return RenderSliverAnimatedBox(
      scrollExtent: scrollExtent,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverAnimatedBox renderObject) {
    renderObject..scrollExtent = scrollExtent;
  }
}

class RenderSliverAnimatedBox extends RenderSliverSingleBoxAdapter
    with
        RenderBuilderDataLayoutBuilder<SliverAnimatedBoxMetrics, RenderBox>,
        RenderSliverChildrenWithPaintOffset {
  RenderSliverAnimatedBox({
    @required double scrollExtent,
  }) : _scrollExtent = scrollExtent;

  double _scrollExtent;

  double get scrollExtent {
    return _scrollExtent;
  }

  set scrollExtent(double scrollExtent) {
    if (_scrollExtent != scrollExtent) {
      _scrollExtent = scrollExtent;
      markNeedsLayout();
    }
  }

  double _boxExtent;
  double _freeScrollExtent;

  @override
  void performLayout() {
    _updateBuilderData();
    rebuildIfNecessary();
    _layoutChild();

    final from = min(scrollExtent, constraints.scrollOffset);
    final to = min(scrollExtent, constraints.scrollOffset + _boxExtent);
    final paintExtent = calculatePaintOffset(
      constraints,
      from: from,
      to: to,
    );
    final cacheExtent = calculateCacheOffset(
      constraints,
      from: from,
      to: to,
    );

    _freeScrollExtent = scrollExtent - _boxExtent;

    final trailingScrollExtent =
        max(0, _freeScrollExtent - constraints.scrollOffset);

    geometry = SliverGeometry(
      scrollExtent: scrollExtent,
      paintExtent: paintExtent,
      maxPaintExtent: _boxExtent,
      cacheExtent: cacheExtent,
      hasVisualOverflow: _boxExtent > constraints.remainingPaintExtent ||
          trailingScrollExtent == 0.0,
    );

    setChildParentData(child, constraints, geometry);
  }

  @override
  double childMainAxisPosition(RenderObject child) {
    return min(0, _freeScrollExtent - constraints.scrollOffset);
  }

  @override
  double childPaintExtent(RenderObject child) {
    return _boxExtent;
  }

  @override
  double childScrollOffset(RenderObject child) {
    return min(constraints.scrollOffset, _freeScrollExtent);
  }

  void _updateBuilderData() {
    builderData = SliverAnimatedBoxMetrics(
      viewportExtent: constraints.viewportMainAxisExtent,
      scrollExtent: scrollExtent,
      scrollOffset: constraints.scrollOffset,
      previousBoxExtent: _boxExtent,
    );
  }

  void _layoutChild() {
    child.layout(
      constraints.asBoxConstraints(maxExtent: scrollExtent),
      parentUsesSize: true,
    );
    _updateChildExtent();
  }

  void _updateChildExtent() {
    switch (constraints.axis) {
      case Axis.horizontal:
        _boxExtent = child.size.width;
        break;
      case Axis.vertical:
        _boxExtent = child.size.height;
        break;
    }
  }
}
