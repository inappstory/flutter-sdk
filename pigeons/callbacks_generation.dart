import 'package:pigeon/pigeon.dart';

import 'story_list_generation.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/pigeon_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/CallbacksGenerated.g.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut:
      'ios/inappstory_plugin/Sources/inappstory_plugin/CallbacksGenerated.g.swift',
  swiftOptions: SwiftOptions(),
))
// ConfigurePigeon

@FlutterApi()
abstract class ErrorCallbackFlutterApi {
  @asyncCallback
  void sessionError();

  @asyncCallback
  void noConnection();
}

@FlutterApi()
abstract class CallToActionCallbackFlutterApi {
  @asyncCallback
  void callToAction(
      SlideDataDto? slideData, String? url, ClickActionDto? clickAction);
}

enum ClickActionDto {
  button,
  swipe,
  game,
  deeplink,
}

@FlutterApi()
abstract class IASCallBacksFlutterApi {
  @asyncCallback
  void onShowStory(StoryDataDto? storyData);

  @asyncCallback
  void onCloseStory(SlideDataDto? slideData);

  @asyncCallback
  void onFavoriteTap(SlideDataDto? slideData, bool isFavorite);

  @asyncCallback
  void onLikeStoryTap(SlideDataDto? slideData, bool isLike);

  @asyncCallback
  void onDislikeStoryTap(SlideDataDto? slideData, bool isDislike);

  @asyncCallback
  void onShareStory(SlideDataDto? slideData);

  @asyncCallback
  void onShowSlide(SlideDataDto? slideData);

  @asyncCallback
  void onStoryWidgetEvent(
      SlideDataDto? slideData, Map<String?, Object?>? widgetData);
}
