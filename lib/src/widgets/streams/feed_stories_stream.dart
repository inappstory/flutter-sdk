import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../controllers/feed_stories_controller.dart';
import '../../data/favorite_from_dto.dart';
import '../../data/feed_favorite.dart';
import '../../ias_story_list_host_api_decorator.dart';
import '../../in_app_story_api_list_subscriber_flutter_api_observable.dart';
import '../../observable_error_callback_flutter_api.dart';
import '../../pigeon_generated.g.dart';
import '../base/base_feed_favorites_widget.dart';
import '../decorators/feed_decorator.dart';
import 'stories_stream.dart';

typedef FeedFavoritesWidgetBuilder = FeedFavoritesWidget Function(
    Iterable<FeedFavorite> favorites);

typedef FeedFavoriteWidgetBuilder = Widget Function(FeedFavorite);

abstract class FeedFavoritesWidget implements Widget {
  Iterable<FeedFavorite> get favorites;

  FeedFavoriteWidgetBuilder get feedFavoriteWidgetBuilder;
}

class FeedStoriesStream extends StoriesStream {
  static const _uniqueId = 'feed';

  FeedStoriesStream({
    required super.feed,
    required super.storyWidgetBuilder,
    this.feedDecorator,
    this.feedController,
    this.feedFavoritesWidgetBuilder,
  }) : super(
          uniqueId: _uniqueId,
          observableStoryList:
              InAppStoryAPIListSubscriberFlutterApiObservable(feed),
          observableErrorCallback: ObservableErrorCallbackFlutterApi(),
          iasStoryListHostApi: IASStoryListHostApiDecorator(
              IASStoryListHostApi(messageChannelSuffix: feed)),
          storyDecorator: feedDecorator ?? FeedStoryDecorator(),
        ) {
    feedController
      ?..feed = feed
      ..iasStoryListHostApi = iasStoryListHostApi;
  }

  final FeedFavoritesWidgetBuilder? feedFavoritesWidgetBuilder;

  final FeedStoriesController? feedController;

  final FeedStoryDecorator? feedDecorator;

  Iterable<FavoriteFromDto> favorites = [];

  Iterable<Widget> combineStoriesAndFavorites() {
    final feedFavoritesWidgetBuilder = this.feedFavoritesWidgetBuilder;

    return [
      ...stories.map(createWidgetFromStory),
      if (feedFavoritesWidgetBuilder != null && favorites.isNotEmpty)
        BaseFeedFavoritesWidget(
          favorites.take(4),
          feed,
          iasStoryListHostApi,
          feedFavoritesWidgetBuilder,
          aspectRatio: feedDecorator?.favouriteAspectRatio,
        ),
    ];
  }

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {
    stories = list
        .whereType<StoryAPIDataDto>()
        .map(createStoryFromDto)
        .toList(growable: false);

    controller.add(combineStoriesAndFavorites());
  }

  @override
  void updateStoryData(StoryAPIDataDto storyData) {
    try {
      final story =
          stories.firstWhere((element) => element.dto.id == storyData.id);
      story.updateStoryData(storyData);

      controller.add(combineStoriesAndFavorites());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating story data: $e');
      }
    }
  }

  @override
  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto?> list) {
    favorites = list
        .whereType<StoryFavoriteItemAPIDataDto>()
        .map(FavoriteFromDto.new)
        .toList(growable: false);

    controller.add(combineStoriesAndFavorites());
  }
}
