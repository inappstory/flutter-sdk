import '../generated/banner_place_generated.g.dart'
    show BannerPlaceManagerHostApi;

class BannerPlaceManager {
  BannerPlaceManager._private();

  final _bannerPlaceManagerApi = BannerPlaceManagerHostApi();

  static final instance = BannerPlaceManager._private();

  Future<void> load(String placeId, {List<String>? tags}) async {
    await _bannerPlaceManagerApi.loadBannerPlace(placeId, tags: tags);
  }

  Future<void> showNext() async {
    await _bannerPlaceManagerApi.showNext();
  }

  Future<void> showPrevious() async {
    await _bannerPlaceManagerApi.showPrevious();
  }

  Future<void> showByIndex(int index) async {
    await _bannerPlaceManagerApi.showByIndex(index);
  }

  Future<void> pauseAutoscroll() async {
    await _bannerPlaceManagerApi.pauseAutoscroll();
  }

  Future<void> resumeAutoscroll() async {
    await _bannerPlaceManagerApi.resumeAutoscroll();
  }
}
