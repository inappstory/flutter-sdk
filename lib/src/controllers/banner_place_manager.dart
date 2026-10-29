import '../generated/banner_place_generated.g.dart'
    show BannerPlaceManagerHostApi;

/// Controls banner places (`BannerPlace` and `BannerGrid` widgets) by ID.
///
/// Every method takes the `placeId` of the banner place it applies to.
class BannerPlaceManager {
  BannerPlaceManager._private();

  final _bannerPlaceManagerApi = BannerPlaceManagerHostApi();

  /// The shared instance used by the app.
  static final instance = BannerPlaceManager._private();

  /// Loads the banners of the banner place [placeId].
  Future<void> load(String placeId) =>
      _bannerPlaceManagerApi.loadBannerPlace(placeId);

  /// Reloads the banners of the banner place [placeId] from the server.
  Future<void> reload(String placeId) =>
      _bannerPlaceManagerApi.reloadBannerPlace(placeId);

  /// Scrolls the banner place [placeId] to the next banner.
  Future<void> showNext(String placeId) =>
      _bannerPlaceManagerApi.showNext(placeId);

  /// Scrolls the banner place [placeId] to the previous banner.
  Future<void> showPrevious(String placeId) =>
      _bannerPlaceManagerApi.showPrevious(placeId);

  /// Scrolls the banner place [placeId] to the banner at [index].
  Future<void> showByIndex({
    required String placeId,
    required int index,
  }) =>
      _bannerPlaceManagerApi.showByIndex(placeId, index);

  /// Pauses automatic scrolling of the banner place [placeId].
  Future<void> pauseAutoscroll(String placeId) =>
      _bannerPlaceManagerApi.pauseAutoscroll(placeId);

  /// Resumes automatic scrolling of the banner place [placeId].
  Future<void> resumeAutoscroll(String placeId) =>
      _bannerPlaceManagerApi.resumeAutoscroll(placeId);

  /// Preloads the banners of the banner place [placeId] before it is shown,
  /// so they appear without a loading delay.
  Future<void> preloadBannerPlace(String placeId) =>
      _bannerPlaceManagerApi.preloadBannerPlace(placeId);

  /// Enables or disables user interaction (taps and swipes) with the banner
  /// place [placeId].
  ///
  /// Interaction is enabled if [isInteractionEnabled] is `true`.
  Future<void> setInteraction({
    required String placeId,
    required bool isInteractionEnabled,
  }) =>
      _bannerPlaceManagerApi.setInteraction(placeId, isInteractionEnabled);
}
