import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../data/favorite_from_dto.dart';
import '../../pigeon_generated.g.dart';
import '../streams/feed_stories_stream.dart';

class BaseFeedFavoritesWidget extends StatelessWidget {
  const BaseFeedFavoritesWidget(
    this.favorites,
    this.feed,
    this.iasStoryListHostApi,
    this.favoritesWidgetBuilder, {
    super.key,
    this.aspectRatio,
  });

  final double? aspectRatio;
  final String feed;

  final Iterable<FavoriteFromDto> favorites;
  final IASStoryListHostApi iasStoryListHostApi;
  final FeedFavoritesWidgetBuilder favoritesWidgetBuilder;

  void onVisibilityChanged(VisibilityInfo info) =>
      iasStoryListHostApi.showFavoriteItem(feed);

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey('inappstory_feed_favorites'),
      onVisibilityChanged: onVisibilityChanged,
      child: AspectRatio(
        aspectRatio: aspectRatio ?? 1.0,
        child: favoritesWidgetBuilder(favorites),
      ),
    );
  }
}
