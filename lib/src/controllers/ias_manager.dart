import 'dart:ui';

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
        CallToActionCallbackFlutterApi;
import 'logger.dart';

/// Entry point for managing InAppStory SDK state — users, settings, cache, and callbacks.
///
/// This class is a singleton; access it via [InAppStoryManager.instance].
///
/// Example:
/// ```dart
/// final manager = InAppStoryManager.instance;
/// await manager.setUserSettings(userId: 'user_123');
/// ```
class InAppStoryManager {
  InAppStoryManager._private() {
    SkusCallbackFlutterApi.setUp(_callbackImpl);
    CheckoutManagerCallbackFlutterApi.setUp(_checkoutCallbackImpl);
    CallToActionCallbackFlutterApi.setUp(_ctaCallbackImpl);
  }

  final _iasManager = InAppStoryManagerHostApi();

  final _callbackImpl = GoodsCallbackFlutterApiImpl();
  final _checkoutCallbackImpl = IASCheckoutManagerCallbackImpl();

  final _ctaCallbackImpl = CallToActionCallbackImpl();

  /// The singleton instance of the manager.
  static final instance = InAppStoryManager._private();

  IASLogger? _logger;

  /// Logger used for SDK debug output.
  ///
  /// Returns a default [IASLogger] instance if none has been explicitly assigned.
  IASLogger get logger => _logger ?? IASLogger.create();

  set logger(IASLogger value) {
    _logger = value;
  }

  /// Sets content placeholders used for story template substitution.
  ///
  /// [placeholders] is a key/value map where each key is a placeholder name
  /// and the value is the string to substitute.
  Future<void> setPlaceholders(Map<String, String> placeholders) async {
    await _iasManager.setPlaceholders(placeholders);
  }

  /// Sets the current user's tags for content segmentation.
  Future<void> setTags(List<String> tags) async {
    await _iasManager.setTags(tags);
  }

  /// Updates settings for the current user.
  ///
  /// All parameters are optional — pass only those that need to change.
  ///
  /// - [anonymous] — marks the user as anonymous.
  /// - [userId] — user identifier.
  /// - [userSign] — user signature for verification.
  /// - [locale] — locale used for content localization.
  /// - [tags] — user tags for segmentation.
  /// - [placeholders] — template placeholders.
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

  /// Switches the active user.
  ///
  /// [userId] — the new user identifier.
  /// [userSign] — optional signature for verification.
  Future<void> changeUser(String userId, {String? userSign}) async {
    await _iasManager.changeUser(userId, userSign: userSign);
  }

  /// Logs out the current user from the SDK.
  Future<void> userLogout() async {
    await _iasManager.userLogout();
  }

  /// Closes all currently open story readers.
  Future<void> closeReaders() async {
    await _iasManager.closeReaders();
  }

  /// Clears the local SDK cache (images, story data).
  Future<void> clearCache() async {
    await _iasManager.clearCache();
  }

  /// Makes the status bar transparent. Android only.
  Future<void> setTransparentStatusBar() async {
    await _iasManager.setTransparentStatusBar();
  }

  /// Sets the locale for SDK content localization.
  ///
  /// The call is ignored if [locale] does not contain a country code.
  Future<void> setLocale(Locale locale) async {
    if (locale.countryCode?.isEmpty ?? true) {
      return;
    }
    await _iasManager.setLang(locale.languageCode, locale.countryCode!);
  }

  /// Enables or disables sound in stories.
  ///
  /// Pass `true` to enable, `false` to disable.
  Future<void> changeSound(bool enabled) async {
    await _iasManager.changeSound(enabled);
  }

  /// Sets the callback invoked to retrieve the list of goods (SKUs) shown in stories.
  void setGetSkusCallback(SkusCallbackImpl callback) {
    _callbackImpl.callback = callback;
  }

  /// Sets the callback invoked when the user updates the product cart state.
  void setOnProductCartUpdate(OnProductCartUpdateCallbackImpl callback) {
    _checkoutCallbackImpl.onProductCartUpdateCallback = callback;
  }

  /// Sets the callback used to read the current product cart state.
  void setGetProductCartState(GetProductCartStateCallbackImpl callback) {
    _checkoutCallbackImpl.getProductCartStateCallback = callback;
  }

  /// Sets additional SDK options as a key/value map.
  Future<void> setOptions(Map<String, String> options) async {
    await _iasManager.setOptionKeys(options);
  }

  /// Registers a callback to handle call-to-action events in stories.
  void addCallToActionCallback(CallToActionImpl callback) {
    _ctaCallbackImpl.addCallback(callback);
  }

  /// Removes a previously registered call-to-action callback.
  void removeCallToActionCallback(CallToActionImpl callback) {
    _ctaCallbackImpl.removeCallback(callback);
  }
}
