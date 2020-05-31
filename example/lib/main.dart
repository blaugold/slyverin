import 'package:flutter/material.dart';

import 'src/sliver_animated_box_example.dart';
import 'src/sliver_sticky_header_centered_example.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

typedef void OnOpenExample(BuildContext context);

class Example {
  final String title;
  final OnOpenExample onOpen;

  Example({
    this.title,
    this.onOpen,
  });
}

final examples = [
  Example(
    title: 'SliverStickyHeader: Centered',
    onOpen: (context) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => SliverStickyHeaderCenteredExample(),
      ));
    },
  ),
  Example(
    title: 'SliverAnimatedBox',
    onOpen: (context) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => SliverAnimatedBoxExample(),
      ));
    },
  ),
];

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slyverin Examples'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: examples
              .map((e) => Container(
                    padding: EdgeInsets.all(16),
                    child: RaisedButton(
                      child: Text(e.title),
                      onPressed: () {
                        e.onOpen(context);
                      },
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
