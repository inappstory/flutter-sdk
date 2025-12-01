import 'package:flutter/widgets.dart';

import '../generated/pigeon_generated.g.dart'
    show IASInAppMessagesCallbacksFlutterApi, InAppMessageDataDto;

/// A mixin that provides callback methods for handling in-app message events
/// in the InAppStory plugin.
///
/// This mixin is intended to be used with a `State` class of a `StatefulWidget`.
mixin IASInAppMessageCallback<T extends StatefulWidget> on State<T>
    implements IASInAppMessagesCallbacksFlutterApi {
  /// Sets up the callbacks by registering this mixin instance
  @override
  void initState() {
    super.initState();
    IASInAppMessagesCallbacksFlutterApi.setUp(this);
  }

  /// Removes the callbacks by unregistering this mixin instance
  @override
  void dispose() {
    IASInAppMessagesCallbacksFlutterApi.setUp(null);
    super.dispose();
  }

  /// Called when an in-app message is shown.
  ///
  /// [inAppMessageData] - Data about the in-app message being shown, or `null` if unavailable.
  @override
  void onShowInAppMessage(InAppMessageDataDto? inAppMessageData) {}

  /// Called when an in-app message is closed.
  ///
  /// [inAppMessageData] - Data about the in-app message being closed, or `null` if unavailable.
  @override
  void onCloseInAppMessage(InAppMessageDataDto? inAppMessageData) {}

  /// Called when a widget event occurs in an in-app message.
  ///
  /// [inAppMessageData] - Data about the in-app message where the widget event occurred, or `null` if unavailable.
  /// [name] - The name of the widget event, or `null` if unavailable.
  /// [data] - Additional data associated with the widget event, or `null` if unavailable.
  @override
  void onInAppMessageWidgetEvent(InAppMessageDataDto? inAppMessageData,
      String? name, Map<String?, Object?>? data) {}
}
