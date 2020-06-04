import 'dart:math';

import 'package:example/src/curves.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slyverin/slyverin.dart';

import 'fixtures.dart';

class SliverAnimatedBoxExample extends StatefulWidget {
  @override
  _SliverAnimatedBoxExampleState createState() =>
      _SliverAnimatedBoxExampleState();
}

class _SliverAnimatedBoxExampleState extends State<SliverAnimatedBoxExample> {
  var _clicks = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ImageAsset>>(
      future: loadImages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        return Scaffold(
          appBar: AppBar(
            title: Text('SliverAnimatedBox'),
          ),
          body: Scrollbar(
            child: CustomScrollView(
              slivers: [
                _buildSpacer(),
                _buildClockSliver(),
                _buildSpacer(),
                _buildCounterSliver(),
                _buildSpacer(),
                _buildPhotoSlideSliver(snapshot.data),
                _buildSpacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpacer({int tickDistance = 100, int height = 1000}) {
    final ticks = height ~/ tickDistance;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tickStart = tickDistance * index;
          return Container(
            height: min(tickDistance, height - tickStart).toDouble(),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 0,
                  color: Colors.black38,
                ),
              ),
            ),
            padding: EdgeInsets.all(4),
            child: Text(
              tickStart.toString(),
              style: TextStyle(fontSize: 10),
            ),
          );
        },
        childCount: ticks,
      ),
    );
  }

  Widget _buildClockSliver() {
    return SliverAnimatedBox(
      scrollExtent: 10000,
      builder: (context, metrics) {
        return Builder(
          builder: (context) {
            final milliSeconds =
                ((24 * 60 * 60 * 1000 - 1) * metrics.animationProgress).toInt();

            final date =
                DateTime.fromMillisecondsSinceEpoch(milliSeconds).toUtc();
            final hour = date.hour.toString().padLeft(2, '0');
            final minutes = date.minute.toString().padLeft(2, '0');
            final second = date.second.toString().padLeft(2, '0');

            return Container(
              height: metrics.viewportExtent,
              color: HSLColor.fromAHSL(
                1,
                metrics.animationProgress * 360,
                .5,
                .5,
              ).toColor(),
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(
                  '$hour:$minutes:$second',
                  style: GoogleFonts.robotoMono(
                    fontSize: 54,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCounterSliver() {
    return SliverAnimatedBox(
      scrollExtent: 3000,
      builder: (context, metrics) {
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            Container(
              height: 300,
              color: Colors.indigo,
              alignment: Alignment.center,
              child: FlatButton(
                child: Text(
                  'Clicks: $_clicks',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    _clicks += 1;
                  });
                },
              ),
            ),
            FractionallySizedBox(
              widthFactor: metrics.animationProgress,
              child: Container(
                height: 4,
                color: Colors.orange,
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildPhotoSlideSliver(List<ImageAsset> images) {
    return SliverAnimatedBox(
      scrollExtent: 5000,
      builder: (context, metrics) {
        final height = 500.0;
        return Container(
          height: height,
          child: AnimatedViewport(
            axisDirection: AxisDirection.right,
            animationProgress: metrics.animationProgress,
            curve: PreciseCubic.fromCubic(Curves.easeInOut),
            cacheExtent: 500,
            slivers: images.map((imageAsset) {
              final image = imageAsset.image;
              return SliverToBoxAdapter(
                child: Container(
                  height: height,
                  width: height * (image.width / image.height),
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 15,
                  ),
                  child: Card(
                    elevation: 6,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RawImage(
                      image: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class AnimatedViewport extends StatefulWidget {
  final List<Widget> slivers;
  final double animationProgress;
  final AxisDirection axisDirection;
  final Curve curve;
  final double cacheExtent;

  const AnimatedViewport({
    Key key,
    this.slivers,
    this.animationProgress,
    this.axisDirection,
    this.curve = Curves.linear,
    this.cacheExtent,
  })  : assert(curve != null),
        super(key: key);

  @override
  _AnimatedViewportState createState() => _AnimatedViewportState();
}

class _AnimatedViewportState extends State<AnimatedViewport> {
  final _offset = _AnimatedViewportOffset();

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    _offset.animationProgress = widget.animationProgress;
    _offset.curve = widget.curve;
  }

  @override
  Widget build(BuildContext context) {
    return Viewport(
      offset: _offset,
      axisDirection: widget.axisDirection,
      slivers: widget.slivers,
      cacheExtent: widget.cacheExtent,
    );
  }
}

class _AnimatedViewportOffset extends ViewportOffset {
  @override
  ScrollDirection get userScrollDirection => ScrollDirection.forward;

  @override
  bool get allowImplicitScrolling => false;

  @override
  double get pixels => _pixels;
  double _pixels = 0;

  void _updatePixels() {
    _pixels = curve.transform(_animationProgress) * _maxScrollExtent;
  }

  Curve _curve = Curves.linear;

  Curve get curve => _curve;

  void set curve(Curve curve) {
    assert(curve != null);
    _curve = curve;
  }

  double _maxScrollExtent = 0;

  double _animationProgress = 0;

  double get animationProgress {
    return _animationProgress;
  }

  set animationProgress(double animationProgress) {
    assert(animationProgress >= 0);
    assert(animationProgress <= 1);

    if (_animationProgress != animationProgress) {
      _animationProgress = animationProgress;
      _updatePixels();
      notifyListeners();
    }
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    if (_maxScrollExtent != maxScrollExtent) {
      _maxScrollExtent = maxScrollExtent;
      _updatePixels();
      return false;
    }

    return true;
  }

  @override
  bool applyViewportDimension(double viewportDimension) => true;

  @override
  void correctBy(double correction) {
    _pixels += correction;
  }

  @override
  Future<void> animateTo(double to, {Duration duration, Curve curve}) {
    throw UnimplementedError();
  }

  @override
  void jumpTo(double pixels) {
    throw UnimplementedError();
  }
}
