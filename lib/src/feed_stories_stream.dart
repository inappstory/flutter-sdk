import 'package:flutter/widgets.dart';

import 'base_feed_favorites_widget.dart';
import 'favorite_from_dto.dart';
import 'feed_favorite.dart';
import 'ias_story_list_host_api_decorator.dart';
import 'in_app_story_api_list_subscriber_flutter_api_observable.dart';
import 'observable_error_callback_flutter_api.dart';
import 'pigeon_generated.g.dart';
import 'stories_stream.dart';

typedef FeedFavoritesWidgetBuilder = FeedFavoritesWidget Function(Iterable<FeedFavorite>);

typedef FeedFavoriteWidgetBuilder = Widget Function(FeedFavorite);

abstract class FeedFavoritesWidget implements Widget {
  Iterable<FeedFavorite> get favorites;

  FeedFavoriteWidgetBuilder get feedFavoriteWidgetBuilder;
}

class FeedStoriesStream extends StoriesStream {
  static const _uniqueId = "feed";

  FeedStoriesStream({
    required super.feed,
    required super.storyWidgetBuilder,
    this.feedFavoritesWidgetBuilder,
  }) : super(
          uniqueId: _uniqueId,
          observableStoryList: InAppStoryAPIListSubscriberFlutterApiObservable(_uniqueId),
          observableErrorCallback: ObservableErrorCallbackFlutterApi(),
          iasStoryListHostApi: IASStoryListHostApiDecorator(IASStoryListHostApi(messageChannelSuffix: _uniqueId)),
        );

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
