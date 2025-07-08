import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/appearance_manager.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/generated/AppearanceManagerGenerated.g.kt',
  kotlinOptions: KotlinOptions(
    includeErrorClass: false,
  ),
  swiftOut: 'ios/Classes/Generated/AppearanceManagerGenerated.g.swift',
  swiftOptions: SwiftOptions(
    includeErrorClass: false,
  ),
))
enum Position {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
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

  void setSoundIcon(String iconPath, String selectedIconPath);
//
// void setRefreshIcon();
//
}
