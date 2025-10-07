import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/banner_place_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/BannerPlaceGenerated.g.kt',
  kotlinOptions: KotlinOptions(includeErrorClass: false),
  swiftOut: 'ios/Classes/BannerPlaceGenerated.g.swift',
  swiftOptions: SwiftOptions(includeErrorClass: false),
))
@HostApi()
abstract class BannerPlaceManagerHostApi {
  void loadBannerPlace(String placeId, {List<String>? tags});

  void preloadBannerPlace(String placeId, {List<String>? tags});

  void showNext();

  void showPrevious();

  void showByIndex(int index);

  void pauseAutoscroll();

  void resumeAutoscroll();
}

class BannerPlaceDecoration {
  late int bannerOffset;
  late int bannersGap;
  late int cornerRadius;
  late bool loop;
}

@FlutterApi()
abstract class BannerPlaceCallbackFlutterApi {
  void onBannerScroll(int index);

  void onBannerPlaceLoaded(int size, int widgetHeight);

  void onActionWith(String target);

  void onBannerPlacePreloaded(int size);
}

@FlutterApi()
abstract class BannerLoadCallbackFlutterApi {
  void onBannersLoaded(int size, int widgetHeight);
}

enum GradientType {
  linear,
  radial,
  sweep,
}

class BannerDecorationDTO {
  late int? color;
  late String? image;
  late GradientType? gradientType;
  late List<int>? gradientColors;
  late List<double>? gradientStops;
}
