import 'package:pigeon/pigeon.dart';

// Коментировать перед запуском
// flutter pub run pigeon --input pigeon_generation.dart
// import 'lib/inappstory_sdk_module.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/pigeon_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/src/main/kotlin/com/example/inappstory_plugin/PigeonGenerated.g.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut: 'ios/Classes/PigeonGenerated.g.swift',
  swiftOptions: SwiftOptions(),
))
// ConfigurePigeon

@HostApi()
abstract class InappstorySdkModuleHostApi implements InappstorySdkModule {
  @override
  void initWith(String apiKey, String userID, bool sendStatistics);

  @override
  void getStories(String feed);

  void setPlaceholders(Map<String, String> newPlaceholders);

  void setTags(List<String> tags);
}

@HostApi()
abstract class IASManager {}

@HostApi()
abstract class InAppStoryAPI {}

@HostApi()
abstract class IASStoryListHostApi {
  void load(String feed, bool hasFavorite, bool isFavorite);

  void openStoryReader(int storyId);

  void showFavoriteItem();

  void updateVisiblePreviews(List<int> storyIds);
}

@FlutterApi()
abstract class InAppStoryAPIListSubscriberFlutterApi {
  void storyIsOpened(int var1);

  void updateStoryData(StoryAPIDataDto var1);

  void updateStoriesData(List<StoryAPIDataDto> list);

  void readerIsOpened();

  void readerIsClosed();
}

@FlutterApi()
abstract class ErrorCallbackFlutterApi {
  void loadListError(String feed);

  void loadOnboardingError(String feed);

  void loadSingleError();

  void cacheError();

  void readerError();

  void emptyLinkError();

  void sessionError();

  void noConnection();
}

class StoryAPIDataDto {
  late int id;
  late StoryDataDto storyData;
  late String? imageFilePath;
  late String? videoFilePath;
  late bool hasAudio;
  late String title;
  late String titleColor;
  late String backgroundColor;
  late bool opened;
  late double aspectRatio;
}

class StoryDataDto {
  late int id;
  late String title;
  late String tags;
  late String feed;
  late SourceTypeDto sourceType;
  late int slidesCount;
  late StoryTypeDto storyType;
}

enum StoryTypeDto {
  COMMON,
  UGC;
}

enum SourceTypeDto {
  SINGLE,
  ONBOARDING,
  LIST,
  FAVORITE,
  STACK;
}

@FlutterApi()
abstract class CallToActionCallbackFlutterApi {
  void callToAction(SlideDataDto? slideData, String? url, ClickActionDto? clickAction);
}

class SlideDataDto {
  late StoryDataDto story;
  late int index;
  late String? payload;
}

enum ClickActionDto {
  BUTTON,
  SWIPE,
  GAME,
  DEEPLINK;
}
