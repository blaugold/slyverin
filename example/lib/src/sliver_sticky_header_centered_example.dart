import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:slyverin/slyverin.dart';

import 'fixtures.dart';

class SliverStickyHeaderCenteredExample extends StatefulWidget {
  SliverStickyHeaderCenteredExample({Key? key}) : super(key: key);

  @override
  _SliverStickyHeaderCenteredExampleState createState() =>
      _SliverStickyHeaderCenteredExampleState();
}

class _SliverStickyHeaderCenteredExampleState
    extends State<SliverStickyHeaderCenteredExample> {
  final _center = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ImageAsset>>(
      future: loadImages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final images = snapshot.data!;
        final firstHalfImages = images.sublist(0, images.length ~/ 2);
        final secondHalfImages = images.sublist(firstHalfImages.length);

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
      },
    );
  }

  SliverStickyHeader _buildImageItem(ImageAsset img, {bool reverse = false}) {
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
        child: RawImage(
          image: img.image,
          fit: BoxFit.cover,
        ),
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
