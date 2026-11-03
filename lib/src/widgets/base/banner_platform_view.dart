import 'package:flutter/material.dart';

import '../../generated/banner_place_generated.g.dart';
import '../decorators/banner_grid_decoration.dart';

class BannerPlatformView extends StatelessWidget {
  const BannerPlatformView({
    super.key,
    required this.bannerWidgetId,
    required this.placeId,
    required this.onPlatformViewCreated,
    required this.autoLoad,
    this.layoutType = 'carousel',
    this.gridDecoration,
    this.decoration,
  });

  final String placeId;

  final String bannerWidgetId;

  final BannerPlaceDecoration? decoration;

  final bool autoLoad;

  final String layoutType;
  final BannerGridDecoration? gridDecoration;

  final Function() onPlatformViewCreated;

  @override
  Widget build(BuildContext context) {
    const String viewType = 'banner-view';
    Map<String, dynamic> creationParams = <String, dynamic>{};

    creationParams['bannerWidgetId'] = bannerWidgetId;
    creationParams['placeId'] = placeId;
    creationParams['layoutType'] = layoutType;
    final grid = gridDecoration;
    if (grid != null) {
      creationParams['gridHorizontalGap'] = grid.horizontalGap;
      creationParams['gridVerticalGap'] = grid.verticalGap;
      creationParams['gridCornerRadius'] = grid.cornerRadius;
    }
    if (decoration != null) {
      creationParams['loop'] = decoration?.loop ?? false;
      creationParams['bannerOffset'] = decoration?.bannerOffset ?? 0.0;
      creationParams['bannersGap'] = decoration?.bannersGap ?? 8.0;
      creationParams['cornerRadius'] = decoration?.cornerRadius ?? 16.0;
    }
    creationParams['autoLoad'] = autoLoad;
    return buildPlatformView(context, viewType, creationParams);
  }

  Widget buildPlatformView(
    BuildContext context,
    String viewType,
    Map<String, dynamic> creationParams,
  ) {
    return SizedBox.shrink();
  }
}
