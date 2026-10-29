import 'package:pigeon/pigeon.dart';

import 'story_list_generation.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/pigeon_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/StoryGenerated.g.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut:
      'ios/inappstory_plugin/Sources/inappstory_plugin/StoryGenerated.g.swift',
  swiftOptions: SwiftOptions(),
))
// ConfigurePigeon

@HostApi()
abstract class IASSingleStoryHostApi {
  void showOnce({required String storyId, required String token});

  void show({
    required String storyId,
    required String token,
    List<String>? tags,
  });

  bool cancelByToken({required String token});
}

@FlutterApi()
abstract class IShowStoryCallbackFlutterApi {
  @asyncCallback
  void onShow();

  @asyncCallback
  void onError();

  @asyncCallback
  void alreadyShown();
}

@FlutterApi()
abstract class SingleLoadCallbackFlutterApi {
  @asyncCallback
  void singleLoadSuccess(StoryDataDto storyData);

  @asyncCallback
  void singleLoadError(String? storyId, String? reason);
}
