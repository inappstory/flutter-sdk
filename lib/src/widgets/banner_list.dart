import 'base/banner_place_base.dart';

/// Displays banners in a vertically scrollable list.
///
/// The list scrolls within the viewport defined by [height].
class BannerList extends BannerPlaceBase {
  /// Creates a vertical banner list for the banner place [placeId].
  ///
  /// * [height]: the height of the scrollable viewport, in logical pixels.
  /// * [autoLoad]: whether banners load when the widget is created.
  ///   Defaults to `true`.
  /// * [isInteractionEnabled]: whether the user can tap and scroll banners.
  ///   Defaults to `true`.
  /// * [listDecoration]: the appearance of the list.
  /// * [bannerPlaceLoaderBuilder]: builds the widget shown while loading.
  /// * [bannerPlaceErrorBuilder]: builds the widget shown if loading fails.
  /// * [onActionWith]: called when a widget inside a banner sends an event.
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
  const BannerList({
    super.key,
    required super.placeId,
    required super.height,
    super.listDecoration,
    super.autoLoad,
    super.isInteractionEnabled,
    super.bannerPlaceLoaderBuilder,
    super.bannerPlaceErrorBuilder,
    super.onActionWith,
    super.onBannerPlaceLoaded,
    super.onBannerPlaceLoadError,
    super.onBannerPlacePreloaded,
    super.onPreloadedError,
    super.hideOnEmpty,
    super.loadingTimeout,
  });

  @override
  bool get isGrid => false;

  @override
  bool get isList => true;
}
