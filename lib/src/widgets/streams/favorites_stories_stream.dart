import '../../../inappstory_plugin.dart';
import '../../controllers/feed_stories_controller.dart';
import '../../ias_story_list_host_api_decorator.dart';
import '../../in_app_story_api_list_subscriber_flutter_api_observable.dart';
import '../../observable_error_callback_flutter_api.dart';
import 'stories_stream.dart';

class FavoritesStoriesStream extends StoriesStream {
  static const _uniqueId = 'favorites';

  FavoritesStoriesStream({
    required super.feed,
    required super.storyWidgetBuilder,
    this.feedDecorator,
    this.feedController,
  }) : super(
          uniqueId: _uniqueId,
          observableStoryList: InAppStoryAPIListSubscriberFlutterApiObservable(_uniqueId),
          observableErrorCallback: ObservableErrorCallbackFlutterApi(),
          iasStoryListHostApi: IASStoryListHostApiDecorator(IASStoryListHostApi(messageChannelSuffix: _uniqueId)),
          storyDecorator: feedDecorator ?? FeedStoryDecorator(),
        ) {
    feedController
      ?..feed = feed
      ..iasStoryListHostApi = iasStoryListHostApi;
  }

  final FeedStoriesController? feedController;

  final FeedStoryDecorator? feedDecorator;

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {
    stories = list.whereType<StoryAPIDataDto>().map(createStoryFromDto).toList(growable: false);

    controller.add(stories.map(createWidgetFromStory).toList());
  }

  @override
  void updateStoryData(StoryAPIDataDto storyData) {
    try {
      final story = stories.firstWhere((element) => element.dto.id == storyData.id);
      story.updateStoryData(storyData);

      controller.add(stories.map(createWidgetFromStory).toList());
    } catch (e) {}
  }
}
