import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/pigeon_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/StoryListGenerated.g.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut:
      'ios/inappstory_plugin/Sources/inappstory_plugin/StoryListGenerated.g.swift',
  swiftOptions: SwiftOptions(),
))
// ConfigurePigeon

enum StoryTypeDto { common, ugc, iam, banner }

enum SourceTypeDto {
  single,
  onboarding,
  list,
  favorite,
  stack,
  inAppMessage,
  banners
}

@HostApi()
abstract class IASStoryListHostApi {
  void load(String feed, String uniqueId);

  void reloadFeed(String feed);

  void openStoryReader(int storyId, String feed);

  void showFavoriteItem(String feed);

  void updateVisiblePreviews(List<int> storyIds, String feed);

  void removeSubscriber(String feed);
}

@FlutterApi()
abstract class InAppStoryAPIListSubscriberFlutterApi {
  @asyncCallback
  void updateStoryData(StoryAPIDataDto var1);

  @asyncCallback
  void updateStoriesData(List<StoryAPIDataDto?> list);

  @asyncCallback
  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto?> list);

  @asyncCallback
  void storiesLoaded(int size, String feed);

  @asyncCallback
  void scrollToStory(int index, String feed, String uniqueId);

  @asyncCallback
  void storiesUpdateFailure(String feed, String? reason);
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
  late Map<String, String>? extraFields;
}

class StoryFavoriteItemAPIDataDto {
  late int id;
  late String? imageFilePath;
  late String backgroundColor;
}

class SlideDataDto {
  late StoryDataDto? story;
  late int index;
  late String? payload;
}

@HostApi()
abstract class IASOnboardingsHostApi {
  /// [feed] by default == "onboarding"
  /// [limit] has to be set greater than 0 (can be set as any big number if limits is unnecessary)
  void show({
    required int limit,
    String feed = 'onboarding',
    required String token,
    List<String> tags = const [],
  });

  bool cancelByToken(String token);
}

@FlutterApi()
abstract class OnboardingLoadCallbackFlutterApi {
  @asyncCallback
  void onboardingLoadSuccess(int count, String feed);

  @asyncCallback
  void onboardingLoadError(String feed, String? reason);
}
