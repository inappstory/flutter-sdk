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
  @async
  void initWith(String apiKey, String userID, bool sendStatistics);
}

@HostApi()
abstract class InAppStoryManagerHostApi {
  void setPlaceholders(Map<String, String> newPlaceholders);

  void setTags(List<String> tags);

  @async
  void changeUser(String userId);

  void closeReaders();
}

@HostApi()
abstract class IASStoryListHostApi {
  void load(String feed);

  void openStoryReader(int storyId);

  void showFavoriteItem();

  void updateVisiblePreviews(List<int> storyIds);
}

@FlutterApi()
abstract class InAppStoryAPIListSubscriberFlutterApi {
  void updateStoryData(StoryAPIDataDto var1);

  void updateStoriesData(List<StoryAPIDataDto> list);

  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto> list);
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
  late String? title;
  late String? tags;
  late String? feed;
  late SourceTypeDto? sourceType;
  late int slidesCount;
  late StoryTypeDto? storyType;
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
  DEEPLINK,
}

enum Position {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

@HostApi()
abstract class AppearanceManagerHostApi {
  void setHasLike(bool value);

  void setHasFavorites(bool value);

  void setHasShare(bool value);

  void setClosePosition(Position position);

  void setTimerGradientEnable(bool isEnabled);

  bool getTimerGradientEnable();

  void setTimerGradient({required List<int> colors, List<double> locations = const []});

  void setReaderBackgroundColor(int color);

  void setReaderCornerRadius(int radius);
}

class StoryFavoriteItemAPIDataDto {
  late int id;
  late String? imageFilePath;
  late String backgroundColor;
}

@HostApi()
abstract class IASSingleStoryHostApi {
  void showOnce({required String storyId});

  void show({required String storyId});
}

@FlutterApi()
abstract class IShowStoryOnceCallbackFlutterApi {
  void onShow();

  void onError();

  void alreadyShown();
}

@FlutterApi()
abstract class SingleLoadCallbackFlutterApi {
  void singleLoad(StoryDataDto storyData);
}

@HostApi()
abstract class IASOnboardingsHostApi {
  /// [feed] by default == "onboarding"
  /// [limit] has to be set greater than 0 (can be set as any big number if limits is unnecessary)
  void show({
    required int limit,
    String feed = "onboarding",
    List<String> tags = const [],
  });
}

@FlutterApi()
abstract class OnboardingLoadCallbackFlutterApi {
  void onboardingLoad(int count, String feed);
}
