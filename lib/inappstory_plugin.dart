
import 'inappstory_plugin_platform_interface.dart';

class InappstoryPlugin {
  Future<String?> getPlatformVersion() {
    return InappstoryPluginPlatform.instance.getPlatformVersion();
  }
}
