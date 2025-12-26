import 'package:flutter/widgets.dart';

import '../generated/pigeon_generated.g.dart'
    show GameReaderCallbackFlutterApi, ContentDataDto;

mixin IASGameReaderCallback<T extends StatefulWidget> on State<T>
    implements GameReaderCallbackFlutterApi {
  /// Sets up the callbacks by registering this mixin instance
  @override
  void initState() {
    super.initState();
    GameReaderCallbackFlutterApi.setUp(this);
  }

  /// Removes the callbacks by unregistering this mixin instance
  @override
  void dispose() {
    GameReaderCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  void startGame(ContentDataDto? contentData) {}

  @override
  void closeGame(ContentDataDto? contentData) {}

  @override
  void finishGame(ContentDataDto? contentData, Map<String?, Object?>? result) {}

  @override
  void eventGame(ContentDataDto? contentData, String? gameId, String? eventName,
      Map<String?, Object?>? payload) {}

  @override
  void gameError(ContentDataDto? contentData, String? message) {}
}
