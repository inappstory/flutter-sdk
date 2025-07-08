import 'dart:ui';

import 'package:meta/meta.dart';

import '../pigeon_generated.g.dart'
    show AppearanceManagerHostApi, Position, GoodsItemAppearanceDto;

class AppearanceManager {
  AppearanceManager._private();

  final _appearanceManager = AppearanceManagerHostApi();

  static final instance = AppearanceManager._private();

  Future<void> setHasFavorites(bool value) async {
    await _appearanceManager.setHasFavorites(value);
  }

  Future<void> setHasLike(bool value) async {
    await _appearanceManager.setHasLike(value);
  }

  Future<void> setHasShare(bool value) async {
    await _appearanceManager.setHasShare(value);
  }

  Future<void> setTimerGradientEnable(bool isEnabled) async {
    await _appearanceManager.setTimerGradientEnable(isEnabled);
  }

  Future<bool> getTimerGradientEnable() async {
    return await _appearanceManager.getTimerGradientEnable();
  }

  Future<void> setTimerGradient({
    required List<int> colors,
    List<double> locations = const [],
  }) async {
    await _appearanceManager.setTimerGradient(
        colors: colors, locations: locations);
  }

  Future<void> setReaderBackgroundColor(Color color) async {
    await _appearanceManager.setReaderBackgroundColor(color.toARGB32());
  }

  Future<void> setReaderCornerRadius(int radius) async {
    await _appearanceManager.setReaderCornerRadius(radius);
  }

  Future<void> setClosePosition(Position position) async {
    await _appearanceManager.setClosePosition(position);
  }

  Future<void> setLikeIcon(String iconPath, String selectedIconPath) async {
    if ((iconPath.isEmpty) && (selectedIconPath.isEmpty)) {
      return;
    }
    await _appearanceManager.setLikeIcon(iconPath, selectedIconPath);
  }

  Future<void> setDislikeIcon(String iconPath, String selectedIconPath) async {
    await _appearanceManager.setDislikeIcon(iconPath, selectedIconPath);
  }

  Future<void> setFavoriteIcon(String iconPath, String selectedIconPath) async {
    await _appearanceManager.setFavoriteIcon(iconPath, selectedIconPath);
  }

  Future<void> setShareIcon(String iconPath, String selectedIconPath) async {
    await _appearanceManager.setShareIcon(iconPath, selectedIconPath);
  }

  Future<void> setCloseIcon(String iconPath) async {
    await _appearanceManager.setCloseIcon(iconPath);
  }

  Future<void> setSoundIcon(String iconPath, String selectedIconPath) async {
    await _appearanceManager.setSoundIcon(iconPath, selectedIconPath);
  }

  Future<void> setGoodsItemAppearance(
      GoodsItemAppearance itemAppearance) async {
    await _appearanceManager.setUpGoods(itemAppearance.toDto());
  }
}

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
