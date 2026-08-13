// ignore_for_file: invalid_use_of_protected_member
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/data/goods_item_appearance.dart';

void main() {
  group('$GoodsItemAppearance', () {
    group('WHEN toDto called with all fields null', () {
      test('THEN color fields stay null', () {
        final dto = GoodsItemAppearance().toDto();

        expect(dto.itemBackgroundColor, isNull);
        expect(dto.itemMainTextColor, isNull);
        expect(dto.itemOldPriceTextColor, isNull);
        expect(dto.widgetBackgroundColor, isNull);
        expect(dto.closeButtonColor, isNull);
      });
    });

    group('WHEN toDto called with colors set', () {
      test('THEN each color is converted to its ARGB32 int', () {
        final dto = GoodsItemAppearance(
          itemBackgroundColor: const Color(0xFFFF0000),
          itemMainTextColor: const Color(0xFF00FF00),
          itemOldPriceTextColor: const Color(0xFF0000FF),
          widgetBackgroundColor: const Color(0x80112233),
          closeButtonColor: const Color(0xFFABCDEF),
        ).toDto();

        expect(dto.itemBackgroundColor, 0xFFFF0000);
        expect(dto.itemMainTextColor, 0xFF00FF00);
        expect(dto.itemOldPriceTextColor, 0xFF0000FF);
        expect(dto.widgetBackgroundColor, 0x80112233);
        expect(dto.closeButtonColor, 0xFFABCDEF);
      });
    });

    group('WHEN toDto called with non-color fields set', () {
      test('THEN they pass through unchanged', () {
        final dto = GoodsItemAppearance(
          itemCornerRadius: 8,
          itemTitleTextSize: 14,
          widgetBackgroundHeight: 200,
          closeButtonImage: 'assets/close.png',
        ).toDto();

        expect(dto.itemCornerRadius, 8);
        expect(dto.itemTitleTextSize, 14);
        expect(dto.widgetBackgroundHeight, 200);
        expect(dto.closeButtonImage, 'assets/close.png');
      });
    });
  });
}
