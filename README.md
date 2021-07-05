[![pub.dev](https://badgen.net/pub/v/slyverin)](https://pub.dev/packages/slyverin)
[![LICENSE](https://badgen.net/pub/license/slyverin)](./LICENSE)

# slyverin

A library of Flutter sliver implementations.

[Live Demo](https://blaugold.github.io/slyverin/example_dist/index.html)

## `SliverStickyHeader`

<p align="center">
    <img width="400" src="./docs/sliver_sticky_header_centered.gif">
</p>

This sliver accepts two widgets: a header and a body. The header stays pinned to the top of the viewport, until the bottom edge of the overall sliver scrolls out.

The sliver allows you to reverse the normal order so that the header is at the bottom. This has a useful application when using a scroll view which is centered, since from the view of a sliver everything reverses above the center. For this sliver implementation this means that without the `reverse` option set to `true`, slivers above the center have their header at the bottom.

To implement a list which is infinite and centered, slivers above the center have to reverse their layout. Why would you need a list like that? A good example is a list, which is able to lazily load new content from both sides of the center. Without centering the scroll view, adding new content at the top suddenly shifts everything down, making the list hard to use, especially when content is added while scrolling.

[Example](example/lib/src/sliver_sticky_header_centered_example.dart)

## `SliverAnimatedBox`

A sliver which pins its child to the start of the viewport and animates it over the duration of the `scrollExtent`.

The `scrollExtent` is the total amount a user has to scroll to move the sliver off the viewport. On the screen the sliver only occupies the extent of the widget built by `builder`, which has to derive ist visual representation from a RenderBox. The `builder` can use the `SliverAnimatedBoxMetrics` it is given to animate the returned Widget tree.

[Example](example/lib/src/sliver_animated_box_example.dart)

## License

The project is licensed under the MIT License.
