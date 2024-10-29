import 'dart:async';

import 'package:inappstory_plugin/inappstory_sdk_module.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappstory_plugin_method_channel.dart';
import 'src/pigeon_generated.g.dart';

abstract class InappstoryPluginPlatform extends PlatformInterface implements InappstorySdkModule {
  /// Constructs a InappstoryPluginPlatform.
  InappstoryPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static InappstoryPluginPlatform _instance = MethodChannelInappstoryPlugin();

  /// The default instance of [InappstoryPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelInappstoryPlugin].
  static InappstoryPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [InappstoryPluginPlatform] when
  /// they register themselves.
  static set instance(InappstoryPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  @override
  Future<void> initWith(String apiKey, String userID, bool sandbox, bool sendStatistics);
}
