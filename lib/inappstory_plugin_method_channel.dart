import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:inappstory_plugin/src/pigeon_generated.g.dart';

import 'inappstory_plugin_platform_interface.dart';

/// An implementation of [InappstoryPluginPlatform] that uses method channels.
class MethodChannelInappstoryPlugin extends InappstoryPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('inappstory_plugin');
  final inappstorySdkModuleHostApi = InappstorySdkModuleHostApi();

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> initWith(String apiKey, String userID, bool sendStatistics) async {
    await inappstorySdkModuleHostApi.initWith(apiKey, userID, sendStatistics);
  }

  @override
  Future<void> getStories(String feed) {
    return inappstorySdkModuleHostApi.getStories(feed);
  }
}
