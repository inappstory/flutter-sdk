import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'inappstory_plugin_platform_interface.dart';

/// An implementation of [InappstoryPluginPlatform] that uses method channels.
class MethodChannelInappstoryPlugin extends InappstoryPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('inappstory_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
