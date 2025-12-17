import 'dart:io';

import 'package:flutter/material.dart';

import '../generated/banner_place_generated.g.dart'
    show BannerLoadCallbackFlutterApi;
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
  BannerPlaceState bannerPlaceState = BannerPlaceState.none;

  @override
  void initState() {
    super.initState();
    BannerLoadCallbackFlutterApi.setUp(this, messageChannelSuffix: widget.placeId);
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
          if (bannerPlaceState == BannerPlaceState.loading ||
              bannerPlaceState == BannerPlaceState.none)
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
          placeId: widget.placeId,
          decoration: widget.placeDecoration,
          bannerDecoration: widget.bannerDecoration,
          autoLoad: widget.autoLoad,
          onPlatformViewCreated: () {
            setState(() {
              bannerPlaceState = BannerPlaceState.loading;
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
          placeId: widget.placeId,
          decoration: widget.placeDecoration,
          bannerDecoration: widget.bannerDecoration,
          autoLoad: widget.autoLoad,
          onPlatformViewCreated: () {
            setState(() {
              bannerPlaceState = BannerPlaceState.loading;
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
      bannerPlaceState = BannerPlaceState.loaded;
    });
  }

  @override
  void dispose() {
    BannerLoadCallbackFlutterApi.setUp(null, messageChannelSuffix: widget.placeId);
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
