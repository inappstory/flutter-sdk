import 'package:flutter/widgets.dart';

import '../../inappstory_plugin.dart'
    show IASInAppMessagesCallbacksFlutterApi, InAppMessageDataDto;

mixin IASInAppMessageCallback<T extends StatefulWidget> on State<T>
    implements IASInAppMessagesCallbacksFlutterApi {
  @override
  void initState() {
    super.initState();
    IASInAppMessagesCallbacksFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    IASInAppMessagesCallbacksFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  void onShowInAppMessage(InAppMessageDataDto? inAppMessageData) {}

  @override
  void onCloseInAppMessage(InAppMessageDataDto? inAppMessageData) {}

  @override
  void onInAppMessageWidgetEvent(InAppMessageDataDto? inAppMessageData,
      String? name, Map<String?, Object?>? data) {}
}
