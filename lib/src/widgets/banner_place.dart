import 'dart:io';

import 'package:flutter/material.dart';

import '../generated/banner_place_generated.g.dart'
    show BannerLoadCallbackFlutterApi, BannerViewHostApi;
import '../helpers/id_gen.dart';
import 'banner/android_banner_view.dart';
import 'banner/ios_banner_view.dart';
import 'builders/builders.dart' show BannerPlaceLoaderBuilder;
import 'decorators/decorators.dart';

enum BannerPlaceState {
  none,
  loading,
  loaded,
  failed,
}

class BannerPlace extends StatefulWidget {
  const BannerPlace({
    super.key,
    required this.placeId,
    required this.height,
    this.placeDecoration,
    this.bannerDecoration,
    this.autoLoad = true,
    this.bannerPlaceLoaderBuilder,
  });

  final String placeId;

  final double height;

  final BannerPlaceDecoration? placeDecoration;
  final BannerDecoration? bannerDecoration;

  final BannerPlaceLoaderBuilder? bannerPlaceLoaderBuilder;

  final bool autoLoad;

  @override
  State<BannerPlace> createState() => _BannerPlaceState();
}

class _BannerPlaceState extends State<BannerPlace>
    implements BannerLoadCallbackFlutterApi {
  BannerPlaceState _bannerPlaceState = BannerPlaceState.none;

  String bannerWidgetId = idGenerator();

  @override
  void didUpdateWidget(covariant BannerPlace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeId != widget.placeId) {
      _bannerPlaceState = BannerPlaceState.loading;
      BannerViewHostApi(messageChannelSuffix: bannerWidgetId)
          .changeBannerPlaceId(widget.placeId);
    }
  }

  @override
  void initState() {
    super.initState();
    BannerLoadCallbackFlutterApi.setUp(this,
        messageChannelSuffix: bannerWidgetId);
  }

  @override
  Widget build(BuildContext context) {
    Widget? placeholder = widget.bannerPlaceLoaderBuilder != null
        ? widget.bannerPlaceLoaderBuilder!(context)
        : SizedBox.shrink();
    return SizedBox(
      height: widget.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          buildPlatformView(context),
          if (_bannerPlaceState == BannerPlaceState.loading ||
              _bannerPlaceState == BannerPlaceState.none)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: placeholder,
            ),
        ],
      ),
    );
  }

  Widget buildPlatformView(BuildContext context) {
    if (Platform.isAndroid) {
      return SizedBox(
        height: widget.height,
        width: MediaQuery.of(context).size.width,
        child: AndroidBannerView(
          bannerWidgetId: bannerWidgetId,
          placeId: widget.placeId,
          decoration: widget.placeDecoration,
          bannerDecoration: widget.bannerDecoration,
          autoLoad: widget.autoLoad,
          onPlatformViewCreated: () {
            setState(() {
              _bannerPlaceState = BannerPlaceState.loading;
            });
          },
        ),
      );
    }
    if (Platform.isIOS) {
      return SizedBox(
        height: widget.height,
        width: MediaQuery.of(context).size.width,
        child: IosBannerView(
          bannerWidgetId: bannerWidgetId,
          placeId: widget.placeId,
          decoration: widget.placeDecoration,
          bannerDecoration: widget.bannerDecoration,
          autoLoad: widget.autoLoad,
          onPlatformViewCreated: () {
            setState(() {
              _bannerPlaceState = BannerPlaceState.loading;
            });
          },
        ),
      );
    }
    return const Center(
      child: Text('Unknown platform'),
    );
  }

  @override
  void onBannersLoaded(int size, int widgetHeight) {
    setState(() {
      _bannerPlaceState = BannerPlaceState.loaded;
    });
  }

  @override
  void dispose() {
    BannerViewHostApi(messageChannelSuffix: bannerWidgetId).deInitBannerPlace();
    BannerLoadCallbackFlutterApi.setUp(null,
        messageChannelSuffix: bannerWidgetId);
    super.dispose();
  }
}

class BannerDecoration {
  Color? color;
  String? image;

  BannerDecoration({
    this.color,
    this.image,
  });
}
