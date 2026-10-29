import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/pigeon_generated_private.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/CoreGeneratedPrivate.g.kt',
  kotlinOptions: KotlinOptions(includeErrorClass: false),
  swiftOut: 'ios/inappstory_plugin/Sources/inappstory_plugin/CoreGeneratedPrivate.g.swift',
  swiftOptions: SwiftOptions(includeErrorClass: false),
))

@HostApi()
abstract class InAppStoryStatManagerHostApi {
  @asyncCallback
  void sendStatistics(bool enabled);
}

@FlutterApi()
abstract class LoggerFlutterApi {
  @asyncCallback
  void errorLog(String? tag, String? message);

  @asyncCallback
  void debugLog(String? tag, String? message);
}
