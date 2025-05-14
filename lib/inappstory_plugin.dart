import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'inappstory_plugin_platform_interface.dart';
import 'inappstory_sdk_module.dart';
import 'src/controllers/feed_stories_controller.dart';
import 'src/widgets/builders/builders.dart';
import 'src/widgets/decorators/feed_decorator.dart';
import 'src/widgets/streams/favorites_stories_stream.dart';
import 'src/widgets/streams/feed_stories_stream.dart';

export 'src/callbacks/callbacks.dart';
export 'src/controllers/controllers.dart';
export 'src/data/story.dart';
export 'src/pigeon_generated.g.dart';
export 'src/widgets/widgets.dart';

class InAppStoryPlugin implements InAppStorySdkModule {
  factory InAppStoryPlugin() => _singleton ??= InAppStoryPlugin._private();

  InAppStoryPlugin._private();

  static InAppStoryPlugin? _singleton;

  /// The [InAppStoryPlugin] initialization method.
  @override
  Future<void> initWith(String apiKey, String userID, bool sendStatistics) {
    return InappstoryPluginPlatform.instance
        .initWith(apiKey, userID, sendStatistics);
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
