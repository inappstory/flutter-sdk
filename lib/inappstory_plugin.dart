import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'inappstory_plugin_platform_interface.dart';
import 'inappstory_sdk_module.dart';
import 'src/base_story_widget.dart';
import 'src/feed_stories_stream.dart';

export 'src/pigeon_generated.g.dart';
export 'src/story.dart';
export 'src/story_widget.dart';

class InAppStoryPlugin implements InAppStorySdkModule {
  factory InAppStoryPlugin() => _singleton ??= InAppStoryPlugin._private();

  InAppStoryPlugin._private();

  static InAppStoryPlugin? _singleton;

  Future<String?> getPlatformVersion() {
    return InappstoryPluginPlatform.instance.getPlatformVersion();
  }

  @override
  Future<void> initWith(String apiKey, String userID, bool sendStatistics) {
    return InappstoryPluginPlatform.instance.initWith(apiKey, userID, sendStatistics);
  }

  Stream<Iterable<Widget>> getStoriesWidgets(String feed, StoryWidgetBuilder builder) {
    return FeedStoriesStream(feed, "feed", builder, true);
  }
}
