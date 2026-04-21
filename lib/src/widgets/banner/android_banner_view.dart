import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../base/banner_platform_view.dart';

class AndroidBannerView extends BannerPlatformView {
  const AndroidBannerView({
    super.key,
    required super.bannerWidgetId,
    required super.autoLoad,
    required super.placeId,
    required super.onPlatformViewCreated,
    super.bannerDecoration,
    super.decoration,
    super.enableVerticalScroll,
  });

  @override
  Widget buildPlatformView(
    BuildContext context,
    String viewType,
    Map<String, dynamic> creationParams,
  ) {
    return AndroidView(
      viewType: viewType,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => enableVerticalScroll
              ? EagerGestureRecognizer()
              : HorizontalDragGestureRecognizer(),
        ),
      },
      layoutDirection: TextDirection.ltr,
      creationParams: Map<String, dynamic>.from(creationParams),
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (id) => onPlatformViewCreated.call(),
    );
  }
}
