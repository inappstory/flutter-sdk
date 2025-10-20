import 'dart:ui';

import '../callbacks/callbacks.dart'
    show GoodsCallbackFlutterApiImpl, SkusCallbackImpl;
import '../pigeon_generated.g.dart'
    show InAppStoryManagerHostApi, SkusCallbackFlutterApi;

class InAppStoryManager {
  InAppStoryManager._private();

  final _iasManager = InAppStoryManagerHostApi();

  final _callbackImpl = GoodsCallbackFlutterApiImpl();

  static final instance = InAppStoryManager._private();

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
    SkusCallbackFlutterApi.setUp(_callbackImpl);
  }

  Future<void> setOptions(Map<String, String> options) async {
    await _iasManager.setOptionKeys(options);
  }
}
