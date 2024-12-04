import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/inappstory_plugin_method_channel.dart';
import 'package:inappstory_plugin/inappstory_plugin_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockInappstoryPluginPlatform with MockPlatformInterfaceMixin implements InappstoryPluginPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> initWith(String apiKey, String userID, bool sendStatistics) {
    throw UnimplementedError();
  }
}

void main() {
  final InappstoryPluginPlatform initialPlatform = InappstoryPluginPlatform.instance;

  test('$MethodChannelInappstoryPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelInappstoryPlugin>());
  });
}
