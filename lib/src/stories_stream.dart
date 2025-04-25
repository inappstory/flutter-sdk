import 'dart:async';

import 'package:flutter/widgets.dart';

import 'base_story_widget.dart';
import 'observable.dart';
import 'pigeon_generated.g.dart';
import 'story_from_pigeon_dto.dart';

abstract class StoriesStream extends Stream<Iterable<Widget>>
    implements InAppStoryAPIListSubscriberFlutterApi, ErrorCallbackFlutterApi {
  StoriesStream({
    required this.feed,
    required this.uniqueId,
    required this.storyWidgetBuilder,
    required this.observableStoryList,
    required this.observableErrorCallback,
    required this.iasStoryListHostApi,
  });

  final String uniqueId;
  final String feed;
  final Observable<InAppStoryAPIListSubscriberFlutterApi> observableStoryList;
  final Observable<ErrorCallbackFlutterApi> observableErrorCallback;
  final StoryWidgetBuilder storyWidgetBuilder;
  final IASStoryListHostApi iasStoryListHostApi;

  Iterable<StoryFromPigeonDto> stories = [];

  late final controller = StreamController<Iterable<Widget>>(
    onListen: onListen,
    onCancel: onCancel,
  );

  void onListen() {
    observableStoryList.addObserver(this);
    observableErrorCallback.addObserver(this);
    iasStoryListHostApi.load(feed);
  }

  void onCancel() {
    observableStoryList.removeObserver(this);
    observableErrorCallback.removeObserver(this);
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
  void cacheError() {}

  @override
  void emptyLinkError() {}

  @override
  void noConnection() {}

  @override
  void sessionError() {}
}
