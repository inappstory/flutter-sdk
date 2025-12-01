import '../data/goods_item_data.dart';
import '../generated/pigeon_generated.g.dart'
    show GoodsItemDataDto, SkusCallbackFlutterApi;

typedef SkusCallbackImpl = Future<List<GoodsItemData>> Function(
    List<String> skus);

class GoodsCallbackFlutterApiImpl implements SkusCallbackFlutterApi {
  SkusCallbackImpl? _callback;

  set callback(SkusCallbackImpl? value) {
    _callback = value;
  }

  @override
  Future<List<GoodsItemDataDto>> getSkus(List<String> strings) async {
    if (_callback == null) {
      return [];
    }
    final data = await _callback!.call(strings);

    final result = <GoodsItemDataDto>[];
    for (var element in data) {
      result.add(element.toDto());
    }

    return result;
  }
}
