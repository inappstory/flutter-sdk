import 'package:flutter/widgets.dart';

import '../data/feed_favorite.dart';
import 'feed_favorite_widget.dart';
import 'streams/feed_stories_stream.dart';

class GridFeedFavoritesWidget extends StatelessWidget implements FeedFavoritesWidget {
  GridFeedFavoritesWidget(
    this.favorites, {
    this.feedFavoriteWidgetBuilder = FeedFavoriteWidget.new,
    super.key,
  });

  @override
  final Iterable<FeedFavorite> favorites;

  @override
  final FeedFavoriteWidgetBuilder feedFavoriteWidgetBuilder;

  late final gridDelegate = effectiveSliverGridDelegate(favorites);

  SliverGridDelegate effectiveSliverGridDelegate(Iterable<FeedFavorite> favorites) {
    final crossAxisCount = switch (favorites.length) {
      >= 9 => 3,
      _ => 2,
    };

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate,
      itemBuilder: (_, index) => feedFavoriteWidgetBuilder(favorites.elementAt(index)),
      itemCount: favorites.length,
    );
  }
}
