import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// This is an adaption of [ConstrainedLayoutBuilder], which removes the
/// requirement that a constraints is passed to [builder]. Instead an argument
/// of an arbitrary type [BuilderData] is passed.
abstract class BuilderDataLayoutBuilder<BuilderData>
    extends RenderObjectWidget {
  /// Creates a widget that defers its building until layout.
  ///
  /// The [builder] argument must not be null, and the returned widget should not
  /// be null.
  const BuilderDataLayoutBuilder({
    Key key,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  _LayoutBuilderElement<BuilderData> createElement() =>
      _LayoutBuilderElement<BuilderData>(this);

  /// Called at layout time to construct the widget tree.
  ///
  /// The builder must not return null.
  final Widget Function(BuildContext, BuilderData) builder;

// updateRenderObject is redundant with the logic in the LayoutBuilderElement below.
}

class _LayoutBuilderElement<BuilderData> extends RenderObjectElement {
  _LayoutBuilderElement(BuilderDataLayoutBuilder<BuilderData> widget)
      : super(widget);

  @override
  BuilderDataLayoutBuilder<BuilderData> get widget =>
      super.widget as BuilderDataLayoutBuilder<BuilderData>;

  @override
  RenderBuilderDataLayoutBuilder<BuilderData, RenderObject> get renderObject =>
      super.renderObject
          as RenderBuilderDataLayoutBuilder<BuilderData, RenderObject>;

  Element _child;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) visitor(_child);
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
    super.forgetChild(child);
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot); // Creates the renderObject.
    renderObject.updateCallback(_layout);
  }

  @override
  void update(BuilderDataLayoutBuilder<BuilderData> newWidget) {
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);

    renderObject.updateCallback(_layout);
    // Force the callback to be called, even if the builder data is the
    // same, because the logic in the callback might have changed.
    renderObject.markNeedsBuild();
  }

  @override
  void performRebuild() {
    // This gets called if markNeedsBuild() is called on us.
    // That might happen if, e.g., our builder uses Inherited widgets.

    // Force the callback to be called, even if the builder data is the
    // same. This is because that callback may depend on the updated widget
    // configuration, or an inherited widget.
    renderObject.markNeedsBuild();
    // Calls widget.updateRenderObject (a no-op in this case).
    super.performRebuild();
  }

  @override
  void unmount() {
    renderObject.updateCallback(null);
    super.unmount();
  }

  void _layout(BuilderData builderData) {
    owner.buildScope(this, () {
      Widget built;
      if (widget.builder != null) {
        try {
          built = widget.builder(this, builderData);
          debugWidgetBuilderValue(widget, built);
        } catch (e, stack) {
          built = ErrorWidget.builder(
            _debugReportException(
              ErrorDescription('building $widget'),
              e,
              stack,
              informationCollector: () sync* {
                yield DiagnosticsDebugCreator(DebugCreator(this));
              },
            ),
          );
        }
      }
      try {
        _child = updateChild(_child, built, null);
        assert(_child != null);
      } catch (e, stack) {
        built = ErrorWidget.builder(
          _debugReportException(
            ErrorDescription('building $widget'),
            e,
            stack,
            informationCollector: () sync* {
              yield DiagnosticsDebugCreator(DebugCreator(this));
            },
          ),
        );
        _child = updateChild(null, built, slot);
      }
    });
  }

  @override
  void insertChildRenderObject(RenderObject child, dynamic slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        this.renderObject;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveChildRenderObject(RenderObject child, dynamic slot) {
    assert(false);
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    final RenderBuilderDataLayoutBuilder<BuilderData, RenderObject>
        renderObject = this.renderObject;
    assert(renderObject.child == child);
    renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}

typedef void BuilderDataLayoutCallback<BuilderData>(BuilderData builderData);

/// Generic mixin for [RenderObject]s created by [BuilderDataLayoutBuilder].
///
/// Provides a callback that should be called at layout time, typically in
/// [RenderObject.performLayout].
mixin RenderBuilderDataLayoutBuilder<BuilderData,
    ChildType extends RenderObject> on RenderObjectWithChildMixin<ChildType> {
  /// The data to pass to [BuilderDataLayoutBuilder.builder]. This needs to
  /// be updated before calls to [rebuildIfNecessary].
  BuilderData builderData;

  BuilderDataLayoutCallback<BuilderData> _callback;

  /// Change the layout callback.
  void updateCallback(BuilderDataLayoutCallback<BuilderData> value) {
    if (value == _callback) return;
    _callback = value;
    markNeedsLayout();
  }

  bool _needsBuild = true;

  /// Marks this layout builder as needing to rebuild.
  ///
  /// The layout builder rebuilds automatically when builder data change.
  /// However, we must also rebuild when the widget updates, e.g. after
  /// [State.setState], or [State.didChangeDependencies], even when the layout
  /// constraints remain unchanged.
  ///
  /// See also:
  ///
  ///  * [BuilderDataLayoutBuilder.builder], which is called during the rebuild.
  void markNeedsBuild() {
    // Do not call the callback directly. It must be called during the layout
    // phase, when parent constraints are available. Calling `markNeedsLayout`
    // will cause it to be called at the right time.
    _needsBuild = true;
    markNeedsLayout();
  }

  // The builder data that was passed to this class last time it was laid out.
  // These constraints are compared to the new builder data to determine whether
  // [ConstrainedLayoutBuilder.builder] needs to be called.
  BuilderData _previousBuilderData;

  /// Invoke the callback supplied via [updateCallback].
  ///
  /// Typically this results in [BuilderDataLayoutBuilder.builder] being called
  /// during layout.
  void rebuildIfNecessary() {
    assert(_callback != null);
    if (_needsBuild || builderData != _previousBuilderData) {
      _previousBuilderData = builderData;
      _needsBuild = false;
      invokeLayoutCallback((dynamic _) {
        _callback(builderData);
      });
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('builderData', builderData.toString()));
  }
}

FlutterErrorDetails _debugReportException(
  DiagnosticsNode context,
  dynamic exception,
  StackTrace stack, {
  InformationCollector informationCollector,
}) {
  final FlutterErrorDetails details = FlutterErrorDetails(
    exception: exception,
    stack: stack,
    library: 'widgets library',
    context: context,
    informationCollector: informationCollector,
  );
  FlutterError.reportError(details);
  return details;
}
