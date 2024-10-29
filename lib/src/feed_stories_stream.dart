import 'dart:async';

import 'package:inappstory_plugin/inappstory_plugin_platform_interface.dart';

import 'pigeon_generated.g.dart';
import 'stories_stream.dart';

class FeedStoriesStream extends Stream<Iterable<StoryAPIData>>
    implements InAppStoryAPIListSubscriberFlutterApi, ErrorCallbackFlutterApi, StoriesStream {
  FeedStoriesStream(this.feed);

  final String feed;

  late final controller = StreamController<Iterable<StoryAPIData>>(
    onListen: onListen,
    onCancel: onCancel,
  );

  void onListen() {
    InAppStoryAPIListSubscriberFlutterApi.setUp(this);
    ErrorCallbackFlutterApi.setUp(this);
    InappstoryPluginPlatform.instance.getStories(feed);
  }

  void onCancel() {
    InAppStoryAPIListSubscriberFlutterApi.setUp(null);
    ErrorCallbackFlutterApi.setUp(null);
  }

  @override
  void updateStoriesData(List<StoryAPIData?> list) {
    controller.add(list.whereType<StoryAPIData>());
  }

  @override
  void loadListError(String feed) {
    controller.addError(Exception('loadListError feed: $feed'));
  }

  @override
  StreamSubscription<Iterable<StoryAPIData>> listen(
    void Function(Iterable<StoryAPIData> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  void readerIsClosed() {}

  @override
  void readerIsOpened() {}

  @override
  void storyIsOpened(int var1) {}

  @override
  void updateStoryData(StoryAPIData var1) {
    print(var1.imageFilePath);
  }

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
