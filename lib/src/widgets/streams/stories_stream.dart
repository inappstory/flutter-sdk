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

  /// How long to wait for the native SDK to report the outcome of a load
  /// before giving up. The SDK can silently drop a load (e.g. when settings
  /// change mid-flight) without ever calling back, leaving the UI stuck in
  /// an infinite loading state; this converts that silence into a failure.
  static const _loadTimeout = Duration(seconds: 15);

  Timer? _loadWatchdog;

  // TEMP DIAGNOSTIC: remove before release. Traces the native SDK handshake to
  // find out whether it answers a load at all after a settings change.
  // Uses print, not log: dart:developer log goes to the VM service only and
  // never reaches the stdout that `flutter run` prints.
  // ignore: avoid_print
  void _trace(String message) =>
      print('[IAS-TRACE][$feed/$uniqueId] $message @${DateTime.now()}');

  @protected
  void armLoadWatchdog() {
    _loadWatchdog?.cancel();
    _trace('watchdog armed (${_loadTimeout.inSeconds}s)');
    _loadWatchdog = Timer(_loadTimeout, () {
      _trace('WATCHDOG FIRED: SDK never answered');
      storiesUpdateFailure(feed, 'timeout: no response from InAppStory SDK');
    });
  }

  @protected
  void disarmLoadWatchdog() {
    if (_loadWatchdog != null) _trace('watchdog disarmed (SDK answered)');
    _loadWatchdog?.cancel();
    _loadWatchdog = null;
  }

  @protected
  Future<void> reload() => iasStoryListHostApi.reloadFeed(feed);

  Future<void> _reloadAndArm() async {
    _trace('reload() called by controller');
    armLoadWatchdog();
    try {
      await reload();
      _trace('reload() channel call returned OK');
    } catch (e) {
      _trace('reload() channel call THREW: $e');
      rethrow;
    }
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
    _trace('onListen: creating list adaptor');
    await InappstorySdkModuleHostApi().createListAdaptor(feed, uniqueId);
    observableStoryList.addObserver(this);
    armLoadWatchdog();
    _trace('onListen: calling load()');
    iasStoryListHostApi.load(feed, uniqueId);
  }

  void onCancel() async {
    _trace('onCancel: tearing down (widget unmounted)');
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
