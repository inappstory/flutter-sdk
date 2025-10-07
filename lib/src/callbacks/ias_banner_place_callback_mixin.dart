import 'package:flutter/widgets.dart';

import '../generated/banner_place_generated.g.dart';

mixin IASBannerPlaceCallback<T extends StatefulWidget> on State<T>
    implements BannerPlaceCallbackFlutterApi {
  @override
  void initState() {
    super.initState();
    BannerPlaceCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    BannerPlaceCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  void onBannerScroll(int index) {}

  @override
  void onBannerPlaceLoaded(int size, int widgetHeight) {}

  @override
  void onActionWith(String target) {}

  @override
  void onBannerPlacePreloaded(int size) {}
}
