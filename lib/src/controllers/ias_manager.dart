import 'dart:async';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/widgets.dart';

import '../callbacks/call_to_action_callback_impl.dart';
import '../callbacks/callbacks.dart'
    show GoodsCallbackFlutterApiImpl, SkusCallbackImpl;
import '../callbacks/ias_checkout_callback_impl.dart';
import '../callbacks/ias_error_callback_impl.dart';
import '../generated/appearance_manager.g.dart' show SkusCallbackFlutterApi;
import '../generated/checkout_generated.g.dart'
    show CheckoutManagerCallbackFlutterApi;
import '../generated/pigeon_generated.g.dart'
    show
        IASGamesHostApi,
        IASInAppMessagesHostApi,
        IASSingleStoryHostApi,
        IASOnboardingsHostApi,
        CallToActionCallbackFlutterApi,
        ErrorCallbackFlutterApi;
import '../generated/story_manager_generated.g.dart'
    show InAppStoryManagerHostApi;
import '../helpers/id_gen.dart';
import '../helpers/tags_validator.dart';
import 'logger.dart';

/// The main entry point for user settings, tags, readers and on-demand
/// content such as single stories, onboardings, in-app messages and games.
///
/// Use the shared [InAppStoryManager.instance].
class InAppStoryManager {
  InAppStoryManager._private() {
    SkusCallbackFlutterApi.setUp(_callbackImpl);
    CheckoutManagerCallbackFlutterApi.setUp(_checkoutCallbackImpl);
    CallToActionCallbackFlutterApi.setUp(_ctaCallbackImpl);
    ErrorCallbackFlutterApi.setUp(_errorCallbackImpl);
  }

  final _iasManager = InAppStoryManagerHostApi();

  final _callbackImpl = GoodsCallbackFlutterApiImpl();
  final _checkoutCallbackImpl = IASCheckoutManagerCallbackImpl();
  final _iam = IASInAppMessagesHostApi();
  final _onboardings = IASOnboardingsHostApi();
  final _singleStoryApi = IASSingleStoryHostApi();
  final _games = IASGamesHostApi();

  final _ctaCallbackImpl = CallToActionCallbackImpl();
  final _errorCallbackImpl = ErrorCallbackFlutterApiImpl();

  /// The shared instance used by the app.
  static final instance = InAppStoryManager._private();

  IASLogger? _logger;

  /// The logger used by the SDK.
  ///
  /// Assign a custom [IASLogger] to change how SDK messages are logged.
  IASLogger get logger => _logger ?? IASLogger.create();

  set logger(IASLogger value) {
    _logger = value;
  }

  /// Sets text [placeholders] substituted into story content.
  ///
  /// Each key is a placeholder name and each value is its replacement.
  Future<void> setPlaceholders(Map<String, String> placeholders) async {
    await _iasManager.setPlaceholders(placeholders);
  }

  /// Replaces the current tags with [tags], returning true when they were
  /// valid and applied as-is.
  ///
  /// Invalid tags are logged and dropped: the tags are cleared (set empty) and
  /// false is returned instead of throwing.
  Future<bool> setTags(List<String> tags) async {
    final valid = checkTags(tags);
    await _iasManager.setTags(valid ? tags : const <String>[]);
    return valid;
  }

  /// Adds [tags] to the current tags, returning true when they were valid and
  /// added.
  ///
  /// Invalid tags are logged and dropped: nothing is added and false is
  /// returned instead of throwing.
  Future<bool> addTags(List<String> tags) async {
    if (!checkTags(tags)) {
      return false;
    }
    await _iasManager.addTags(tags);
    return true;
  }

  /// Removes [tags] from the current tags, returning true when they were valid
  /// and removed.
  ///
  /// Invalid tags are logged and dropped: nothing is removed and false is
  /// returned instead of throwing.
  Future<bool> removeTags(List<String> tags) async {
    if (!checkTags(tags)) {
      return false;
    }
    await _iasManager.removeTags(tags);
    return true;
  }

  /// Updates the user settings in a single call.
  ///
  /// Only non-null arguments are applied:
  /// * [anonymous]: whether the user is anonymous.
  /// * [userId] and [userSign]: the user ID and its signature.
  /// * [locale]: the content language.
  /// * [tags]: replaces the current tags.
  /// * [placeholders]: replaces the text placeholders.
  ///
  /// Invalid [tags] are dropped, so an invalid set clears the tags rather than
  /// throwing.
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
      newTags: tags == null ? null : sanitizeTags(tags),
      newPlaceholders: placeholders,
    );
  }

  /// Switches the current user to [userId], optionally signed with
  /// [userSign].
  Future<void> changeUser(String userId, {String? userSign}) async {
    await _iasManager.changeUser(userId, userSign: userSign);
  }

  /// Logs out the current user.
  Future<void> userLogout() async {
    await _iasManager.userLogout();
  }

  /// Closes the story reader if it is open.
  Future<void> closeReaders() async {
    await _iasManager.closeReaders();
  }

  /// Clears the SDK cache of stories and resources.
  Future<void> clearCache() async {
    await _iasManager.clearCache();
  }

  /// Makes the status bar transparent while the reader is open.
  ///
  /// Android only; does nothing on iOS.
  Future<void> setTransparentStatusBar() async {
    await _iasManager.setTransparentStatusBar();
  }

  /// Sets the content language to [locale].
  ///
  /// Does nothing if [locale] has no country code.
  Future<void> setLocale(Locale locale) async {
    if (locale.countryCode?.isEmpty ?? true) {
      return;
    }
    await _iasManager.setLang(locale.languageCode, locale.countryCode!);
  }

  /// Turns sound in stories on if [enabled] is `true`, or off otherwise.
  Future<void> changeSound(bool enabled) async {
    await _iasManager.changeSound(enabled);
  }

  /// Sets the [callback] that provides goods data for SKUs shown in stories.
  void setGetSkusCallback(SkusCallbackImpl callback) {
    _callbackImpl.callback = callback;
  }

  /// Sets the [callback] called when a story changes the product cart.
  void setOnProductCartUpdate(OnProductCartUpdateCallbackImpl callback) {
    _checkoutCallbackImpl.onProductCartUpdateCallback = callback;
  }

  /// Sets the [callback] that returns the current product cart.
  void setGetProductCartState(GetProductCartStateCallbackImpl callback) {
    _checkoutCallbackImpl.getProductCartStateCallback = callback;
  }

  /// Sets custom [options] passed to story content as key-value pairs.
  Future<void> setOptions(Map<String, String> options) async {
    await _iasManager.setOptionKeys(options);
  }

  /// Preloads in-app messages so they can be shown without delay.
  ///
  /// Preloads only the messages with the given [ids], or all messages if
  /// [ids] is `null` or empty. Returns whether preloading succeeded.
  Future<bool> preloadInAppMessages({List<String>? ids}) async {
    return await _iam.preloadMessages(ids: ids);
  }

  /// Shows onboarding stories from [feed], up to [limit] stories.
  ///
  /// [feed] defaults to `'onboarding'`. Non-null [tags] filter the stories.
  /// Completes with `true` on success and `false` on error. Cancel the
  /// operation to stop showing the onboarding.
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
        log('[InAppStory]: showOnboarding finished with error', error: error);
        return false;
      }),
      onCancel: () async {
        return _onboardings.cancelByToken(uniqueId);
      },
    );
    return operation;
  }

  /// Shows the in-app message with ID [id].
  ///
  /// If [onlyPreloaded] is `true`, the message is shown only if it was
  /// preloaded. [bottomPadding] is the space, in logical pixels, between the
  /// message and the bottom of the screen. Non-null [tags] are used for
  /// targeting. Completes with `true` on success and `false` on error. Cancel
  /// the operation to stop showing the message.
  CancelableOperation<bool> showIAMById(
    String id, {
    bool onlyPreloaded = false,
    double? bottomPadding,
    List<String>? tags,
  }) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _iam
          .showById(id, uniqueId,
              onlyPreloaded: onlyPreloaded,
              bottomPadding: bottomPadding,
              tags: tags == null ? null : sanitizeTags(tags))
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: showIAMById finished with error', error: error);
        return false;
      }),
      onCancel: () async {
        return _iam.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  /// Shows the in-app message triggered by the event [id].
  ///
  /// If [onlyPreloaded] is `true`, the message is shown only if it was
  /// preloaded. [bottomPadding] is the space, in logical pixels, between the
  /// message and the bottom of the screen. Non-null [tags] are used for
  /// targeting. Completes with `true` on success and `false` on error. Cancel
  /// the operation to stop showing the message.
  CancelableOperation<bool> showIAMByEvent(
    String id, {
    bool onlyPreloaded = false,
    double? bottomPadding,
    List<String>? tags,
  }) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _iam
          .showByEvent(id, uniqueId,
              onlyPreloaded: onlyPreloaded,
              bottomPadding: bottomPadding,
              tags: tags == null ? null : sanitizeTags(tags))
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: showIAMByEvent finished with error', error: error);
        return false;
      }),
      onCancel: () async {
        return _iam.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  /// Opens the story with ID [id] in the reader.
  ///
  /// Non-null [tags] are used for targeting. Completes with `true` on success
  /// and `false` on error. Cancel the operation to stop opening the story.
  CancelableOperation<bool> showStory(String id, {List<String>? tags}) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _singleStoryApi
          .show(
            storyId: id,
            token: uniqueId,
            tags: tags == null ? null : sanitizeTags(tags),
          )
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: ShowStory finished with error', error: error);
        return false;
      }),
      onCancel: () async {
        return _singleStoryApi.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  /// Opens the story with ID [id] only if the user has not seen it yet.
  ///
  /// Completes with `true` on success and `false` on error. Cancel the
  /// operation to stop opening the story.
  CancelableOperation<bool> showStoryOnce(String id) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _singleStoryApi
          .showOnce(storyId: id, token: uniqueId)
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: showStoryOnce finished with error', error: error);
        return false;
      }),
      onCancel: () async {
        return _singleStoryApi.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  /// Opens the game with [gameId]. Game lifecycle events are delivered to
  /// [IASGameReaderCallback].
  Future<void> openGame(String gameId) async {
    await _games.openGame(gameId);
  }

  /// Closes the currently open game.
  Future<void> closeGame() async {
    await _games.closeGame();
  }

  /// Preloads games so they open without delay.
  Future<void> preloadGames() async {
    await _games.preloadGames();
  }

  /// Adds a [callback] called when the user taps a call-to-action in a story.
  void addCallToActionCallback(CallToActionImpl callback) {
    _ctaCallbackImpl.addCallback(callback);
  }

  /// Removes a [callback] previously added with [addCallToActionCallback].
  void removeCallToActionCallback(CallToActionImpl callback) {
    _ctaCallbackImpl.removeCallback(callback);
  }

  /// Sets the [callback] notified about SDK errors.
  void setErrorCallback(IASErrorCallback callback) {
    _errorCallbackImpl.callback = callback;
  }
}
