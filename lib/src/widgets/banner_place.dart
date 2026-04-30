import 'dart:io';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../controllers/ias_manager.dart';
import '../generated/banner_place_generated.g.dart'
    show BannerViewHostApi, BannerPlaceCallbackFlutterApi, BannerData;
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
    this.onActionWith,
    this.onBannerScroll,
    this.onBannerPlaceLoaded,
    this.onBannerPlacePreloaded,
    this.onPreloadedError,
  });

  final String placeId;

  final double height;

  final BannerPlaceDecoration? placeDecoration;
  final BannerDecoration? bannerDecoration;

  final BannerPlaceLoaderBuilder? bannerPlaceLoaderBuilder;

  final bool autoLoad;

  final Function(BannerData bannerData, String widgetEventName,
      Map<String, Object?>? widgetData)? onActionWith;
  final Function(int index)? onBannerScroll;
  final Function(int size, int widgetHeight)? onBannerPlaceLoaded;
  final Function()? onBannerPlacePreloaded;
  final Function()? onPreloadedError;

  @override
  State<BannerPlace> createState() => _BannerPlaceState();
}

class _BannerPlaceState extends State<BannerPlace>
    implements BannerPlaceCallbackFlutterApi {
  var _bannerPlaceState = BannerPlaceState.none;

  final _bannerWidgetId = idGenerator();

  bool _isVisible = false;

  late final _tag = 'BannerPlace(${widget.placeId}|$_bannerWidgetId)';

  final _iasLogger = InAppStoryManager.instance.logger;

  @override
  void didUpdateWidget(covariant BannerPlace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeId != widget.placeId) {
      _iasLogger.flutterDebugLog(_tag,
          'changing banner place id: ${oldWidget.placeId} -> ${widget.placeId}');
      _bannerPlaceState = BannerPlaceState.loading;
      BannerViewHostApi(messageChannelSuffix: _bannerWidgetId)
          .changeBannerPlaceId(widget.placeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? placeholder = widget.bannerPlaceLoaderBuilder != null
        ? widget.bannerPlaceLoaderBuilder!(context)
        : SizedBox.shrink();
    return SizedBox(
      height: widget.height,
      width: MediaQuery.of(context).size.width,
      child: VisibilityDetector(
        key: ValueKey(_bannerWidgetId),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction > 0.0) {
            _isVisible = true;
          } else {
            _isVisible = false;
          }
        },
        child: Stack(
          children: [
            _buildPlatformView(context),
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
      ),
    );
  }

  Widget _buildPlatformView(BuildContext context) {
    _iasLogger.flutterDebugLog(_tag, 'build PlatformView');
    if (Platform.isAndroid) {
      return SizedBox(
        height: widget.height,
        width: MediaQuery.of(context).size.width,
        child: AndroidBannerView(
          bannerWidgetId: _bannerWidgetId,
          placeId: widget.placeId,
          decoration: widget.placeDecoration,
          bannerDecoration: widget.bannerDecoration,
          autoLoad: widget.autoLoad,
          onPlatformViewCreated: () {
            BannerPlaceCallbackFlutterApi.setUp(this,
                messageChannelSuffix: _bannerWidgetId);
            setState(() {
              _bannerPlaceState = BannerPlaceState.loading;
            });
            _iasLogger.flutterDebugLog(_tag, 'PlatformView created');
          },
        ),
      );
    }
    if (Platform.isIOS) {
      return SizedBox(
        height: widget.height,
        width: MediaQuery.of(context).size.width,
        child: IosBannerView(
          bannerWidgetId: _bannerWidgetId,
          placeId: widget.placeId,
          decoration: widget.placeDecoration,
          bannerDecoration: widget.bannerDecoration,
          autoLoad: widget.autoLoad,
          onPlatformViewCreated: () {
            BannerPlaceCallbackFlutterApi.setUp(this,
                messageChannelSuffix: _bannerWidgetId);
            setState(() {
              _bannerPlaceState = BannerPlaceState.loading;
            });
            _iasLogger.flutterDebugLog(_tag, 'PlatformView created');
          },
        ),
      );
    }
    return const Center(
      child: Text('Unknown platform'),
    );
  }

  @override
  void dispose() {
    _iasLogger.flutterDebugLog(_tag, 'dispose');
    BannerViewHostApi(messageChannelSuffix: _bannerWidgetId)
        .deInitBannerPlace();
    BannerPlaceCallbackFlutterApi.setUp(null,
        messageChannelSuffix: _bannerWidgetId);
    super.dispose();
  }

  @override
  void onActionWith(BannerData bannerData, String widgetEventName,
      Map<String, Object?>? widgetData) {
    if (_isVisible) {
      widget.onActionWith?.call(bannerData, widgetEventName, widgetData);
    }
  }

  @override
  void onBannerPlaceLoaded(int size, int widgetHeight) {
    widget.onBannerPlaceLoaded?.call(size, widgetHeight);
    setState(() {
      _bannerPlaceState = BannerPlaceState.loaded;
    });
  }

  @override
  void onBannerPlacePreloaded() {
    widget.onBannerPlacePreloaded?.call();
  }

  @override
  void onBannerPlacePreloadedError() {
    widget.onPreloadedError?.call();
  }

  @override
  void onBannerScroll(int index) {
    if (_isVisible) {
      widget.onBannerScroll?.call(index);
    }
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
