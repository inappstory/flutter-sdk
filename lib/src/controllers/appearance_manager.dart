import 'dart:ui';

import '../data/data.dart' show GoodsItemAppearance;
import '../generated/pigeon_generated.g.dart'
    show AppearanceManagerHostApi, Position, CoverQuality;

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
    GoodsItemAppearance itemAppearance,
  ) async {
    await _appearanceManager.setUpGoods(itemAppearance.toDto());
  }

  Future<void> setCoverQuality(CoverQuality coverQuality) async {
    await _appearanceManager.setCoverQuality(coverQuality);
  }
}
