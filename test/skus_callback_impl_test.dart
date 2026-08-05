// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/callbacks/ias_skus_callback_impl.dart';
import 'package:inappstory_plugin/src/data/goods_item_data.dart';

void main() {
  group('$GoodsCallbackFlutterApiImpl', () {
    group('GIVEN no callback', () {
      late GoodsCallbackFlutterApiImpl impl;
      setUp(() {
        impl = GoodsCallbackFlutterApiImpl();
      });

      test('WHEN getSkus called THEN returns empty list', () async {
        final result = await impl.getSkus(['sku1']);
        expect(result, isEmpty);
      });
    });

    group('GIVEN callback set', () {
      late GoodsCallbackFlutterApiImpl impl;
      late List<String> receivedSkus;

      setUp(() {
        impl = GoodsCallbackFlutterApiImpl();
        receivedSkus = [];
        impl.callback = (skus) async {
          receivedSkus = skus;
          return [
            const GoodsItemData(sku: 'sku1', title: 'Title1'),
          ];
        };
      });

      test('WHEN getSkus called THEN returns converted DTOs', () async {
        final result = await impl.getSkus(['sku1']);
        expect(result, isNotEmpty);
        expect(result.first.sku, 'sku1');
      });

      test('WHEN getSkus called with specific skus THEN callback receives those skus', () async {
        await impl.getSkus(['sku1', 'sku2']);
        expect(receivedSkus, ['sku1', 'sku2']);
      });
    });
  });
}
