import 'dart:ui';

import 'package:meta/meta.dart';

import '../pigeon_generated.g.dart' show GoodsItemAppearanceDto;

class GoodsItemAppearance {
  final Color? itemBackgroundColor;
  final int? itemCornerRadius;
  final Color? itemMainTextColor;
  final Color? itemOldPriceTextColor;
  final int? itemTitleTextSize;
  final int? itemDescriptionTextSize;
  final int? itemPriceTextSize;
  final int? itemOldPriceTextSize;
  final Color? widgetBackgroundColor;
  final int? widgetBackgroundHeight;
  final String? closeButtonImage;
  final Color? closeButtonColor;

  GoodsItemAppearance({
    this.itemBackgroundColor,
    this.itemCornerRadius,
    this.itemMainTextColor,
    this.itemOldPriceTextColor,
    this.itemTitleTextSize,
    this.itemDescriptionTextSize,
    this.itemPriceTextSize,
    this.itemOldPriceTextSize,
    this.widgetBackgroundColor,
    this.widgetBackgroundHeight,
    this.closeButtonColor,
    this.closeButtonImage,
  });

  @protected
  GoodsItemAppearanceDto toDto() {
    return GoodsItemAppearanceDto(
      itemBackgroundColor: itemBackgroundColor?.toARGB32(),
      itemCornerRadius: itemCornerRadius,
      itemDescriptionTextSize: itemDescriptionTextSize,
      itemMainTextColor: itemMainTextColor?.toARGB32(),
      itemOldPriceTextColor: itemOldPriceTextColor?.toARGB32(),
      itemOldPriceTextSize: itemOldPriceTextSize,
      itemPriceTextSize: itemPriceTextSize,
      itemTitleTextSize: itemTitleTextSize,
      widgetBackgroundColor: widgetBackgroundColor?.toARGB32(),
      widgetBackgroundHeight: widgetBackgroundHeight,
      closeButtonColor: closeButtonColor?.toARGB32(),
      closeButtonImage: closeButtonImage,
    );
  }
}
