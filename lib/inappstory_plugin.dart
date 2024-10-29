import 'dart:async';

import 'package:inappstory_plugin/inappstory_sdk_module.dart';

import 'inappstory_plugin_platform_interface.dart';

export 'package:inappstory_plugin/src/pigeon_generated.g.dart';

export 'src/stories_stream.dart';

class InappstoryPlugin implements InappstorySdkModule {
  Future<String?> getPlatformVersion() {
    return InappstoryPluginPlatform.instance.getPlatformVersion();
  }

  @override
  Future<void> initWith(String apiKey, String userID, bool sandbox, bool sendStatistics) {
    return InappstoryPluginPlatform.instance.initWith(apiKey, userID, sandbox, sendStatistics);
  }

  @override
  FutureOr<void> getStories(String feed) {
    return InappstoryPluginPlatform.instance.getStories(feed);
  }
}
