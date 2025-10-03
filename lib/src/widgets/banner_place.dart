import 'dart:io';

import 'package:flutter/material.dart';

import '../generated/banner_place_generated.g.dart'
    show BannerPlaceDecoration, GradientType;
import 'android_banner_view.dart';
import 'ios_banner_view.dart';

class BannerPlace extends StatelessWidget {
  const BannerPlace({
    super.key,
    required this.placeId,
    required this.height,
    this.placeDecoration,
    this.bannerDecoration,
  });

  final String placeId;

  final double height;

  final BannerPlaceDecoration? placeDecoration;
  final BannerDecoration? bannerDecoration;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return SizedBox(
        height: height,
        width: MediaQuery.of(context).size.width,
        child: AndroidBannerView(
          placeId,
          decoration: placeDecoration,
          bannerDecoration: bannerDecoration,
        ),
      );
    }
    if (Platform.isIOS) {
      return SizedBox(
        height: height,
        width: MediaQuery.of(context).size.width,
        child: IosBannerView(
          placeId: placeId,
          decoration: placeDecoration,
          bannerDecoration: bannerDecoration,
        ),
      );
    }
    return const Center(
      child: Text('Unknown platform'),
    );
  }
}

class BannerDecoration {
  Color? color;
  String? image;
  GradientType? gradientType;
  List<Color>? gradientColors;
  List<double>? gradientStops;

  BannerDecoration({
    this.color,
    this.image,
    this.gradientType,
    this.gradientColors,
    this.gradientStops,
  });
}
