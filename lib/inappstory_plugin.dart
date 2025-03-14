import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'inappstory_plugin_platform_interface.dart';
import 'inappstory_sdk_module.dart';
import 'src/base_story_widget.dart';
import 'src/favorites_stories_stream.dart';
import 'src/feed_stories_stream.dart';

export 'src/base_feed_favorites_widget.dart';
export 'src/feed_favorite_widget.dart';
export 'src/feed_stories_stream.dart';
export 'src/grid_feed_favorites_widget.dart';
export 'src/pigeon_generated.g.dart';
export 'src/story.dart';
export 'src/story_widget.dart';

class InAppStoryPlugin implements InAppStorySdkModule {
  factory InAppStoryPlugin() => _singleton ??= InAppStoryPlugin._private();

  InAppStoryPlugin._private();

  static InAppStoryPlugin? _singleton;

  @override
  Future<void> initWith(String apiKey, String userID, bool sendStatistics) {
    return InappstoryPluginPlatform.instance.initWith(apiKey, userID, sendStatistics);
  }

  Stream<Iterable<Widget>> getStoriesWidgets({
    required String feed,
    required StoryWidgetBuilder storyBuilder,
    FeedFavoritesWidgetBuilder? favoritesBuilder,
  }) {
    return FeedStoriesStream(
      feed: feed,
      storyWidgetBuilder: storyBuilder,
      feedFavoritesWidgetBuilder: favoritesBuilder,
    );
  }

  Stream<Iterable<Widget>> getFavoritesStoriesWidgets({
    required String feed,
    required StoryWidgetBuilder storyBuilder,
  }) {
    return FavoritesStoriesStream(feed: feed, storyWidgetBuilder: storyBuilder);
  }
}
