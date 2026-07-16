import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';

import '../../controllers/feed_stories_controller.dart';
import '../../data/observable.dart';
import '../../data/story_from_pigeon_dto.dart';
import '../../generated/pigeon_generated.g.dart'
    show
        InAppStoryAPIListSubscriberFlutterApi,
        IASStoryListHostApi,
        StoryAPIDataDto,
        StoryFavoriteItemAPIDataDto,
        InappstorySdkModuleHostApi;
import '../base/base_story_widget.dart';
import '../builders/builders.dart';
import '../decorators/feed_decorator.dart';

abstract class StoriesStream extends Stream<Iterable<Widget>>
    implements InAppStoryAPIListSubscriberFlutterApi {
  StoriesStream({
    required this.feed,
    required this.uniqueId,
    required this.storyWidgetBuilder,
    required this.observableStoryList,
    required this.iasStoryListHostApi,
    required this.storyDecorator,
    FeedStoriesController? feedController,
  }) {
    this.feedController = feedController;
  }

  final String uniqueId;

  String feed;
  final Observable<InAppStoryAPIListSubscriberFlutterApi> observableStoryList;
  final StoryWidgetBuilder storyWidgetBuilder;
  final IASStoryListHostApi iasStoryListHostApi;
  final FeedStoryDecorator storyDecorator;

  List<StoryFromPigeonDto> stories = [];

  static const _loadTimeout = Duration(seconds: 15);

  Timer? _loadWatchdog;

  @protected
  void armLoadWatchdog() {
    _loadWatchdog?.cancel();
    _loadWatchdog = Timer(_loadTimeout, () {
      log('[InAppStory]: feed "$feed" got no response from the native SDK '
          'within ${_loadTimeout.inSeconds}s, reporting it as a failure');
      storiesUpdateFailure(feed, 'timeout: no response from InAppStory SDK');
    });
  }

  @protected
  void disarmLoadWatchdog() {
    _loadWatchdog?.cancel();
    _loadWatchdog = null;
  }

  @protected
  Future<void> reload() => iasStoryListHostApi.reloadFeed(feed);

  Future<void> _reloadAndArm() async {
    armLoadWatchdog();
    await reload();
  }

  late final FeedReloadCallback _reload = _reloadAndArm;

  FeedStoriesController? _feedController;

  FeedStoriesController? get feedController => _feedController;

  set feedController(FeedStoriesController? controller) {
    if (identical(_feedController, controller)) return;

    _feedController?.detach(_reload);
    _feedController = controller;
    controller?.attach(_reload);
  }

  late final controller = StreamController<Iterable<Widget>>(
    onListen: onListen,
    onCancel: onCancel,
  );

  void onListen() async {
    await InappstorySdkModuleHostApi().createListAdaptor(feed, uniqueId);
    observableStoryList.addObserver(this);
    armLoadWatchdog();
    iasStoryListHostApi.load(feed, uniqueId);
  }

  void onCancel() async {
    disarmLoadWatchdog();
    iasStoryListHostApi.removeSubscriber(uniqueId);
    observableStoryList.removeObserver(this);
    await InappstorySdkModuleHostApi().removeListAdaptor(feed, uniqueId);
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
}
