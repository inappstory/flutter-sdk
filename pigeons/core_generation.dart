import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/pigeon_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/CoreGenerated.g.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut:
      'ios/inappstory_plugin/Sources/inappstory_plugin/CoreGenerated.g.swift',
  swiftOptions: SwiftOptions(),
))
// ConfigurePigeon

@HostApi()
abstract class InappstorySdkModuleHostApi {
  @asyncCallback
  void initWith(
    String apiKey,
    String userID, {
    bool anonymous = false,
    String? userSign,
    String? languageCode,
    String? languageRegion,
    String? cacheSize,
    List<String>? tags,
  });

  void createListAdaptor(String feed, String uniqueId);

  void removeListAdaptor(String feed, String uniqueId);

  bool isInitialized();
}
