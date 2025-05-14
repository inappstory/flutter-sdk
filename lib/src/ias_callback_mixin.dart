import 'package:flutter/material.dart';

import '../inappstory_plugin.dart';

/// A mixin that provides callback methods for handling various events
/// related to stories and slides
mixin IASCallbacks<T extends StatefulWidget> on State<T> implements IASCallBacksFlutterApi {
  /// Sets up the callbacks by registering this mixin instance
  @override
  void initState() {
    super.initState();
    IASCallBacksFlutterApi.setUp(this);
  }

  /// Removes the callbacks by unregistering this mixin instance
  @override
  void dispose() {
    IASCallBacksFlutterApi.setUp(null);
    super.dispose();
  }

  /// Called when a story is shown.
  ///
  /// [storyData] - Data about the story being shown, or `null` if unavailable.
  @override
  void onShowStory(StoryDataDto? storyData) {}

  /// Called when a story is closed.
  ///
  /// [slideData] - Data about the slide being closed, or `null` if unavailable.
  @override
  void onCloseStory(SlideDataDto? slideData) {}

  /// Called when the favorite button is tapped on a slide.
  ///
  /// [slideData] - Data about the slide where the favorite button was tapped, or `null` if unavailable.
  /// [isFavorite] - A boolean indicating whether the slide is marked as favorite.
  @override
  void onFavoriteTap(SlideDataDto? slideData, bool isFavorite) {}

  /// Called when the like button is tapped on a story.
  ///
  /// [slideData] - Data about the slide where the like button was tapped, or `null` if unavailable.
  /// [isLike] - A boolean indicating whether the story is liked.
  @override
  void onLikeStoryTap(SlideDataDto? slideData, bool isLike) {}

  /// Called when the dislike button is tapped on a story.
  ///
  /// [slideData] - Data about the slide where the dislike button was tapped, or `null` if unavailable.
  /// [isDislike] - A boolean indicating whether the story is disliked.
  @override
  void onDislikeStoryTap(SlideDataDto? slideData, bool isDislike) {}

  /// Called when a story is shared. Does not override default share behaviour.
  ///
  /// [slideData] - Data about the slide being shared, or `null` if unavailable.
  @override
  void onShareStory(SlideDataDto? slideData) {}

  /// Called when a slide is shown.
  ///
  /// [slideData] - Data about the slide being shown, or `null` if unavailable.
  @override
  void onShowSlide(SlideDataDto? slideData) {}

  /// Called when a widget event occurs in a story.
  ///
  /// [slideData] - Data about the slide where the widget event occurred, or `null` if unavailable.
  @override
  void onStoryWidgetEvent(SlideDataDto? slideData, Map<String?, Object?>? widgetData) {}
}
