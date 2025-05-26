import 'package:flutter/widgets.dart';

import '../data/feed_favorite.dart';
import 'decorators/feed_decorator.dart';
import 'base/feed_favorite_widget.dart';
import 'streams/feed_stories_stream.dart';

class FeedFavoritesItemWidget extends StatelessWidget
    implements FeedFavoritesWidget {
  const FeedFavoritesItemWidget(
    this.favorites, {
    this.feedFavoriteWidgetBuilder = FeedFavoriteWidget.new,
    this.decorator,
    super.key,
  });

  final FeedStoryDecorator? decorator;

  @override
  final Iterable<FeedFavorite> favorites;

  @override
  final FeedFavoriteWidgetBuilder feedFavoriteWidgetBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: decorator?.favouriteAspectRatio ?? 1.0,
      ),
      itemBuilder: (_, index) =>
          feedFavoriteWidgetBuilder(favorites.elementAt(index)),
      itemCount: favorites.length,
    );
  }
}
