import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'inappstory_plugin_platform_interface.dart';
import 'src/generated/pigeon_generated.g.dart' show InappstorySdkModuleHostApi;

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
  FutureOr<void> initWith(
    String apiKey,
    String userId, {
    bool anonymous = false,
    String? userSign,
    String? languageCode,
    String? languageRegion,
    String? cacheSize,
  }) async {
    // TEMP DIAGNOSTIC: remove before release. print, not log: dart:developer
    // log never reaches the stdout that `flutter run` prints.
    // ignore: avoid_print
    print('[IAS-TRACE][init] >>> initWith userId=$userId @${DateTime.now()}');
    try {
      await inappstorySdkModuleHostApi.initWith(
        apiKey,
        userId,
        userSign: userSign,
        anonymous: anonymous,
        languageCode: languageCode,
        languageRegion: languageRegion,
        cacheSize: cacheSize,
      );
      // ignore: avoid_print
      print('[IAS-TRACE][init] <<< initWith returned OK @${DateTime.now()}');
    } catch (e) {
      // ignore: avoid_print
      print('[IAS-TRACE][init] <<< initWith THREW: $e @${DateTime.now()}');
      rethrow;
    }
  }

  @override
  Future<bool> isInitialized() {
    return inappstorySdkModuleHostApi.isInitialized();
  }
}
