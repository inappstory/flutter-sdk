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
///
/// Show methods return a [CancelableOperation] whose value reports completion
/// of the native call, not whether content was displayed. A native-call error
/// is logged and reported as `false`; otherwise the value is `true`.
///
/// Cancelling a pending operation requests native cancellation. It does not
/// guarantee that already displayed content is closed.
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

  /// Replaces the current tags with [tags].
  ///
  /// Invalid tags are ignored (and logged); only valid tags (up to 100) are
  /// applied. Returns `true` when the operation succeeds. Native-call errors
  /// propagate.
  Future<bool> setTags(List<String> tags) async {
    final sanitized = sanitizeTags(tags);
    await _iasManager.setTags(sanitized);
    return true;
  }

  /// Adds [tags] to the current tags.
  ///
  /// Invalid tags are ignored (and logged); only valid tags (up to 100) are
  /// added. If no valid tags remain, the native call is skipped. Returns `true`
  /// when the operation succeeds. Native-call errors propagate.
  Future<bool> addTags(List<String> tags) async {
    final sanitized = sanitizeTags(tags);
    if (sanitized.isNotEmpty) {
      await _iasManager.addTags(sanitized);
    }
    return true;
  }

  /// Removes [tags] from the current tags.
  ///
  /// Invalid tags are ignored (and logged); only valid tags are removed.
  /// If no valid tags remain, the native call is skipped. Returns `true` when
  /// the operation succeeds. Native-call errors propagate.
  Future<bool> removeTags(List<String> tags) async {
    final sanitized = sanitizeTags(tags);
    if (sanitized.isNotEmpty) {
      await _iasManager.removeTags(sanitized);
    }
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
  /// Invalid [tags] are ignored (and logged): only valid tags (up to 100) are
  /// applied rather than throwing.
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

  /// Requests onboarding stories from [feed], up to [limit] stories.
  ///
  /// [feed] defaults to `'onboarding'`. Non-null [tags] filter the stories.
  ///
  /// Completes with `true` if the native call returns without error, or `false`
  /// if it fails. This does not confirm that any stories were displayed.
  /// Cancel a pending operation to request native cancellation.
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

  /// Requests the in-app message with ID [id] without targeting checks.
  ///
  /// Use [showIAMByIdWithTargeting] to check targeting filters, including when
  /// no request-specific tags are supplied.
  ///
  /// [onlyPreloaded] requires the message to have been preloaded.
  /// [bottomPadding] is the space between the message and the bottom of the
  /// screen, in logical pixels; `null` is treated as zero.
  ///
  /// Completes with `true` if the native call returns without error, or `false`
  /// if it fails. This does not confirm that the message was displayed.
  /// Cancel a pending operation to request native cancellation.
  CancelableOperation<bool> showIAMById(
    String id, {
    bool onlyPreloaded = false,
    double? bottomPadding,
  }) =>
      _showIAM(
        (token) => _iam.showById(
          id,
          token,
          onlyPreloaded: onlyPreloaded,
          bottomPadding: bottomPadding,
        ),
      );

  /// Requests the in-app message with ID [id] with targeting enabled.
  ///
  /// Targeting is enabled by choosing this method, even when [tags] is `null`.
  /// Use [showIAMById] to skip targeting checks.
  ///
  /// Non-null [tags] override the tags for this request without changing SDK
  /// settings. An empty list explicitly requests no tags. Validation failures
  /// are logged and invalid tags are ignored (filtered out).
  /// A `null` value is passed through for the native SDK to handle.
  ///
  /// [onlyPreloaded] requires the message to have been preloaded; it does not
  /// bypass targeting checks or guarantee offline operation. [bottomPadding]
  /// is the bottom spacing in logical pixels; `null` is treated as zero.
  ///
  /// Completes with `true` if the native call returns without error, or `false`
  /// if it fails. This does not confirm that the message was displayed.
  /// Cancel a pending operation to request native cancellation.
  CancelableOperation<bool> showIAMByIdWithTargeting(
    String id, {
    bool onlyPreloaded = false,
    double? bottomPadding,
    List<String>? tags,
  }) =>
      _showIAM(
        (token) => _iam.showByIdWithTargeting(
          id,
          token,
          onlyPreloaded: onlyPreloaded,
          bottomPadding: bottomPadding,
          tags: tags == null ? null : sanitizeTags(tags),
        ),
      );

  /// Requests an in-app message for the event named [id].
  ///
  /// The native SDK always applies targeting to event requests. This method
  /// does not supply a request-specific tag override; use
  /// [showIAMByEventWithTargeting] to supply one.
  ///
  /// [onlyPreloaded] requires the message to have been preloaded.
  /// [bottomPadding] is the space between the message and the bottom of the
  /// screen, in logical pixels; `null` is treated as zero.
  ///
  /// Completes with `true` if the native call returns without error, or `false`
  /// if it fails. This does not confirm that the message was displayed.
  /// Cancel a pending operation to request native cancellation.
  CancelableOperation<bool> showIAMByEvent(
    String id, {
    bool onlyPreloaded = false,
    double? bottomPadding,
  }) =>
      _showIAM(
        (token) => _iam.showByEvent(
          id,
          token,
          onlyPreloaded: onlyPreloaded,
          bottomPadding: bottomPadding,
        ),
      );

  /// Requests an in-app message for the event named [id] with optional tags.
  ///
  /// Like [showIAMByEvent], this always uses native event targeting.
  /// Supplying [tags] changes the request's tags, not whether targeting runs.
  ///
  /// Non-null [tags] override the tags for this request without changing SDK
  /// settings. An empty list explicitly requests no tags. Validation failures
  /// are logged and invalid tags are ignored (filtered out).
  /// A `null` value is passed through for the native SDK to handle.
  ///
  /// [onlyPreloaded] requires the message to have been preloaded.
  /// [bottomPadding] is the bottom spacing in logical pixels; `null` is treated
  /// as zero.
  ///
  /// Completes with `true` if the native call returns without error, or `false`
  /// if it fails. This does not confirm that the message was displayed.
  /// Cancel a pending operation to request native cancellation.
  CancelableOperation<bool> showIAMByEventWithTargeting(
    String id, {
    bool onlyPreloaded = false,
    double? bottomPadding,
    List<String>? tags,
  }) =>
      _showIAM(
        (token) => _iam.showByEventWithTargeting(
          id,
          token,
          onlyPreloaded: onlyPreloaded,
          bottomPadding: bottomPadding,
          tags: tags == null ? null : sanitizeTags(tags),
        ),
      );

  CancelableOperation<bool> _showIAM(
    Future<void> Function(String token) show,
  ) {
    final uniqueId = idGenerator();
    return CancelableOperation.fromFuture(
      show(uniqueId).then((_) => true).catchError((error) {
        log('[InAppStory]: In-app message request failed', error: error);
        return false;
      }),
      onCancel: () async => _iam.cancelByToken(token: uniqueId),
    );
  }

  /// Requests the story with ID [id] without targeting checks.
  ///
  /// Use [showStoryWithTargeting] to check targeting filters, including when
  /// no request-specific tags are supplied.
  ///
  /// Completes with `true` if the native call returns without error, or `false`
  /// if it fails. This does not confirm that the story was displayed.
  /// Cancel a pending operation to request native cancellation.
  CancelableOperation<bool> showStory(String id) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _singleStoryApi
          .show(storyId: id, token: uniqueId)
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

  /// Requests the story with ID [id] only if the user has not seen it yet.
  ///
  /// Targeting is not applied.
  ///
  /// Completes with `true` if the native call returns without error, or `false`
  /// if it fails. This does not confirm that the story was displayed.
  /// Cancel a pending operation to request native cancellation.
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

  /// Requests the story with ID [id] with targeting enabled.
  ///
  /// Targeting is enabled by choosing this method, even when [tags] is `null`.
  /// Use [showStory] to skip targeting checks.
  ///
  /// Non-null [tags] override the tags for this request without changing SDK
  /// settings. An empty list explicitly requests no tags. Validation failures
  /// are logged and invalid tags are ignored (filtered out).
  /// A `null` value is passed through for the native SDK to handle.
  ///
  /// Completes with `true` if the native call returns without error, or `false`
  /// if it fails. This does not confirm that the story was displayed.
  /// Cancel a pending operation to request native cancellation.
  CancelableOperation<bool> showStoryWithTargeting(
    String id, {
    List<String>? tags,
  }) {
    final uniqueId = idGenerator();
    var operation = CancelableOperation.fromFuture(
      _singleStoryApi
          .showWithTargeting(
            storyId: id,
            token: uniqueId,
            tags: tags == null ? null : sanitizeTags(tags),
          )
          .then((value) => true)
          .catchError((error) {
        log('[InAppStory]: showStoryWithTargeting finished with error',
            error: error);
        return false;
      }),
      onCancel: () async {
        return _singleStoryApi.cancelByToken(token: uniqueId);
      },
    );
    return operation;
  }

  /// Opens the game with [gameId].
  ///
  /// Game lifecycle events are reported through the registered game callbacks.
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
