import 'package:flutter/widgets.dart';

import '../generated/pigeon_generated.g.dart' show IShowStoryCallbackFlutterApi;

mixin IASShowStoryCallback<T extends StatefulWidget> on State<T>
    implements IShowStoryCallbackFlutterApi {
  @override
  void initState() {
    super.initState();
    IShowStoryCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    IShowStoryCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  Future<void> alreadyShown() async {}

  @override
  Future<void> onError() async {}

  @override
  Future<void> onShow() async {}
}
