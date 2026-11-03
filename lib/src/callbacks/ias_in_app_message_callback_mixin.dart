import 'package:flutter/widgets.dart';

import '../data/in_app_message_data.dart';
import '../generated/pigeon_generated.g.dart'
    show IASInAppMessagesCallbacksFlutterApi, InAppMessageDataDto;

/// A mixin that provides callback methods for handling in-app message events
/// in the InAppStory plugin.
///
/// This mixin is intended to be used with a `State` class of a `StatefulWidget`.
mixin IASInAppMessageCallback<T extends StatefulWidget> on State<T> {
  _IASInAppMessagesBridge? _bridge;

  /// Sets up the callbacks by registering this mixin instance
  @override
  void initState() {
    super.initState();
    _bridge = _IASInAppMessagesBridge(this);
    IASInAppMessagesCallbacksFlutterApi.setUp(_bridge);
  }

  /// Removes the callbacks by unregistering this mixin instance
  @override
  void dispose() {
    IASInAppMessagesCallbacksFlutterApi.setUp(null);
    _bridge = null;
    super.dispose();
  }

  /// Called when an in-app message is shown.
  ///
  /// [inAppMessageData] - Data about the in-app message being shown, or `null` if unavailable.
  Future<void> onShowInAppMessage(InAppMessageData? inAppMessageData) async {}

  /// Called when an in-app message is closed.
  ///
  /// [inAppMessageData] - Data about the in-app message being closed, or `null` if unavailable.
  Future<void> onCloseInAppMessage(InAppMessageData? inAppMessageData) async {}

  /// Called when a widget event occurs in an in-app message.
  ///
  /// [inAppMessageData] - Data about the in-app message where the widget event occurred, or `null` if unavailable.
  /// [name] - The name of the widget event, or `null` if unavailable.
  /// [data] - Additional data associated with the widget event, or `null` if unavailable.
  Future<void> onInAppMessageWidgetEvent(InAppMessageData? inAppMessageData,
      String? name, Map<String?, Object?>? data) async {}
}

class _IASInAppMessagesBridge implements IASInAppMessagesCallbacksFlutterApi {
  _IASInAppMessagesBridge(this._target);

  final IASInAppMessageCallback _target;

  @override
  Future<void> onShowInAppMessage(InAppMessageDataDto? inAppMessageData) {
    return _target.onShowInAppMessage(
      inAppMessageData == null
          ? null
          : InAppMessageData.fromDto(inAppMessageData),
    );
  }

  @override
  Future<void> onCloseInAppMessage(InAppMessageDataDto? inAppMessageData) {
    return _target.onCloseInAppMessage(
      inAppMessageData == null
          ? null
          : InAppMessageData.fromDto(inAppMessageData),
    );
  }

  @override
  Future<void> onInAppMessageWidgetEvent(
      InAppMessageDataDto? inAppMessageData, String? name, Map<String?, Object?>? data) {
    return _target.onInAppMessageWidgetEvent(
      inAppMessageData == null
          ? null
          : InAppMessageData.fromDto(inAppMessageData),
      name,
      data,
    );
  }
}
