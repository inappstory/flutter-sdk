import 'dart:ui';

import 'package:meta/meta.dart';

import '../data/data.dart' show GoodsItemAppearance, PlaceholderDecoration;
import '../generated/appearance_manager.g.dart'
    show
        AppearanceManagerHostApi,
        Position,
        CoverQuality,
        ScrollStyle,
        PresentationStyle;

export '../generated/appearance_manager.g.dart' show
    Position,
    CoverQuality,
    ScrollStyle,
    PresentationStyle;

/// Configures the look and behaviour of the story reader and SDK widgets.
///
/// Settings are global. Apply them through [AppearanceManager.instance],
/// usually right after the SDK is initialized.
class AppearanceManager {
  AppearanceManager._private([AppearanceManagerHostApi? api])
      : _appearanceManager = api ?? AppearanceManagerHostApi();

  final AppearanceManagerHostApi _appearanceManager;

  /// The shared instance used by the app.
  static final instance = AppearanceManager._private();

  /// Creates a manager backed by a custom [api], for use in tests.
  @visibleForTesting
  factory AppearanceManager.forTesting(AppearanceManagerHostApi api) =>
      AppearanceManager._private(api);

  /// Shows the "add to favorites" button in the reader if [value] is `true`.
  Future<void> setHasFavorites(bool value) async {
    await _appearanceManager.setHasFavorites(value);
  }

  /// Shows the like and dislike buttons in the reader if [value] is `true`.
  Future<void> setHasLike(bool value) async {
    await _appearanceManager.setHasLike(value);
  }

  /// Shows the share button in the reader if [value] is `true`.
  Future<void> setHasShare(bool value) async {
    await _appearanceManager.setHasShare(value);
  }

  /// Enables or disables the gradient behind the reader's timer bar.
  Future<void> setTimerGradientEnable(bool isEnabled) async {
    await _appearanceManager.setTimerGradientEnable(isEnabled);
  }

  /// Returns whether the gradient behind the reader's timer bar is enabled.
  Future<bool> getTimerGradientEnable() async {
    return await _appearanceManager.getTimerGradientEnable();
  }

  /// Sets the gradient shown behind the reader's timer bar.
  ///
  /// [colors] are ARGB color values. [locations] are optional stops from
  /// `0.0` to `1.0`; they are used only if there are as many as [colors].
  Future<void> setTimerGradient({
    required List<int> colors,
    List<double> locations = const [],
  }) async {
    await _appearanceManager.setTimerGradient(
        colors: colors, locations: locations);
  }

  /// Sets the background [color] of the story reader.
  Future<void> setReaderBackgroundColor(Color color) async {
    await _appearanceManager.setReaderBackgroundColor(color.toARGB32());
  }

  /// Sets the corner [radius] of the story reader, in logical pixels.
  Future<void> setReaderCornerRadius(int radius) async {
    await _appearanceManager.setReaderCornerRadius(radius);
  }

  /// Sets which corner of the reader shows the close button.
  Future<void> setClosePosition(Position position) async {
    await _appearanceManager.setClosePosition(position);
  }

  /// Replaces the like button icons.
  ///
  /// [iconPath] and [selectedIconPath] are Flutter asset paths for the
  /// default and selected states. Does nothing if both are empty.
  Future<void> setLikeIcon(String iconPath, String selectedIconPath) async {
    if ((iconPath.isEmpty) && (selectedIconPath.isEmpty)) {
      return;
    }
    await _appearanceManager.setLikeIcon(iconPath, selectedIconPath);
  }

  /// Replaces the dislike button icons.
  ///
  /// [iconPath] and [selectedIconPath] are Flutter asset paths for the
  /// default and selected states.
  Future<void> setDislikeIcon(String iconPath, String selectedIconPath) async {
    await _appearanceManager.setDislikeIcon(iconPath, selectedIconPath);
  }

  /// Replaces the favorite button icons.
  ///
  /// [iconPath] and [selectedIconPath] are Flutter asset paths for the
  /// default and selected states.
  Future<void> setFavoriteIcon(String iconPath, String selectedIconPath) async {
    await _appearanceManager.setFavoriteIcon(iconPath, selectedIconPath);
  }

  /// Replaces the share button icons.
  ///
  /// [iconPath] and [selectedIconPath] are Flutter asset paths for the
  /// default and pressed states.
  Future<void> setShareIcon(String iconPath, String selectedIconPath) async {
    await _appearanceManager.setShareIcon(iconPath, selectedIconPath);
  }

  /// Replaces the reader's close button icon with the asset at [iconPath].
  Future<void> setCloseIcon(String iconPath) async {
    await _appearanceManager.setCloseIcon(iconPath);
  }

  /// Replaces the sound toggle icons.
  ///
  /// [iconPath] and [selectedIconPath] are Flutter asset paths for the
  /// default and selected states.
  Future<void> setSoundIcon(String iconPath, String selectedIconPath) async {
    await _appearanceManager.setSoundIcon(iconPath, selectedIconPath);
  }

  /// Sets how goods items and the goods widget look in stories.
  Future<void> setGoodsItemAppearance(
    GoodsItemAppearance itemAppearance,
  ) async {
    await _appearanceManager.setUpGoods(itemAppearance.toDto());
  }

  /// Sets the image quality of story covers in feeds.
  Future<void> setCoverQuality(CoverQuality coverQuality) async {
    await _appearanceManager.setCoverQuality(coverQuality);
  }

  /// Sets the animation used when swiping between stories in the reader.
  Future<void> setReaderScrollStyle(ScrollStyle style) async {
    await _appearanceManager.setReaderScrollStyle(style);
  }

  /// Sets the animation used when opening and closing the reader.
  Future<void> setReaderPresentationStyle(PresentationStyle style) async {
    await _appearanceManager.setReaderPresentationStyle(style);
  }

  /// Sets the system navigation bar color while the reader is open.
  ///
  /// [darkColor] is used in dark mode. Android only; does nothing on iOS.
  Future<void> setNavBarColor(Color color, {Color? darkColor}) async {
    await _appearanceManager.setNavBarColor(
        color.toARGB32(), darkColor?.toARGB32());
  }

  /// Sets the loading placeholder shown while story covers are loading.
  ///
  /// Pass a [decoration], or a background [color] and/or an asset [image] as
  /// a shortcut; [decoration] takes precedence. Pass no arguments to restore
  /// the default SDK placeholder.
  Future<void> setStoriesPlaceholder({
    PlaceholderDecoration? decoration,
    Color? color,
    String? image,
  }) async {
    await _appearanceManager.setStoriesPlaceholder(
        _resolvePlaceholder(decoration, color, image)?.toDto());
  }

  /// Sets the loading placeholder shown while banner content is loading.
  ///
  /// Applies globally to every `BannerPlace` and `BannerGrid`, so call it once
  /// after `initWith` and before banners are created. Pass no arguments to
  /// restore the default SDK loader.
  ///
  /// On iOS the placeholder is used by the banner carousel only: the native SDK
  /// always shows its standard per-cell loader in a grid. On Android it applies
  /// to both the carousel and the grid.
  Future<void> setBannersPlaceholder({
    PlaceholderDecoration? decoration,
    Color? color,
    String? image,
  }) async {
    await _appearanceManager.setBannersPlaceholder(
        _resolvePlaceholder(decoration, color, image)?.toDto());
  }

  PlaceholderDecoration? _resolvePlaceholder(
    PlaceholderDecoration? decoration,
    Color? color,
    String? image,
  ) =>
      decoration ??
      ((color != null || image != null)
          ? PlaceholderDecoration(color: color, image: image)
          : null);
}
