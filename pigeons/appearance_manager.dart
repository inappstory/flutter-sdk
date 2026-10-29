import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/appearance_manager.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/AppearanceManagerGenerated.g.kt',
  kotlinOptions: KotlinOptions(
    includeErrorClass: false,
  ),
  swiftOut:
      'ios/inappstory_plugin/Sources/inappstory_plugin/AppearanceManagerGenerated.g.swift',
  swiftOptions: SwiftOptions(
    includeErrorClass: false,
  ),
))
// ConfigurePigeon

enum Position {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

enum CoverQuality { medium, high }

enum ScrollStyle { flat, cover, cube }

enum PresentationStyle { zoom, modal, fade }

class GoodsItemAppearanceDto {
  late int? itemBackgroundColor;
  late int? itemCornerRadius;
  late int? itemMainTextColor;
  late int? itemOldPriceTextColor;
  late int? itemTitleTextSize;
  late int? itemDescriptionTextSize;
  late int? itemPriceTextSize;
  late int? itemOldPriceTextSize;
  late int? widgetBackgroundColor;
  late String? closeButtonImage;
  late int? closeButtonColor;
  late int? widgetBackgroundHeight;
}

class GoodsItemDataDto {
  late String? sku;
  late String? title;
  late String? productDescription;
  late String? image;
  late String? price;
  late String? oldPrice;
}

class PlaceholderDecorationDto {
  late int? color;
  late String? image;
}

@HostApi()
abstract class AppearanceManagerHostApi {
  void setHasLike(bool value);

  void setHasFavorites(bool value);

  void setHasShare(bool value);

  void setClosePosition(Position position);

  void setTimerGradientEnable(bool isEnabled);

  bool getTimerGradientEnable();

  void setTimerGradient(
      {required List<int> colors, List<double> locations = const []});

  void setReaderBackgroundColor(int color);

  void setReaderCornerRadius(int radius);

  void setLikeIcon(String iconPath, String selectedIconPath);

  void setDislikeIcon(String iconPath, String selectedIconPath);

  void setFavoriteIcon(String iconPath, String selectedIconPath);

  void setShareIcon(String iconPath, String selectedIconPath);

  void setCloseIcon(String iconPath);

  void setRefreshIcon(String iconPath);

  void setSoundIcon(String iconPath, String selectedIconPath);

  void setUpGoods(GoodsItemAppearanceDto appearance);

  void setCoverQuality(CoverQuality coverQuality);

  void setReaderScrollStyle(ScrollStyle style);

  void setReaderPresentationStyle(PresentationStyle style);

  void setNavBarColor(int color, int? darkColor);

  void setStoriesPlaceholder(PlaceholderDecorationDto? decoration);

  void setBannersPlaceholder(PlaceholderDecorationDto? decoration);
}

@FlutterApi()
abstract class SkusCallbackFlutterApi {
  @asyncCallback
  List<GoodsItemDataDto> getSkus(List<String> strings);
}

@FlutterApi()
abstract class GoodsItemSelectedCallbackFlutterApi {
  @asyncCallback
  void goodsItemSelected(GoodsItemDataDto item);
}
