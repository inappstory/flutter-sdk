import 'package:flutter/widgets.dart';

import '../data/story_data.dart';
import '../generated/pigeon_generated.g.dart'
    show StoryDataDto, SlideDataDto, IASCallBacksFlutterApi;

/// A mixin that provides callback methods for handling various events
/// related to stories and slides
mixin IASCallbacks<T extends StatefulWidget> on State<T> {
  _IASCallbacksBridge? _bridge;

  /// Sets up the callbacks by registering this mixin instance
  @override
  void initState() {
    super.initState();
    _bridge = _IASCallbacksBridge(this);
    IASCallBacksFlutterApi.setUp(_bridge);
  }

  /// Removes the callbacks by unregistering this mixin instance
  @override
  void dispose() {
    IASCallBacksFlutterApi.setUp(null);
    _bridge = null;
    super.dispose();
  }

  /// Called when a story is shown.
  ///
  /// [storyData] - Data about the story being shown, or `null` if unavailable.
  Future<void> onShowStory(StoryData? storyData) async {}

  /// Called when a story is closed.
  ///
  /// [slideData] - Data about the slide being closed, or `null` if unavailable.
  Future<void> onCloseStory(SlideData? slideData) async {}

  /// Called when the favorite button is tapped on a slide.
  ///
  /// [slideData] - Data about the slide where the favorite button was tapped, or `null` if unavailable.
  /// [isFavorite] - A boolean indicating whether the slide is marked as favorite.
  Future<void> onFavoriteTap(SlideData? slideData, bool isFavorite) async {}

  /// Called when the like button is tapped on a story.
  ///
  /// [slideData] - Data about the slide where the like button was tapped, or `null` if unavailable.
  /// [isLike] - A boolean indicating whether the story is liked.
  Future<void> onLikeStoryTap(SlideData? slideData, bool isLike) async {}

  /// Called when the dislike button is tapped on a story.
  ///
  /// [slideData] - Data about the slide where the dislike button was tapped, or `null` if unavailable.
  /// [isDislike] - A boolean indicating whether the story is disliked.
  Future<void> onDislikeStoryTap(SlideData? slideData, bool isDislike) async {}

  /// Called when a story is shared. Does not override default share behaviour.
  ///
  /// [slideData] - Data about the slide being shared, or `null` if unavailable.
  Future<void> onShareStory(SlideData? slideData) async {}

  /// Called when a slide is shown.
  ///
  /// [slideData] - Data about the slide being shown, or `null` if unavailable.
  Future<void> onShowSlide(SlideData? slideData) async {}

  /// Called when a widget event occurs in a story.
  ///
  /// [slideData] - Data about the slide where the widget event occurred, or `null` if unavailable.
  Future<void> onStoryWidgetEvent(
      SlideData? slideData, Map<String?, Object?>? widgetData) async {}
}

class _IASCallbacksBridge implements IASCallBacksFlutterApi {
  _IASCallbacksBridge(this._target);

  final IASCallbacks _target;

  @override
  Future<void> onShowStory(StoryDataDto? storyData) =>
      _target.onShowStory(storyData == null ? null : StoryData.fromDto(storyData));

  @override
  Future<void> onCloseStory(SlideDataDto? slideData) =>
      _target.onCloseStory(slideData == null ? null : SlideData.fromDto(slideData));

  @override
  Future<void> onFavoriteTap(SlideDataDto? slideData, bool isFavorite) =>
      _target.onFavoriteTap(
          slideData == null ? null : SlideData.fromDto(slideData), isFavorite);

  @override
  Future<void> onLikeStoryTap(SlideDataDto? slideData, bool isLike) =>
      _target.onLikeStoryTap(
          slideData == null ? null : SlideData.fromDto(slideData), isLike);

  @override
  Future<void> onDislikeStoryTap(SlideDataDto? slideData, bool isDislike) =>
      _target.onDislikeStoryTap(
          slideData == null ? null : SlideData.fromDto(slideData), isDislike);

  @override
  Future<void> onShareStory(SlideDataDto? slideData) =>
      _target.onShareStory(slideData == null ? null : SlideData.fromDto(slideData));

  @override
  Future<void> onShowSlide(SlideDataDto? slideData) =>
      _target.onShowSlide(slideData == null ? null : SlideData.fromDto(slideData));

  @override
  Future<void> onStoryWidgetEvent(
          SlideDataDto? slideData, Map<String?, Object?>? widgetData) =>
      _target.onStoryWidgetEvent(
          slideData == null ? null : SlideData.fromDto(slideData), widgetData);
}
