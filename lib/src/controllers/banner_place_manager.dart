import '../generated/banner_place_generated.g.dart'
    show BannerPlaceManagerHostApi;

class BannerPlaceManager {
  BannerPlaceManager._private();

  final _bannerPlaceManagerApi = BannerPlaceManagerHostApi();

  static final instance = BannerPlaceManager._private();

  Future<void> load(String placeId) async {
    await _bannerPlaceManagerApi.loadBannerPlace(placeId);
  }

  Future<void> showNext(String placeId) async {
    await _bannerPlaceManagerApi.showNext(placeId);
  }

  Future<void> showPrevious(String placeId) async {
    await _bannerPlaceManagerApi.showPrevious(placeId);
  }

  Future<void> showByIndex({
    required String placeId,
    required int index,
  }) async {
    await _bannerPlaceManagerApi.showByIndex(placeId, index);
  }

  Future<void> pauseAutoscroll(String placeId) async {
    await _bannerPlaceManagerApi.pauseAutoscroll(placeId);
  }

  Future<void> resumeAutoscroll(String placeId) async {
    await _bannerPlaceManagerApi.resumeAutoscroll(placeId);
  }

  Future<void> preloadBannerPlace(String placeId) async {
    await _bannerPlaceManagerApi.preloadBannerPlace(placeId);
  }
}
