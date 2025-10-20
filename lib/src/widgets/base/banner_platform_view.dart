import 'package:flutter/material.dart';

import '../../generated/banner_place_generated.g.dart';
import '../banner_place.dart' show BannerDecoration;

class BannerPlatformView extends StatelessWidget {
  const BannerPlatformView({
    super.key,
    required this.placeId,
    required this.onPlatformViewCreated,
    required this.autoLoad,
    this.decoration,
    this.bannerDecoration,
  });

  final String placeId;

  final BannerPlaceDecoration? decoration;

  final BannerDecoration? bannerDecoration;
  final bool autoLoad;

  final Function() onPlatformViewCreated;

  @override
  Widget build(BuildContext context) {
    const String viewType = 'banner-view';
    Map<String, dynamic> creationParams = <String, dynamic>{};

    creationParams['placeId'] = placeId;
    if (decoration != null) {
      creationParams['loop'] = decoration?.loop ?? false;
      creationParams['bannerOffset'] = decoration?.bannerOffset ?? 0.0;
      creationParams['bannersGap'] = decoration?.bannersGap ?? 8.0;
      creationParams['cornerRadius'] = decoration?.cornerRadius ?? 16.0;
    }

    if (bannerDecoration != null) {
      creationParams['bannerDecoration'] = BannerDecorationDTO(
        color: bannerDecoration?.color?.toARGB32(),
        image: bannerDecoration?.image,
      ).toJson();
    }
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

extension on BannerDecorationDTO {
  Map<String, dynamic> toJson() => {
        'color': color,
        'image': image,
      };
}
