import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/pigeon_generated_private.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/PigeonGeneratedPrivate.g.kt',
  kotlinOptions: KotlinOptions(includeErrorClass: false),
  swiftOut: 'ios/Classes/PigeonGeneratedPrivate.g.swift',
  swiftOptions: SwiftOptions(includeErrorClass: false),
))
// ConfigurePigeon

@HostApi()
abstract class InAppStoryStatManagerHostApi {
  @async
  void sendStatistics(bool enabled);
}
