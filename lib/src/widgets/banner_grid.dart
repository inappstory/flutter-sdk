import 'base/banner_place_base.dart';
import 'decorators/banner_grid_decoration.dart';

/// Displays banners in a grid with a configurable column count (defaults to 2) without internal scrolling.
///
/// Update [height] from [onBannerPlaceLoaded] to fit all rows. Use an outer
/// scrollable when the grid content may exceed the available screen space.
class BannerGrid extends BannerPlaceBase {
  /// Creates a grid of banners from the banner place [placeId].
  ///
  /// * [placeId]: the ID of the banner place in the InAppStory console.
  /// * [height]: the height of the widget, in logical pixels.
  /// * [autoLoad]: whether banners load when the widget is created. If
  ///   `false`, load them with `BannerPlaceManager.instance.load`.
  /// * [isInteractionEnabled]: whether the user can tap banners.
  ///   Defaults to `true`.
  /// * [bannerPlaceLoaderBuilder]: builds the widget shown while loading.
  /// * [bannerPlaceErrorBuilder]: builds the widget shown if loading fails.
  /// * [onActionWith]: called when a widget inside a banner sends an event.
  /// * [gridDecoration]: the gaps and corner radius of the grid.
  /// * [columns]: the number of columns in the grid. Defaults to 2.
  /// * [onBannerPlaceLoaded]: called with the number of banners and the full
  ///   content height in logical pixels, including all rows and gaps. On Android,
  ///   waits for native layout and is called again when the measured content
  ///   size changes. Empty results report `(0, 0)`.
  /// * [onBannerPlaceLoadError]: called with the error message if loading
  ///   fails or takes longer than [loadingTimeout].
  /// * [onBannerPlacePreloaded]: called when preloading succeeds.
  /// * [onPreloadedError]: called when preloading fails.
  /// * [hideOnEmpty]: whether the widget is hidden when there are no banners
  ///   or loading fails without a [bannerPlaceErrorBuilder]. Defaults to
  ///   `true`.
  /// * [loadingTimeout]: how long to wait for banners before reporting an
  ///   error. Defaults to 10 seconds; [Duration.zero] disables the timeout.
  const BannerGrid({
    super.key,
    required super.placeId,
    required super.height,
    BannerGridDecoration gridDecoration = const BannerGridDecoration(),
    int? columns,
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
  })  : _columns = columns,
        _gridDecoration = gridDecoration;

  final int? _columns;
  final BannerGridDecoration _gridDecoration;

  /// Number of columns in the grid. Defaults to 2.
  int get columns => _columns ?? gridDecoration.columns;

  /// Gaps, corner radius, and column count of the grid.
  @override
  BannerGridDecoration get gridDecoration =>
      _columns != null && _columns != _gridDecoration.columns
          ? BannerGridDecoration(
              horizontalGap: _gridDecoration.horizontalGap,
              verticalGap: _gridDecoration.verticalGap,
              cornerRadius: _gridDecoration.cornerRadius,
              columns: _columns!,
            )
          : _gridDecoration;

  @override
  bool get isGrid => true;
}
