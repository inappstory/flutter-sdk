import 'package:flutter/widgets.dart';

import '../data/goods_item_data.dart';
import '../generated/appearance_manager.g.dart'
    show GoodsItemDataDto, GoodsItemSelectedCallbackFlutterApi;

mixin IASGoodItemSelectedCallback<T extends StatefulWidget> on State<T> {
  _IASGoodItemSelectedBridge? _bridge;

  @override
  void initState() {
    super.initState();
    _bridge = _IASGoodItemSelectedBridge(this);
    GoodsItemSelectedCallbackFlutterApi.setUp(_bridge);
  }

  @override
  void dispose() {
    GoodsItemSelectedCallbackFlutterApi.setUp(null);
    _bridge = null;
    super.dispose();
  }

  Future<void> goodsItemSelected(GoodsItemData item) async {}
}

class _IASGoodItemSelectedBridge implements GoodsItemSelectedCallbackFlutterApi {
  _IASGoodItemSelectedBridge(this._target);

  final IASGoodItemSelectedCallback _target;

  @override
  Future<void> goodsItemSelected(GoodsItemDataDto item) {
    return _target.goodsItemSelected(GoodsItemData.fromDto(item));
  }
}
