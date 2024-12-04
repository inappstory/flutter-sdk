import 'dart:async';

import 'package:flutter/widgets.dart';

import 'base_feed_favorites_widget.dart';
import 'base_story_widget.dart';
import 'favorite_from_dto.dart';
import 'feed_favorite.dart';
import 'ias_story_list_host_api_decorator.dart';
import 'in_app_story_api_list_subscriber_flutter_api_observable.dart';
import 'pigeon_generated.g.dart';
import 'story_from_pigeon_dto.dart';

typedef FeedFavoritesWidgetBuilder = FeedFavoritesWidget Function(Iterable<FeedFavorite>);

typedef FeedFavoriteWidgetBuilder = Widget Function(FeedFavorite);

abstract class FeedFavoritesWidget implements Widget {
  Iterable<FeedFavorite> get favorites;

  FeedFavoriteWidgetBuilder get feedFavoriteWidgetBuilder;
}

class FeedStoriesStream extends Stream<Iterable<Widget>>
    implements InAppStoryAPIListSubscriberFlutterApi, ErrorCallbackFlutterApi {
  FeedStoriesStream(
    this.feed,
    this.uniqueId,
    this.storyWidgetBuilder,
    this.feedFavoritesWidgetBuilder,
  );

  final String uniqueId;
  final String feed;
  late final observableStoryList = InAppStoryAPIListSubscriberFlutterApiObservable(uniqueId);
  final StoryWidgetBuilder storyWidgetBuilder;
  final FeedFavoritesWidgetBuilder? feedFavoritesWidgetBuilder;
  late final IASStoryListHostApi iasStoryListHostApi =
      IASStoryListHostApiDecorator(IASStoryListHostApi(messageChannelSuffix: uniqueId));

  Iterable<StoryFromPigeonDto> stories = [];
  Iterable<FavoriteFromDto> favorites = [];

  Iterable<Widget> combineStoriesAndFavorites() {
    final feedFavoritesWidgetBuilder = this.feedFavoritesWidgetBuilder;

    return [
      ...stories.map(createWidgetFromStory),
      if (feedFavoritesWidgetBuilder != null && favorites.isNotEmpty)
        BaseFeedFavoritesWidget(favorites, iasStoryListHostApi, feedFavoritesWidgetBuilder),
    ];
  }

  late final controller = StreamController<Iterable<Widget>>(
    onListen: onListen,
    onCancel: onCancel,
  );

  void onListen() {
    observableStoryList.addObserver(this);
    ErrorCallbackFlutterApi.setUp(this);
    iasStoryListHostApi.load(feed);
  }

  void onCancel() {
    observableStoryList.removeObserver(this);
    ErrorCallbackFlutterApi.setUp(null);
  }

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {
    stories = list.whereType<StoryAPIDataDto>().map(createStoryFromDto).toList(growable: false);

    controller.add(combineStoriesAndFavorites());
  }

  StoryFromPigeonDto createStoryFromDto(StoryAPIDataDto dto) {
    return StoryFromPigeonDto(dto, iasStoryListHostApi, observableStoryList);
  }

  BaseStoryWidget createWidgetFromStory(StoryFromPigeonDto story) {
    return BaseStoryWidget(
      story,
      storyWidgetBuilder,
      key: ValueKey(story.hashCode),
    );
  }

  @override
  void loadListError(String feed) {
    if (feed != this.feed) return;
    controller.addError(Exception('loadListError feed: $feed'));
  }

  @override
  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto?> list) {
    favorites = list.whereType<StoryFavoriteItemAPIDataDto>().map(FavoriteFromDto.new).toList(growable: false);

    controller.add(combineStoriesAndFavorites());
  }

  @override
  StreamSubscription<Iterable<Widget>> listen(
    void Function(Iterable<Widget> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  void updateStoryData(StoryAPIDataDto var1) {}

  @override
  void cacheError() {}

  @override
  void emptyLinkError() {}

  @override
  void loadOnboardingError(String feed) {}

  @override
  void loadSingleError() {}

  @override
  void noConnection() {}

  @override
  void readerError() {}

  @override
  void sessionError() {}
}
