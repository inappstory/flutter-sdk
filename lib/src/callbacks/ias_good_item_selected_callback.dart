import 'package:flutter/widgets.dart';

import '../pigeon_generated.g.dart'
    show GoodsItemDataDto, GoodsItemSelectedCallbackFlutterApi;

mixin IASGoodItemSelectedCallback<T extends StatefulWidget> on State<T>
implements GoodsItemSelectedCallbackFlutterApi {
  @override
  void initState() {
    super.initState();
    GoodsItemSelectedCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    GoodsItemSelectedCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  @override
  void goodsItemSelected(GoodsItemDataDto item) {}
}
