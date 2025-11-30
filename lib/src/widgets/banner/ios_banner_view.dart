import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/banner_place_manager.dart';
import '../base/banner_platform_view.dart';

class IosBannerView extends BannerPlatformView {
  const IosBannerView({
    super.key,
    required super.placeId,
    required super.onPlatformViewCreated,
    required super.autoLoad,
    super.bannerDecoration,
    super.decoration,
  });

  @override
  Widget buildPlatformView(BuildContext context, String viewType,
      Map<String, dynamic> creationParams) {
    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: Map<String, dynamic>.from(creationParams),
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (id) {
        onPlatformViewCreated.call();
        if (autoLoad) {
          BannerPlaceManager.instance.load(placeId);
        }
      },
    );
  }
}
