import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slyverin/slyverin.dart';

class SliverAnimatedBoxExample extends StatefulWidget {
  @override
  _SliverAnimatedBoxExampleState createState() =>
      _SliverAnimatedBoxExampleState();
}

class _SliverAnimatedBoxExampleState extends State<SliverAnimatedBoxExample> {
  var _clicks = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SliverAnimatedBox'),
      ),
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: 2000,
                color: Colors.green,
              ),
            ),
            _buildAnimatedBox(),
            SliverAnimatedBox(
              scrollExtent: 2000,
              builder: (context, metrics) {
                return Container(
                  height: 500,
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
                );
              },
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 2000,
                color: Colors.orange,
              ),
            )
          ],
        ),
      ),
    );
  }

  SliverAnimatedBox _buildAnimatedBox() {
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
}
