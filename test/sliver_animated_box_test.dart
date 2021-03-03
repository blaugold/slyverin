import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slyverin/slyverin.dart';

void main() {
  testWidgets('hit testing works', (WidgetTester tester) async {
    var buttonWasClicked = false;
    final scrollController = ScrollController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverAnimatedBox(
              scrollExtent: 2000,
              builder: (context, metrics) {
                return Container(
                  height: 500,
                  color: Colors.orange,
                  child: TextButton(
                    child: Text('Button'),
                    onPressed: () {
                      buttonWasClicked = true;
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ));

    scrollController.jumpTo(1500);
    await tester.pumpAndSettle();

    final buttonFinder = find.text('Button');
    await tester.tap(buttonFinder);

    expect(buttonWasClicked, isTrue);
  });
}
