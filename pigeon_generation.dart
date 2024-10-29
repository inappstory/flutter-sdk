import 'package:pigeon/pigeon.dart';

// Коментировать перед запуском
// flutter pub run pigeon --input interfaces.dart
// import 'lib/inappstory_sdk_module.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/pigeon_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/src/main/kotlin/com/example/inappstory_plugin/PigeonGenerated.g.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut: 'ios/Runner/PigeonGenerated.g.swift',
  swiftOptions: SwiftOptions(),
))
// ConfigurePigeon

@HostApi()
abstract class InappstorySdkModuleHostApi implements InappstorySdkModule {
  @override
  void initWith(String apiKey, String userID, bool sandbox, bool sendStatistics);

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

  void updateStoryData(StoryAPIData var1);

  void updateStoriesData(List<StoryAPIData> list);

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

class StoryAPIData {
  late int id;
  late StoryData storyData;
  late String? imageFilePath;
  late String? videoFilePath;
  late bool hasAudio;
  late String title;
  late String titleColor;
  late String backgroundColor;
  late bool opened;
  late double aspectRatio;
}

class StoryData {
  late int id;
  late String title;
  late String tags;
  late String feed;
  late SourceType sourceType;
  late int slidesCount;
  late StoryType storyType;
}

enum StoryType {
  COMMON,
  UGC;
}

enum SourceType {
  SINGLE,
  ONBOARDING,
  LIST,
  FAVORITE,
  STACK;
}

@FlutterApi()
abstract class CallToActionCallbackFlutterApi {
  void callToAction(SlideData? slideData, String? url, ClickAction? clickAction);
}

class SlideData {
  late StoryData story;
  late int index;
  late String payload;
}

enum ClickAction {
  BUTTON,
  SWIPE,
  GAME,
  DEEPLINK;
}
