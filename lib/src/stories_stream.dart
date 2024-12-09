import 'dart:async';

import 'package:flutter/widgets.dart';

import 'base_story_widget.dart';
import 'ias_story_list_host_api_decorator.dart';
import 'in_app_story_api_list_subscriber_flutter_api_observable.dart';
import 'pigeon_generated.g.dart';
import 'story_from_pigeon_dto.dart';

abstract class StoriesStream extends Stream<Iterable<Widget>>
    implements InAppStoryAPIListSubscriberFlutterApi, ErrorCallbackFlutterApi {
  StoriesStream({
    required this.feed,
    required this.uniqueId,
    required this.storyWidgetBuilder,
  });

  final String uniqueId;
  final String feed;
  late final observableStoryList = InAppStoryAPIListSubscriberFlutterApiObservable(uniqueId);
  final StoryWidgetBuilder storyWidgetBuilder;
  late final IASStoryListHostApi iasStoryListHostApi =
      IASStoryListHostApiDecorator(IASStoryListHostApi(messageChannelSuffix: uniqueId));

  Iterable<StoryFromPigeonDto> stories = [];

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
  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto?> list) {}

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
