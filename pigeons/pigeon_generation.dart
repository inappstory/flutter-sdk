import 'package:pigeon/pigeon.dart';

// Comment before run
// flutter pub run pigeon --input pigeon_generation.dart
// import 'lib/inappstory_sdk_module.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/pigeon_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/PigeonGenerated.g.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut: 'ios/Classes/PigeonGenerated.g.swift',
  swiftOptions: SwiftOptions(),
))
// ConfigurePigeon

@HostApi()
abstract class InappstorySdkModuleHostApi {
  @async
  void initWith(
    String apiKey,
    String userID, {
    bool anonymous = false,
    String? userSign,
    String? languageCode,
    String? languageRegion,
    String? cacheSize,
  });

  void createListAdaptor(String feed);

  void removeListAdaptor(String feed);
}

@HostApi()
abstract class InAppStoryManagerHostApi {
  void setPlaceholders(Map<String, String> newPlaceholders);

  void setTags(List<String> tags);

  @async
  void changeUser(String userId, {String? userSign});

  void userLogout();

  void closeReaders();

  void clearCache();

  void setLang(String languageCode, String languageRegion);

  void setTransparentStatusBar();

  void changeSound(bool value);

  void setUserSettings(
    bool anonymous, {
    String? userId,
    String? userSign,
    String? newLanguageCode,
    String? newLanguageRegion,
    List<String>? newTags,
    Map<String, String>? newPlaceholders,
  });
}

@HostApi()
abstract class IASStoryListHostApi {
  void load(String feed);

  void reloadFeed(String feed);

  void openStoryReader(int storyId, String feed);

  void showFavoriteItem(String feed);

  void updateVisiblePreviews(List<int> storyIds, String feed);

  void removeSubscriber(String feed);
}

@FlutterApi()
abstract class InAppStoryAPIListSubscriberFlutterApi {
  void updateStoryData(StoryAPIDataDto var1);

  void updateStoriesData(List<StoryAPIDataDto> list);

  void updateFavoriteStoriesData(List<StoryFavoriteItemAPIDataDto> list);

  void storiesLoaded(int size, String feed);

  void scrollToStory(int index, String feed);
}

@FlutterApi()
abstract class ErrorCallbackFlutterApi {
  void loadListError(String feed);

  void cacheError();

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
  void callToAction(
      SlideDataDto? slideData, String? url, ClickActionDto? clickAction);
}

class SlideDataDto {
  late StoryDataDto? story;
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

class GoodsItemAppearanceDto {
  late int? itemBackgroundColor;
  late int? itemCornerRadius;
  late int? itemMainTextColor;
  late int? itemOldPriceTextColor;
  late int? itemTitleTextSize;
  late int? itemDescriptionTextSize;
  late int? itemPriceTextSize;
  late int? itemOldPriceTextSize;
  late int? widgetBackgroundColor;
  late String? closeButtonImage;
  late int? closeButtonColor;
  late int? widgetBackgroundHeight;
}

enum CoverQuality { Medium, High }

@HostApi()
abstract class AppearanceManagerHostApi {
  void setHasLike(bool value);

  void setHasFavorites(bool value);

  void setHasShare(bool value);

  void setClosePosition(Position position);

  void setTimerGradientEnable(bool isEnabled);

  bool getTimerGradientEnable();

  void setTimerGradient(
      {required List<int> colors, List<double> locations = const []});

  void setReaderBackgroundColor(int color);

  void setReaderCornerRadius(int radius);

  void setLikeIcon(String iconPath, String selectedIconPath);

  void setDislikeIcon(String iconPath, String selectedIconPath);

  void setFavoriteIcon(String iconPath, String selectedIconPath);

  void setShareIcon(String iconPath, String selectedIconPath);

  void setCloseIcon(String iconPath);

  void setRefreshIcon(String iconPath);

  void setSoundIcon(String iconPath, String selectedIconPath);

  void setUpGoods(GoodsItemAppearanceDto appearance);

  void setCoverQuality(CoverQuality coverQuality);
}

class GoodsItemDataDto {
  late String? sku;
  late String? title;
  late String? description;
  late String? image;
  late String? price;
  late String? oldPrice;
}

@FlutterApi()
abstract class SkusCallbackFlutterApi {
  @async
  List<GoodsItemDataDto> getSkus(List<String> strings);
}

@FlutterApi()
abstract class GoodsItemSelectedCallbackFlutterApi {
  void goodsItemSelected(GoodsItemDataDto item);
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
abstract class IShowStoryCallbackFlutterApi {
  void onShow();

  void onError();

  void alreadyShown();
}

@FlutterApi()
abstract class SingleLoadCallbackFlutterApi {
  void singleLoadSuccess(StoryDataDto storyData);

  void singleLoadError(String? storyId, String? reason);
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
  void onboardingLoadSuccess(int count, String feed);

  void onboardingLoadError(String feed, String? reason);
}

enum ContentTypeDto {
  STORY,
  UGC,
  IN_APP_MESSAGE,
}

class ContentDataDto {
  late ContentTypeDto? contentType;
  late SourceTypeDto? sourceType;
}

@HostApi()
abstract class IASGamesHostApi {
  void openGame(String gameId);

  void closeGame();

  void preloadGames();
}

@FlutterApi()
abstract class GameReaderCallbackFlutterApi {
  void startGame(ContentDataDto? contentData);

  void finishGame(ContentDataDto? contentData, Map<String?, Object?>? result);

  void closeGame(ContentDataDto? contentData);

  void eventGame(ContentDataDto? contentData, String? gameId, String? eventName,
      Map<String?, Object?>? payload);

  void gameError(ContentDataDto? contentData, String? message);
}

@FlutterApi()
abstract class IASCallBacksFlutterApi {
  void onShowStory(StoryDataDto? storyData);

  void onCloseStory(SlideDataDto? slideData);

  void onFavoriteTap(SlideDataDto? slideData, bool isFavorite);

  void onLikeStoryTap(SlideDataDto? slideData, bool isLike);

  void onDislikeStoryTap(SlideDataDto? slideData, bool isDislike);

  void onShareStory(SlideDataDto? slideData);

  void onShowSlide(SlideDataDto? slideData);

  void onStoryWidgetEvent(
      SlideDataDto? slideData, Map<String?, Object?>? widgetData);
}

@HostApi()
abstract class IASInAppMessagesHostApi {
  void showById(String messageId, {bool onlyPreloaded = false});

  void showByEvent(String event, {bool onlyPreloaded = false});

  @async
  bool preloadMessages({List<String>? ids});
}

/// Represents data for an in-app message.
///
/// This class contains information about an in-app message, including its
/// unique identifier, title, and associated event.
class InAppMessageDataDto {
  /// The unique identifier of the in-app message.
  late int id;

  /// The title of the in-app message, or `null` if not available.
  late String? title;

  /// The event associated with the in-app message, or `null` if not available.
  late String? event;
}

@FlutterApi()
abstract class IASInAppMessagesCallbacksFlutterApi {
  void onShowInAppMessage(InAppMessageDataDto? inAppMessageData);

  void onCloseInAppMessage(InAppMessageDataDto? inAppMessageData);

  void onInAppMessageWidgetEvent(InAppMessageDataDto? inAppMessageData,
      String? name, Map<String?, Object?>? data);
}
