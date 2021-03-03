import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class ImageAsset {
  ImageAsset({
    required this.asset,
    required this.title,
  });

  final String asset;
  final String title;
  ui.Image? image;

  Future<void> _load() async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(Uint8List.view(data.buffer));
    final frame = await codec.getNextFrame();
    image = frame.image;
  }
}

Future<void>? _loadImagesFuture;

final _images = [
  ImageAsset(asset: 'images/img_0.jpg', title: 'Paint'),
  ImageAsset(asset: 'images/img_1.jpg', title: 'Bubbles'),
  ImageAsset(asset: 'images/img_2.jpg', title: 'Forrest'),
  ImageAsset(asset: 'images/img_3.jpg', title: 'Church'),
  ImageAsset(asset: 'images/img_4.jpg', title: 'Beach'),
  ImageAsset(asset: 'images/img_5.jpg', title: 'Cliffs'),
  ImageAsset(asset: 'images/img_6.jpg', title: 'Rollerblades'),
];

Future<List<ImageAsset>> loadImages() async {
  if (_loadImagesFuture == null) {
    _loadImagesFuture = Future.wait(_images.map((e) => e._load()));
  }

  await _loadImagesFuture;

  return _images;
}
