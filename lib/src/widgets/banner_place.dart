import 'dart:io';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    this.isInteractionEnabled,
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
  final bool? isInteractionEnabled;

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

  final bannerWidgetId = idGenerator();

  bool isVisible = false;
  ModalRoute<dynamic>? _currentRoute;
  bool _lastInteractionState = true;
  bool _platformViewCreated = false;

  void _onRouteAnimationChanged() {
    _syncInteractionState();
  }

  void _onRouteStatusChanged(AnimationStatus status) {
    _syncInteractionState();
  }

  void _syncInteractionState() {
    final route = _currentRoute;
    final isRouteCurrent = route?.isCurrent ?? true;
    final isSecondaryZero = (route?.secondaryAnimation?.value ?? 0.0) == 0.0;
    final isRouteActiveAndCurrent = isRouteCurrent && isSecondaryZero;

    final effectiveInteraction =
        (widget.isInteractionEnabled ?? true) && isRouteActiveAndCurrent;

    if (effectiveInteraction != _lastInteractionState) {
      _lastInteractionState = effectiveInteraction;
      if (_platformViewCreated) {
        try {
          BannerViewHostApi(messageChannelSuffix: bannerWidgetId)
              .setInteraction(effectiveInteraction);
        } catch (_) {}
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (_currentRoute != route) {
      _currentRoute?.secondaryAnimation
          ?.removeListener(_onRouteAnimationChanged);
      _currentRoute?.secondaryAnimation
          ?.removeStatusListener(_onRouteStatusChanged);
      _currentRoute = route;
      _currentRoute?.secondaryAnimation?.addListener(_onRouteAnimationChanged);
      _currentRoute?.secondaryAnimation
          ?.addStatusListener(_onRouteStatusChanged);
    }
    _syncInteractionState();
  }

  @override
  void didUpdateWidget(covariant BannerPlace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeId != widget.placeId) {
      _bannerPlaceState = BannerPlaceState.loading;
      BannerViewHostApi(messageChannelSuffix: bannerWidgetId)
          .changeBannerPlaceId(widget.placeId);
    }
    if (oldWidget.isInteractionEnabled != widget.isInteractionEnabled) {
      _syncInteractionState();
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
        key: ValueKey(bannerWidgetId),
        onVisibilityChanged: (VisibilityInfo info) {
          if (info.visibleFraction > 0.0) {
            isVisible = true;
          } else {
            isVisible = false;
          }
        },
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
            _platformViewCreated = true;
            BannerPlaceCallbackFlutterApi.setUp(this,
                messageChannelSuffix: bannerWidgetId);
            setState(() {
              _bannerPlaceState = BannerPlaceState.loading;
            });
            if (!_lastInteractionState) {
              BannerViewHostApi(messageChannelSuffix: bannerWidgetId)
                  .setInteraction(false);
            }
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
            _platformViewCreated = true;
            BannerPlaceCallbackFlutterApi.setUp(this,
                messageChannelSuffix: bannerWidgetId);
            setState(() {
              _bannerPlaceState = BannerPlaceState.loading;
            });
            if (!_lastInteractionState) {
              BannerViewHostApi(messageChannelSuffix: bannerWidgetId)
                  .setInteraction(false);
            }
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
    _currentRoute?.secondaryAnimation
        ?.removeListener(_onRouteAnimationChanged);
    _currentRoute?.secondaryAnimation
        ?.removeStatusListener(_onRouteStatusChanged);
    _currentRoute = null;
    BannerViewHostApi(messageChannelSuffix: bannerWidgetId).deInitBannerPlace();
    BannerPlaceCallbackFlutterApi.setUp(null,
        messageChannelSuffix: bannerWidgetId);
    super.dispose();
  }

  @override
  void onActionWith(BannerData bannerData, String widgetEventName,
      Map<String, Object?>? widgetData) {
    if (isVisible) {
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
    if (isVisible) {
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
