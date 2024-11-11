import 'dart:async';

import 'inappstory_plugin.dart';
import 'inappstory_plugin_platform_interface.dart';
import 'inappstory_sdk_module.dart';
import 'src/base_story_widget.dart';
import 'src/feed_stories_stream.dart';
import 'src/ias_story_list_host_api_decorator.dart';
import 'src/in_app_story_api_list_subscriber_flutter_api_observable.dart';
import 'src/story_from_pigeon_dto.dart';

export 'src/pigeon_generated.g.dart';
export 'src/story.dart';
export 'src/story_widget.dart';

class InappstoryPlugin implements InappstorySdkModule {
  factory InappstoryPlugin() => _singleton ??= InappstoryPlugin._private();

  InappstoryPlugin._private();

  static InappstoryPlugin? _singleton;

  late final IASStoryListHostApi _iasStoryListHostApi = IASStoryListHostApiDecorator(IASStoryListHostApi());

  late final InAppStoryAPIListSubscriberFlutterApiObservable _inAppStoryAPIListSubscriberFlutterApiObservable =
      InAppStoryAPIListSubscriberFlutterApiObservable();

  Future<String?> getPlatformVersion() {
    return InappstoryPluginPlatform.instance.getPlatformVersion();
  }

  @override
  Future<void> initWith(String apiKey, String userID, bool sendStatistics) {
    return InappstoryPluginPlatform.instance.initWith(apiKey, userID, sendStatistics);
  }

  @override
  FutureOr<void> getStories(String feed) {
    return InappstoryPluginPlatform.instance.getStories(feed);
  }

  Future<Iterable<StoryWidget>> getStoriesWidgets(String feed, StoryWidgetBuilder builder) async {
    final dtos = await FeedStoriesStream(feed, _inAppStoryAPIListSubscriberFlutterApiObservable).first;

    BaseStoryWidget createWidget(StoryFromPigeonDto story) => BaseStoryWidget(story, builder);

    return dtos.map(_createStory).map(createWidget).toList(growable: false);
  }

  StoryFromPigeonDto _createStory(StoryAPIDataDto dto) {
    return StoryFromPigeonDto(dto, _iasStoryListHostApi, _inAppStoryAPIListSubscriberFlutterApiObservable);
  }
}
