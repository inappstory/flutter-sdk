import 'dart:async';

import 'package:inappstory_plugin/inappstory_plugin_platform_interface.dart';

import 'observable.dart';
import 'pigeon_generated.g.dart';

class FeedStoriesStream extends Stream<Iterable<StoryAPIDataDto>>
    implements InAppStoryAPIListSubscriberFlutterApi, ErrorCallbackFlutterApi {
  FeedStoriesStream(
    this.feed,
    this.observableStoryList,
  );

  final String feed;
  final Observable<InAppStoryAPIListSubscriberFlutterApi> observableStoryList;

  late final controller = StreamController<Iterable<StoryAPIDataDto>>(
    onListen: onListen,
    onCancel: onCancel,
  );

  void onListen() {
    observableStoryList.addObserver(this);
    ErrorCallbackFlutterApi.setUp(this);
    InappstoryPluginPlatform.instance.getStories(feed);
  }

  void onCancel() {
    observableStoryList.removeObserver(this);
    ErrorCallbackFlutterApi.setUp(null);
  }

  @override
  void updateStoriesData(List<StoryAPIDataDto?> list) {
    controller.add(list.whereType<StoryAPIDataDto>());
  }

  @override
  void loadListError(String feed) {
    if (feed != this.feed) return;
    controller.addError(Exception('loadListError feed: $feed'));
  }

  @override
  StreamSubscription<Iterable<StoryAPIDataDto>> listen(
    void Function(Iterable<StoryAPIDataDto> event)? onData, {
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
