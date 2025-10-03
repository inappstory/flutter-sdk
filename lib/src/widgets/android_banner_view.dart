import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../generated/banner_place_generated.g.dart';
import 'banner_place.dart';

class AndroidBannerView extends StatelessWidget {
  const AndroidBannerView(this.placeId,
      {super.key, this.decoration, this.bannerDecoration});

  final String placeId;
  final BannerPlaceDecoration? decoration;

  final BannerDecoration? bannerDecoration;

  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
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

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
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
