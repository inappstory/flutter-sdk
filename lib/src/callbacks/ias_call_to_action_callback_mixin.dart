import 'package:flutter/widgets.dart';

import '../generated/pigeon_generated.g.dart'
    show CallToActionCallbackFlutterApi, SlideDataDto, ClickActionDto;

mixin IASCallToActionCallback<T extends StatefulWidget> on State<T>
    implements CallToActionCallbackFlutterApi {
  /// Sets up the callbacks by registering this mixin instance
  @override
  void initState() {
    super.initState();
    CallToActionCallbackFlutterApi.setUp(this);
  }

  /// Removes the callbacks by unregistering this mixin instance
  @override
  void dispose() {
    CallToActionCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  void callToAction(
      SlideDataDto? slideData, String? url, ClickActionDto? clickAction) {}
}
