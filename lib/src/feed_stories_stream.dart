import 'package:flutter/widgets.dart';

import 'base_feed_favorites_widget.dart';
import 'favorite_from_dto.dart';
import 'feed_favorite.dart';
import 'pigeon_generated.g.dart';
import 'stories_stream.dart';

typedef FeedFavoritesWidgetBuilder = FeedFavoritesWidget Function(Iterable<FeedFavorite>);

typedef FeedFavoriteWidgetBuilder = Widget Function(FeedFavorite);

abstract class FeedFavoritesWidget implements Widget {
  Iterable<FeedFavorite> get favorites;

  FeedFavoriteWidgetBuilder get feedFavoriteWidgetBuilder;
}

class FeedStoriesStream extends StoriesStream {
  FeedStoriesStream({
    required super.feed,
    required super.storyWidgetBuilder,
    this.feedFavoritesWidgetBuilder,
  }) : super(uniqueId: "feed");

  final FeedFavoritesWidgetBuilder? feedFavoritesWidgetBuilder;

  Iterable<FavoriteFromDto> favorites = [];

  Iterable<Widget> combineStoriesAndFavorites() {
    final feedFavoritesWidgetBuilder = this.feedFavoritesWidgetBuilder;

    return [
      ...stories.map(createWidgetFromStory),
      if (feedFavoritesWidgetBuilder != null && favorites.isNotEmpty)
        BaseFeedFavoritesWidget(favorites, iasStoryListHostApi, feedFavoritesWidgetBuilder),
    ];
  }

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {
    stories = list.whereType<StoryAPIDataDto>().map(createStoryFromDto).toList(growable: false);

    controller.add(combineStoriesAndFavorites());
  }

  @override
  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto?> list) {
    favorites = list.whereType<StoryFavoriteItemAPIDataDto>().map(FavoriteFromDto.new).toList(growable: false);

    controller.add(combineStoriesAndFavorites());
  }
}
