import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'inappstory_plugin_platform_interface.dart';
import 'inappstory_sdk_module.dart';
import 'src/base_story_widget.dart';
import 'src/favorites_stories_stream.dart';
import 'src/feed_stories_controller.dart';
import 'src/feed_stories_stream.dart';
import 'src/widgets/decorators/feed_decorator.dart';

export 'src/base_feed_favorites_widget.dart';
export 'src/feed_favorite_widget.dart';
export 'src/feed_stories_controller.dart';
export 'src/feed_stories_stream.dart';
export 'src/grid_feed_favorites_widget.dart';
export 'src/pigeon_generated.g.dart';
export 'src/story.dart';
export 'src/widgets/decorators/feed_decorator.dart';
export 'src/widgets/feed_stories_widget.dart';
export 'src/widgets/story_widget.dart';

class InAppStoryPlugin implements InAppStorySdkModule {
  factory InAppStoryPlugin() => _singleton ??= InAppStoryPlugin._private();

  InAppStoryPlugin._private();

  static InAppStoryPlugin? _singleton;

  @override
  Future<void> initWith(String apiKey, String userID, bool sendStatistics) {
    return InappstoryPluginPlatform.instance.initWith(apiKey, userID, sendStatistics);
  }

  @Deprecated('Use FeedStoriesWidget instead')
  Stream<Iterable<Widget>> getStoriesWidgets({
    required String feed,
    required StoryWidgetBuilder storyBuilder,
    FeedFavoritesWidgetBuilder? favoritesBuilder,
    FeedStoriesController? storiesController,
    FeedStoryDecorator? storiesDecorator,
  }) {
    return FeedStoriesStream(
      feed: feed,
      storyWidgetBuilder: storyBuilder,
      feedController: storiesController,
      feedFavoritesWidgetBuilder: favoritesBuilder,
      feedDecorator: storiesDecorator,
    );
  }

  @Deprecated('Use FavoriteStoriesFeedWidget instead')
  Stream<Iterable<Widget>> getFavoritesStoriesWidgets({
    required String feed,
    required StoryWidgetBuilder storyBuilder,
    FeedStoriesController? storiesController,
    FeedStoryDecorator? storiesDecorator,
  }) {
    return FavoritesStoriesStream(
      feed: feed,
      storyWidgetBuilder: storyBuilder,
      feedController: storiesController,
      feedDecorator: storiesDecorator,
    );
  }
}
