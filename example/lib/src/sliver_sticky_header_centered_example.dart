import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:slyverin/slyverin.dart';

class SliverStickyHeaderCenteredExample extends StatefulWidget {
  SliverStickyHeaderCenteredExample({Key key}) : super(key: key);

  @override
  _SliverStickyHeaderCenteredExampleState createState() =>
      _SliverStickyHeaderCenteredExampleState();
}

class ImageItem {
  ImageItem({
    @required this.asset,
    @required this.title,
  });

  final String asset;
  final String title;
}

class _SliverStickyHeaderCenteredExampleState
    extends State<SliverStickyHeaderCenteredExample> {
  final _center = GlobalKey();

  final _images = [
    ImageItem(asset: 'images/img_0.jpg', title: 'Paint'),
    ImageItem(asset: 'images/img_1.jpg', title: 'Bubbles'),
    ImageItem(asset: 'images/img_2.jpg', title: 'Forrest'),
    ImageItem(asset: 'images/img_3.jpg', title: 'Church'),
    ImageItem(asset: 'images/img_4.jpg', title: 'Beach'),
    ImageItem(asset: 'images/img_5.jpg', title: 'Cliffs'),
    ImageItem(asset: 'images/img_6.jpg', title: 'Rollerblades'),
  ];

  @override
  Widget build(BuildContext context) {
    final firstHalfImages = _images.sublist(0, _images.length ~/ 2);
    final secondHalfImages = _images.sublist(firstHalfImages.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('SliverStickyHeader: Centered'),
      ),
      body: CustomScrollView(
        center: _center,
        slivers: [
          for (final img in firstHalfImages)
            _buildImageItem(img, reverse: true),
          _buildCenter(),
          for (final img in secondHalfImages) _buildImageItem(img),
        ],
      ),
    );
  }

  SliverStickyHeader _buildImageItem(ImageItem img, {bool reverse = false}) {
    return SliverStickyHeader(
      reverse: reverse,
      overlayHeader: true,
      header: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            color: Colors.white.withOpacity(.4),
            child: Text(
              img.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
      body: SliverToBoxAdapter(
        child: Image.asset(img.asset),
      ),
    );
  }

  SliverToBoxAdapter _buildCenter() {
    return SliverToBoxAdapter(
      key: _center,
      child: Container(
        decoration:
            BoxDecoration(border: Border.symmetric(vertical: BorderSide())),
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('Center'),
        ),
      ),
    );
  }
}
