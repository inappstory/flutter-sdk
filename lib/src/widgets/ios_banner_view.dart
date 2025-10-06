import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/banner_place_manager.dart';
import '../generated/banner_place_generated.g.dart';
import 'banner_place.dart';

class IosBannerView extends StatelessWidget {
  const IosBannerView(
      {super.key,
      required this.placeId,
      this.decoration,
      this.bannerDecoration});

  final String placeId;

  final BannerPlaceDecoration? decoration;

  final BannerDecoration? bannerDecoration;

  @override
  Widget build(BuildContext context) {
    const String viewType = 'banner-view';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    creationParams['placeId'] = placeId;
    if (decoration != null) {
      creationParams['loop'] = decoration?.loop ?? false;
      creationParams['bannerOffset'] = decoration?.bannerOffset ?? 0.0;
      creationParams['bannersGap'] = decoration?.bannersGap ?? 8.0;
      creationParams['cornerRadius'] = decoration?.cornerRadius ?? 16.0;
    }
    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (id) {
        BannerPlaceManager.instance.load(placeId);
      },
    );
  }
}
