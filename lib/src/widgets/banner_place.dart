import 'base/banner_place_base.dart';

export 'base/banner_place_base.dart' show BannerPlaceState, BannerDecoration;

/// Displays the banners of a banner place as a horizontal carousel.
///
/// The banners are configured in the InAppStory console and controlled with
/// `BannerPlaceManager`.
class BannerPlace extends BannerPlaceBase {
  /// Creates a banner carousel for the banner place [placeId].
  ///
  /// * [placeId]: the ID of the banner place in the InAppStory console.
  /// * [height]: the height of the widget, in logical pixels.
  /// * [autoLoad]: whether banners load when the widget is created. If
  ///   `false`, load them with `BannerPlaceManager.instance.load`.
  /// * [placeDecoration]: the appearance of the carousel.
  /// * [isInteractionEnabled]: whether the user can tap and swipe banners.
  ///   Defaults to `true`.
  /// * [bannerPlaceLoaderBuilder]: builds the widget shown while loading.
  /// * [bannerPlaceErrorBuilder]: builds the widget shown if loading fails.
  /// * [onActionWith]: called when a widget inside a banner sends an event.
  /// * [onBannerScroll]: called with the index of the banner scrolled to.
  /// * [onBannerPlaceLoaded]: called with the number of banners and the
  ///   content height after loading.
  /// * [onBannerPlaceLoadError]: called with the error message if loading
  ///   fails or takes longer than [loadingTimeout].
  /// * [onBannerPlacePreloaded]: called when preloading succeeds.
  /// * [onPreloadedError]: called when preloading fails.
  /// * [hideOnEmpty]: whether the widget is hidden when there are no banners
  ///   or loading fails without a [bannerPlaceErrorBuilder]. Defaults to
  ///   `true`.
  /// * [loadingTimeout]: how long to wait for banners before reporting an
  ///   error. Defaults to 10 seconds; [Duration.zero] disables the timeout.
  const BannerPlace({
    super.key,
    required super.placeId,
    required super.height,
    super.placeDecoration,
    @Deprecated(
      'Ignored since 0.11.0. Use '
      'AppearanceManager.instance.setBannersPlaceholder instead.',
    )
    this.bannerDecoration,
    super.autoLoad,
    super.isInteractionEnabled,
    super.bannerPlaceLoaderBuilder,
    super.bannerPlaceErrorBuilder,
    super.onActionWith,
    super.onBannerScroll,
    super.onBannerPlaceLoaded,
    super.onBannerPlaceLoadError,
    super.onBannerPlacePreloaded,
    super.onPreloadedError,
    super.hideOnEmpty,
    super.loadingTimeout,
  });

  /// No longer has any effect: the banner loading placeholder is global.
  @Deprecated(
    'Ignored since 0.11.0. Use '
    'AppearanceManager.instance.setBannersPlaceholder instead.',
  )
  final BannerDecoration? bannerDecoration;

  @override
  bool get isGrid => false;
}
