import 'package:flutter/widgets.dart';

import '../data/story_data.dart';
import '../generated/pigeon_generated.g.dart'
    show CallToActionCallbackFlutterApi, SlideDataDto, ClickActionDto;

mixin IASCallToActionCallback<T extends StatefulWidget> on State<T> {
  _IASCallToActionBridge? _bridge;

  /// Sets up the callbacks by registering this mixin instance
  @override
  void initState() {
    super.initState();
    _bridge = _IASCallToActionBridge(this);
    CallToActionCallbackFlutterApi.setUp(_bridge);
  }

  /// Removes the callbacks by unregistering this mixin instance
  @override
  void dispose() {
    CallToActionCallbackFlutterApi.setUp(null);
    _bridge = null;
    super.dispose();
  }

  Future<void> callToAction(
      SlideData? slideData, String? url, ClickAction? clickAction) async {}
}

class _IASCallToActionBridge implements CallToActionCallbackFlutterApi {
  _IASCallToActionBridge(this._target);

  final IASCallToActionCallback _target;

  @override
  Future<void> callToAction(
      SlideDataDto? slideData, String? url, ClickActionDto? clickAction) {
    return _target.callToAction(
      slideData == null ? null : SlideData.fromDto(slideData),
      url,
      clickAction == null ? null : ClickAction.fromDto(clickAction),
    );
  }
}
