# slyverin

A library of flutter sliver implementations.

## `SliverStickyHeader`

<details>
    <summary>Demo video</summary>

![Video of example for SliverStickyHeader](./docs/sliver_sticky_header_centered.gif)
</details>

This slivers accepts two widgets: a header and a body. The header stays pinned to the top of
the viewport, until the bottom edge of the overall sliver scrolls out.

The sliver allows you to reverse the normal order so that the header is a the bottom. In it self
this can be an interesting usage of the widget. There is a a more interesting use for this feature 
though. Slivers can be a bit tricky when using a scroll view which is centered, since from the view
of a sliver everything reverses above the center. For this sliver implementation this means
that without the `reverse` option set to `true`, slivers above the center have their header at the
bottom. To implement a list which is infinite, centered and continuous in how slivers a laid out,
slivers above the center have to reverse their layout. Why would you need a list like that? A good
example is a list, which is able to lazily load new content from both sides. Without centering the
scroll view, adding new content at the top suddenly shifts everything down, make the list hard
to use, especially when content is added while scrolling. See 
[this example](./example/lib/src/sliver_sticky_header_centered_example.dart) for a list, making use
of this feature.

## License

The project is licensed under the MIT License.
