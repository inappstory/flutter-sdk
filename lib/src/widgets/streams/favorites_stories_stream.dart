import 'dart:developer';

import '../../controllers/feed_stories_controller.dart';
import '../../data/story_from_pigeon_dto.dart';
import '../../generated/pigeon_generated.g.dart'
    show IASStoryListHostApi, StoryAPIDataDto, StoryFavoriteItemAPIDataDto;
import '../../ias_story_list_host_api_decorator.dart';
import '../../in_app_story_api_list_subscriber_flutter_api_observable.dart';
import '../../observable_error_callback_flutter_api.dart';
import '../decorators/feed_decorator.dart';
import 'stories_stream.dart';

class FavoritesStoriesStream extends StoriesStream {
  static const _uniqueId = 'favorites';

  FavoritesStoriesStream({
    required super.feed,
    required super.storyWidgetBuilder,
    this.feedDecorator,
    this.feedController,
    this.onStoriesLoaded,
  }) : super(
          uniqueId: _uniqueId,
          observableStoryList:
              InAppStoryAPIListSubscriberFlutterApiObservable(_uniqueId),
          observableErrorCallback: ObservableErrorCallbackFlutterApi(),
          iasStoryListHostApi: IASStoryListHostApiDecorator(
              IASStoryListHostApi(messageChannelSuffix: _uniqueId)),
          storyDecorator: feedDecorator ?? FeedStoryDecorator(),
        ) {
    feedController
      ?..feed = _uniqueId
      ..iasStoryListHostApi = iasStoryListHostApi;
  }

  final FeedStoriesController? feedController;

  final FeedStoryDecorator? feedDecorator;

  final Function(int size, String feed)? onStoriesLoaded;

  final tempStories = <StoryFromPigeonDto>[];

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {
    stories = list
        .whereType<StoryAPIDataDto>()
        .map(createStoryFromDto)
        .toList(growable: false);

    tempStories.clear();
    tempStories.addAll(stories);
    controller.add(stories.map(createWidgetFromStory).toList());
  }

  @override
  void updateStoryData(StoryAPIDataDto storyData) {
    try {
      final story = stories
          .where((element) => element.dto.id == storyData.id)
          .firstOrNull;
      story?.updateStoryData(storyData);
    } catch (e) {
      log('[InAppStory]: Error updating story data: $e');
    }
  }

  @override
  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto?> list) {
    if (list.isEmpty) {
      stories = <StoryFromPigeonDto>[];
      controller.add(stories.map(createWidgetFromStory).toList());
      return;
    }
    final newList = <StoryFromPigeonDto>[];
    for (final favorite in list) {
      var item = stories
          .where((element) => element.dto.id == favorite!.id)
          .firstOrNull;
      if (item != null) {
        newList.add(item);
        continue;
      }
      item = tempStories
          .where((element) => element.dto.id == favorite!.id)
          .firstOrNull;
      if (item != null) {
        newList.add(item);
      }
    }
    stories = <StoryFromPigeonDto>[];
    stories.addAll(newList);
    controller.add(stories.map(createWidgetFromStory).toList());
  }

  @override
  void onListen() async {
    observableStoryList.addObserver(this);
    observableErrorCallback.addObserver(this);
    iasStoryListHostApi.load(feed, uniqueId);
  }

  @override
  void onCancel() async {
    //iasStoryListHostApi.removeSubscriber(feed);
    observableStoryList.removeObserver(this);
    observableErrorCallback.removeObserver(this);
  }

  @override
  void storiesLoaded(int size, String feed) =>
      onStoriesLoaded?.call(size, feed);

  @override
  void scrollToStory(int index, String feed, String uniqueId) {
    // TODO: implement scrollToStory
  }
}
