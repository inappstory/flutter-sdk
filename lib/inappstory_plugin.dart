import 'dart:async';

import 'package:inappstory_plugin/inappstory_sdk_module.dart';
import 'package:inappstory_plugin/src/stories_stream.dart';
import 'package:inappstory_plugin/src/story_from_pigeon_dto.dart';

import 'inappstory_plugin_platform_interface.dart';
import 'src/story.dart';

export 'package:inappstory_plugin/src/pigeon_generated.g.dart';

export 'src/default_story_widget.dart';
export 'src/stories_stream.dart';
export 'src/story.dart';

class InappstoryPlugin implements InappstorySdkModule {
  Future<String?> getPlatformVersion() {
    return InappstoryPluginPlatform.instance.getPlatformVersion();
  }

  @override
  Future<void> initWith(String apiKey, String userID, bool sendStatistics) {
    return InappstoryPluginPlatform.instance.initWith(apiKey, userID, sendStatistics);
  }

  @override
  FutureOr<void> getStories(String feed) {
    return InappstoryPluginPlatform.instance.getStories(feed);
  }

  Future<Iterable<Story>> getStories2(String feed) async {
    final dtos = await StoriesStream.feed(feed).first;

    return dtos.map(StoryFromPigeonDto.new).toList();
  }
}
