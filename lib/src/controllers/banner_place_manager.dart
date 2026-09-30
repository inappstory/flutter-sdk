import '../generated/banner_place_generated.g.dart'
    show BannerPlaceManagerHostApi;

class BannerPlaceManager {
  BannerPlaceManager._private();

  final _bannerPlaceManagerApi = BannerPlaceManagerHostApi();

  static final instance = BannerPlaceManager._private();

  Future<void> load(String placeId) =>
      _bannerPlaceManagerApi.loadBannerPlace(placeId);

  Future<void> reload(String placeId) =>
      _bannerPlaceManagerApi.reloadBannerPlace(placeId);

  Future<void> showNext(String placeId) =>
      _bannerPlaceManagerApi.showNext(placeId);

  Future<void> showPrevious(String placeId) =>
      _bannerPlaceManagerApi.showPrevious(placeId);

  Future<void> showByIndex({
    required String placeId,
    required int index,
  }) =>
      _bannerPlaceManagerApi.showByIndex(placeId, index);

  Future<void> pauseAutoscroll(String placeId) =>
      _bannerPlaceManagerApi.pauseAutoscroll(placeId);

  Future<void> resumeAutoscroll(String placeId) =>
      _bannerPlaceManagerApi.resumeAutoscroll(placeId);

  Future<void> preloadBannerPlace(String placeId) =>
      _bannerPlaceManagerApi.preloadBannerPlace(placeId);

  Future<void> setInteraction({
    required String placeId,
    required bool isInteractionEnabled,
  }) =>
      _bannerPlaceManagerApi.setInteraction(placeId, isInteractionEnabled);
}

