import 'package:flutter/widgets.dart';

import '../data/game_content_data.dart';
import '../generated/pigeon_generated.g.dart'
    show GameReaderCallbackFlutterApi, ContentDataDto;

mixin IASGameReaderCallback<T extends StatefulWidget> on State<T> {
  _IASGameReaderBridge? _bridge;

  /// Sets up the callbacks by registering this mixin instance
  @override
  void initState() {
    super.initState();
    _bridge = _IASGameReaderBridge(this);
    GameReaderCallbackFlutterApi.setUp(_bridge);
  }

  /// Removes the callbacks by unregistering this mixin instance
  @override
  void dispose() {
    GameReaderCallbackFlutterApi.setUp(null);
    _bridge = null;
    super.dispose();
  }

  Future<void> startGame(ContentData? contentData) async {}

  Future<void> closeGame(ContentData? contentData) async {}

  @Deprecated('Use closeGame instead')
  Future<void> finishGame(ContentData? contentData, Map<String, Object?>? result) async {}

  Future<void> eventGame(ContentData? contentData, String? gameId, String? eventName,
      Map<String, Object?>? payload) async {}

  Future<void> gameError(ContentData? contentData, String? message) async {}
}

class _IASGameReaderBridge implements GameReaderCallbackFlutterApi {
  _IASGameReaderBridge(this._target);

  final IASGameReaderCallback _target;

  @override
  Future<void> startGame(ContentDataDto? contentData) {
    return _target.startGame(
      contentData == null ? null : ContentData.fromDto(contentData),
    );
  }

  @override
  Future<void> closeGame(ContentDataDto? contentData) {
    return _target.closeGame(
      contentData == null ? null : ContentData.fromDto(contentData),
    );
  }

  @override
  Future<void> finishGame(ContentDataDto? contentData, Map<String, Object?>? result) {
    // ignore: deprecated_member_use_from_same_package
    return _target.finishGame(
      contentData == null ? null : ContentData.fromDto(contentData),
      result,
    );
  }

  @override
  Future<void> eventGame(ContentDataDto? contentData, String? gameId, String? eventName,
      Map<String, Object?>? payload) {
    return _target.eventGame(
      contentData == null ? null : ContentData.fromDto(contentData),
      gameId,
      eventName,
      payload,
    );
  }

  @override
  Future<void> gameError(ContentDataDto? contentData, String? message) {
    return _target.gameError(
      contentData == null ? null : ContentData.fromDto(contentData),
      message,
    );
  }
}
