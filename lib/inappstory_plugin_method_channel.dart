import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'inappstory_plugin_platform_interface.dart';
import 'src/pigeon_generated.g.dart';

/// An implementation of [InappstoryPluginPlatform] that uses method channels.
class MethodChannelInappstoryPlugin extends InappstoryPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('inappstory_plugin');
  final inappstorySdkModuleHostApi = InappstorySdkModuleHostApi();

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  FutureOr<void> initWith(String apiKey, String userId,
      {String? languageCode, String? languageRegion}) async {
    await inappstorySdkModuleHostApi.initWith(apiKey, userId,
        languageCode: languageCode, languageRegion: languageRegion);
  }
}
