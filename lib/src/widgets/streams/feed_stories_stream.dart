import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../../inappstory_plugin.dart';
import '../../data/favorite_from_dto.dart';
import '../../data/feed_favorite.dart';
import '../../data/story_from_pigeon_dto.dart';
import '../../ias_story_list_host_api_decorator.dart';
import '../../in_app_story_api_list_subscriber_flutter_api_observable.dart';
import '../../observable_error_callback_flutter_api.dart';
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
    this.onStoriesLoaded,
    this.onScrollToStory,
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

  final Function(int size, String feed)? onStoriesLoaded;

  Iterable<FavoriteFromDto> favorites = [];

  final Function(int index, StoryFromPigeonDto story)? onScrollToStory;

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
        print('InAppStory: Error updating story data: $e');
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

  @override
  void storiesLoaded(int size, String feed) =>
      onStoriesLoaded?.call(size, feed);

  @override
  void scrollToStory(int id) {
    try {
      final story = stories.firstWhere(
        (element) => element.id == id,
      );
      int index = stories.indexWhere((element) => element.id == id);
      if (index == -1) {
        return;
      }
      onScrollToStory?.call(index, story);
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
