import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../generated/banner_place_generated.g.dart'
    show BannerViewHostApi, BannerPlaceCallbackFlutterApi, BannerData;
import '../helpers/id_gen.dart';
import 'banner/android_banner_view.dart';
import 'banner/ios_banner_view.dart';
import 'builders/builders.dart'
    show BannerPlaceLoaderBuilder, BannerPlaceErrorBuilder;
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
    this.bannerPlaceErrorBuilder,
    this.onActionWith,
    this.onBannerScroll,
    this.onBannerPlaceLoaded,
    this.onBannerPlaceLoadError,
    this.onBannerPlacePreloaded,
    this.onPreloadedError,
    this.hideOnEmpty = true,
    this.loadingTimeout = const Duration(seconds: 10),
  });

  final String placeId;

  final double height;

  final BannerPlaceDecoration? placeDecoration;
  final BannerDecoration? bannerDecoration;

  final BannerPlaceLoaderBuilder? bannerPlaceLoaderBuilder;
  final BannerPlaceErrorBuilder? bannerPlaceErrorBuilder;

  final bool autoLoad;
  final bool? isInteractionEnabled;
  final bool hideOnEmpty;
  final Duration loadingTimeout;

  final Function(BannerData bannerData, String widgetEventName,
      Map<String, Object?>? widgetData)? onActionWith;
  final Function(int index)? onBannerScroll;
  final Function(int size, int widgetHeight)? onBannerPlaceLoaded;
  final Function(String message)? onBannerPlaceLoadError;
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
  Timer? _timeoutTimer;
  int? _loadedSize;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bannerPlaceState = BannerPlaceState.loading;
    BannerPlaceCallbackFlutterApi.setUp(this,
        messageChannelSuffix: bannerWidgetId);
    _startTimeout();
  }

  void _startTimeout() {
    _timeoutTimer?.cancel();
    if (widget.loadingTimeout > Duration.zero) {
      _timeoutTimer = Timer(widget.loadingTimeout, () {
        if (mounted &&
            (_bannerPlaceState == BannerPlaceState.loading ||
                _bannerPlaceState == BannerPlaceState.none)) {
          setState(() {
            _bannerPlaceState = BannerPlaceState.failed;
            _errorMessage = 'Banner loading timed out';
          });
          widget.onBannerPlaceLoadError?.call('Banner loading timed out');
        }
      });
    }
  }

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
      _loadedSize = null;
      _errorMessage = null;
      setState(() {
        _bannerPlaceState = BannerPlaceState.loading;
      });
      _startTimeout();
      BannerViewHostApi(messageChannelSuffix: bannerWidgetId)
          .changeBannerPlaceId(widget.placeId);
    }
    if (oldWidget.isInteractionEnabled != widget.isInteractionEnabled) {
      _syncInteractionState();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerPlaceState == BannerPlaceState.failed) {
      if (widget.bannerPlaceErrorBuilder != null) {
        return SizedBox(
          height: widget.height,
          width: MediaQuery.of(context).size.width,
          child: widget.bannerPlaceErrorBuilder!(
              context, _errorMessage ?? 'Failed to load banner'),
        );
      }
      if (widget.hideOnEmpty) {
        return const SizedBox.shrink();
      }
    }

    if (_bannerPlaceState == BannerPlaceState.loaded &&
        (_loadedSize == 0) &&
        widget.hideOnEmpty) {
      return const SizedBox.shrink();
    }

    Widget? placeholder = widget.bannerPlaceLoaderBuilder != null
        ? widget.bannerPlaceLoaderBuilder!(context)
        : const SizedBox.shrink();

    final bool showLoader = _bannerPlaceState == BannerPlaceState.loading ||
        _bannerPlaceState == BannerPlaceState.none;

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
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !showLoader,
                child: AnimatedOpacity(
                  opacity: showLoader ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: placeholder,
                ),
              ),
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
    _timeoutTimer?.cancel();
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
    _timeoutTimer?.cancel();
    _loadedSize = size;
    widget.onBannerPlaceLoaded?.call(size, widgetHeight);
    if (mounted) {
      setState(() {
        _bannerPlaceState = BannerPlaceState.loaded;
      });
    }
  }

  @override
  void onBannerPlaceLoadError(String message) {
    _timeoutTimer?.cancel();
    _errorMessage = message;
    widget.onBannerPlaceLoadError?.call(message);
    if (mounted) {
      setState(() {
        _bannerPlaceState = BannerPlaceState.failed;
      });
    }
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
