import 'dart:async';

import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin/inappstory_plugin_platform_interface.dart';

import 'feed_stories_stream.dart';

abstract class StoriesStream extends Stream<Iterable<StoryAPIData>> {
  factory StoriesStream.feed(String feed) {
    return FeedStoriesStream(feed);
  }
}


