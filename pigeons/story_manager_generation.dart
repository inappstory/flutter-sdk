import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/story_manager_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/StoryManagerGenerated.g.kt',
  kotlinOptions: KotlinOptions(includeErrorClass: false),
  swiftOut:
      'ios/inappstory_plugin/Sources/inappstory_plugin/StoryManagerGenerated.g.swift',
  swiftOptions: SwiftOptions(includeErrorClass: false),
))
// ConfigurePigeon

@HostApi()
abstract class InAppStoryManagerHostApi {
  void setPlaceholders(Map<String, String> newPlaceholders);

  void setTags(List<String> tags);

  void addTags(List<String> tags);

  void removeTags(List<String> tags);

  @asyncCallback
  void changeUser(String userId, {String? userSign});

  void userLogout();

  @asyncCallback
  void closeReaders();

  void clearCache();

  void setLang(String languageCode, String languageRegion);

  void setTransparentStatusBar();

  void changeSound(bool value);

  void setUserSettings({
    bool? anonymous,
    String? userId,
    String? userSign,
    String? newLanguageCode,
    String? newLanguageRegion,
    List<String>? newTags,
    Map<String, String>? newPlaceholders,
  });

  void setOptionKeys(Map<String, String> options);
}