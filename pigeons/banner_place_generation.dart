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
// BannerPlaceManagerHostApi
@HostApi()
abstract class BannerPlaceManagerHostApi {
  void loadBannerPlace(String placeId);

  void reloadBannerPlace(String placeId);

  void preloadBannerPlace(String placeId);

  void showNext(String placeId);

  void showPrevious(String placeId);

  void showByIndex(String placeId, int index);

  void pauseAutoscroll(String placeId);

  void resumeAutoscroll(String placeId);
}

class BannerPlaceDecoration {
  late int bannerOffset;
  late int bannersGap;
  late int cornerRadius;
  late bool loop;
}

@FlutterApi()
abstract class BannerPlaceCallbackFlutterApi {
  void onBannerScroll(String placeId, int index);

  void onBannerPlaceLoaded(String placeId, int size, int widgetHeight);

  void onActionWith(BannerData bannerData, String widgetEventName,
      Map<String, Object?>? widgetData);

  void onBannerPlacePreloaded(String placeId);

  void onBannerPlacePreloadedError(String placeId);
}

@FlutterApi()
abstract class BannerLoadCallbackFlutterApi {
  void onBannersLoaded(int size, int widgetHeight);
}

@HostApi()
abstract class BannerViewHostApi {
  void changeBannerPlaceId(String newPlaceId);
  void deInitBannerPlace();
}

enum GradientType {
  linear,
  radial,
  sweep,
}

class BannerDecorationDTO {
  late int? color;
  late String? image;
}

class BannerData {
  late String? id;
  late String? bannerPlace;
  late String? payload;
}
