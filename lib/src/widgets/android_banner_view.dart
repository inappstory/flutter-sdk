import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/banner_place_manager.dart';
import '../generated/banner_place_generated.g.dart';
import 'banner_place.dart';

class AndroidBannerView extends StatelessWidget {
  const AndroidBannerView(
    this.placeId, {
    super.key,
    this.decoration,
    this.bannerDecoration,
    this.autoLoad = true,
  });

  final String placeId;
  final BannerPlaceDecoration? decoration;

  final BannerDecoration? bannerDecoration;

  final bool autoLoad;

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
        gradientType: bannerDecoration?.gradientType,
        gradientColors:
            bannerDecoration?.gradientColors?.map((e) => e.toARGB32()).toList(),
        gradientStops: bannerDecoration?.gradientStops,
      ).toJson();
    }

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: Map.from(creationParams),
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (id) {
        if (autoLoad) {
          BannerPlaceManager.instance.load(placeId);
        }
      },
    );
  }
}

extension on BannerDecorationDTO {
  Map<String, dynamic> toJson() => {
        'color': color,
        'image': image,
        'gradientType': gradientType?.index,
        'gradientColors': gradientColors,
        'gradientStops': gradientStops,
      };
}
