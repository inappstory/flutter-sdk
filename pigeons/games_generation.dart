import 'package:pigeon/pigeon.dart';

import 'story_list_generation.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/banner_place_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/GamesGenerated.g.kt',
  kotlinOptions: KotlinOptions(includeErrorClass: false),
  swiftOut:
      'ios/inappstory_plugin/Sources/inappstory_plugin/GamesGenerated.g.swift',
  swiftOptions: SwiftOptions(includeErrorClass: false),
))
// ConfigurePigeon

enum ContentTypeDto { story, ugc, inAppMessage }

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
  @asyncCallback
  void startGame(ContentDataDto? contentData);

  @asyncCallback
  void finishGame(ContentDataDto? contentData, Map<String, Object?>? result);

  @asyncCallback
  void closeGame(ContentDataDto? contentData);

  @asyncCallback
  void eventGame(ContentDataDto? contentData, String? gameId, String? eventName,
      Map<String, Object?>? payload);

  @asyncCallback
  void gameError(ContentDataDto? contentData, String? message);
}
