import 'dart:async';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';

import '../callbacks/call_to_action_callback_impl.dart';
import '../callbacks/callbacks.dart'
    show GoodsCallbackFlutterApiImpl, SkusCallbackImpl;
import '../callbacks/ias_checkout_callback_impl.dart';
import '../generated/checkout_generated.g.dart'
    show CheckoutManagerCallbackFlutterApi;
import '../generated/pigeon_generated.g.dart'
    show
        InAppStoryManagerHostApi,
        SkusCallbackFlutterApi,
        IASInAppMessagesHostApi,
        IASSingleStoryHostApi,
        IASOnboardingsHostApi,
        CallToActionCallbackFlutterApi;
import '../helpers/id_gen.dart';
import 'logger.dart';

class InAppStoryManager {
  InAppStoryManager._private() {
    SkusCallbackFlutterApi.setUp(_callbackImpl);
    CheckoutManagerCallbackFlutterApi.setUp(_checkoutCallbackImpl);
    CallToActionCallbackFlutterApi.setUp(_ctaCallbackImpl);
  }

  final _iasManager = InAppStoryManagerHostApi();

  final _callbackImpl = GoodsCallbackFlutterApiImpl();
  final _checkoutCallbackImpl = IASCheckoutManagerCallbackImpl();
  final _iam = IASInAppMessagesHostApi();
  final _onboardings = IASOnboardingsHostApi();
  final _singleStoryApi = IASSingleStoryHostApi();

  final _ctaCallbackImpl = CallToActionCallbackImpl();

  static final instance = InAppStoryManager._private();

  IASLogger? _logger;

  IASLogger get logger => _logger ?? IASLogger.create();

  set logger(IASLogger value) {
    _logger = value;
  }

  Future<void> setPlaceholders(Map<String, String> placeholders) async {
    await _iasManager.setPlaceholders(placeholders);
  }

  Future<void> setTags(List<String> tags) async {
    await _iasManager.setTags(tags);
  }

  Future<void> setUserSettings({
    bool? anonymous,
    String? userId,
    String? userSign,
    Locale? locale,
    List<String>? tags,
    Map<String, String>? placeholders,
  }) async {
    await _iasManager.setUserSettings(
      anonymous: anonymous,
      userId: userId,
      userSign: userSign,
      newLanguageCode: locale?.languageCode,
      newLanguageRegion: locale?.countryCode,
      newTags: tags,
      newPlaceholders: placeholders,
    );
  }

  Future<void> changeUser(String userId, {String? userSign}) async {
    await _iasManager.changeUser(userId, userSign: userSign);
  }

  Future<void> userLogout() async {
    await _iasManager.userLogout();
  }

  Future<void> closeReaders() async {
    await _iasManager.closeReaders();
  }

  Future<void> clearCache() async {
    await _iasManager.clearCache();
  }

  Future<void> setTransparentStatusBar() async {
    await _iasManager.setTransparentStatusBar();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.countryCode?.isEmpty ?? true) {
      return;
    }
    await _iasManager.setLang(locale.languageCode, locale.countryCode!);
  }

  Future<void> changeSound(bool enabled) async {
    await _iasManager.changeSound(enabled);
  }

  void setGetSkusCallback(SkusCallbackImpl callback) {
    _callbackImpl.callback = callback;
  }

  void setOnProductCartUpdate(OnProductCartUpdateCallbackImpl callback) {
    _checkoutCallbackImpl.onProductCartUpdateCallback = callback;
  }

  void setGetProductCartState(GetProductCartStateCallbackImpl callback) {
    _checkoutCallbackImpl.getProductCartStateCallback = callback;
  }

  Future<void> setOptions(Map<String, String> options) async {
    await _iasManager.setOptionKeys(options);
  }

  Future<bool> preloadInAppMessages({List<String>? ids}) async {
    return await _iam.preloadMessages(ids: ids);
  }

  CancelableOperation<bool> showOnboarding(int limit,
      {String? feed, List<String>? tags}) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _onboardings
          .show(
              limit: limit,
              token: uniqueId,
              feed: feed ?? 'onboarding',
              tags: tags ?? <String>[])
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: showIAMById finished with error');
        return false;
      }),
      onCancel: () async {
        return _iam.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  CancelableOperation<bool> showIAMById(String id,
      {bool onlyPreloaded = false, double? bottomPadding}) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _iam
          .showById(id, uniqueId,
              onlyPreloaded: onlyPreloaded, bottomPadding: bottomPadding)
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: showIAMById finished with error');
        return false;
      }),
      onCancel: () async {
        return _iam.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  CancelableOperation<bool> showIAMByEvent(String id,
      {bool onlyPreloaded = false, double? bottomPadding}) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _iam
          .showByEvent(id, uniqueId,
              onlyPreloaded: onlyPreloaded, bottomPadding: bottomPadding)
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: showIAMByEvent finished with error');
        return false;
      }),
      onCancel: () async {
        return _iam.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  CancelableOperation<bool> showStory(String id) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _singleStoryApi
          .show(storyId: id, token: uniqueId)
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: ShowStory finished with error');
        return false;
      }),
      onCancel: () async {
        return _singleStoryApi.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  CancelableOperation<bool> showStoryOnce(String id) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _singleStoryApi
          .showOnce(storyId: id, token: uniqueId)
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: showStoryOnce finished with error');
        return false;
      }),
      onCancel: () async {
        return _singleStoryApi.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  void addCallToActionCallback(CallToActionImpl callback) {
    _ctaCallbackImpl.addCallback(callback);
  }

  void removeCallToActionCallback(CallToActionImpl callback) {
    _ctaCallbackImpl.removeCallback(callback);
  }
}
