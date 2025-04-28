import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../data/favorite_from_dto.dart';
import '../../pigeon_generated.g.dart';
import '../streams/feed_stories_stream.dart';

class BaseFeedFavoritesWidget extends StatelessWidget {
  const BaseFeedFavoritesWidget(
    this.favorites,
    this.iasStoryListHostApi,
    this.simpleFavoritesWidgetBuilder, {
    super.key,
  });

  final Iterable<FavoriteFromDto> favorites;
  final IASStoryListHostApi iasStoryListHostApi;
  final FeedFavoritesWidgetBuilder simpleFavoritesWidgetBuilder;

  void onVisibilityChanged(VisibilityInfo info) => iasStoryListHostApi.showFavoriteItem();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const ValueKey('inappstory_feed_favorites'),
      onVisibilityChanged: onVisibilityChanged,
      child: AspectRatio(
        aspectRatio: 1,
        child: simpleFavoritesWidgetBuilder(favorites),
      ),
    );
  }
}
