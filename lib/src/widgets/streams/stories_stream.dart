import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/observable.dart';
import '../../data/story_from_pigeon_dto.dart';
import '../../pigeon_generated.g.dart';
import '../base/base_story_widget.dart';
import '../builders/builders.dart';
import '../decorators/feed_decorator.dart';

abstract class StoriesStream extends Stream<Iterable<Widget>>
    implements InAppStoryAPIListSubscriberFlutterApi, ErrorCallbackFlutterApi {
  StoriesStream({
    required this.feed,
    required this.uniqueId,
    required this.storyWidgetBuilder,
    required this.observableStoryList,
    required this.observableErrorCallback,
    required this.iasStoryListHostApi,
    required this.storyDecorator,
  });

  final String uniqueId;
  final String feed;
  final Observable<InAppStoryAPIListSubscriberFlutterApi> observableStoryList;
  final Observable<ErrorCallbackFlutterApi> observableErrorCallback;
  final StoryWidgetBuilder storyWidgetBuilder;
  final IASStoryListHostApi iasStoryListHostApi;
  final FeedStoryDecorator storyDecorator;

  Iterable<StoryFromPigeonDto> stories = [];

  late final controller = StreamController<Iterable<Widget>>(
    onListen: onListen,
    onCancel: onCancel,
  );

  void onListen() async {
    await InappstorySdkModuleHostApi().createListAdaptor(feed);
    observableStoryList.addObserver(this);
    observableErrorCallback.addObserver(this);
    iasStoryListHostApi.load(feed);
  }

  void onCancel() async {
    iasStoryListHostApi.removeSubscriber(feed);
    observableStoryList.removeObserver(this);
    observableErrorCallback.removeObserver(this);
    await InappstorySdkModuleHostApi().removeListAdaptor(feed);
  }

  StoryFromPigeonDto createStoryFromDto(StoryAPIDataDto dto) {
    return StoryFromPigeonDto(
        dto, feed, iasStoryListHostApi, observableStoryList);
  }

  BaseStoryWidget createWidgetFromStory(StoryFromPigeonDto story) {
    return BaseStoryWidget(
      story,
      storyWidgetBuilder,
      storyDecorator: storyDecorator,
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
    VoidCallback? onDone,
    bool? cancelOnError,
  }) {
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
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
