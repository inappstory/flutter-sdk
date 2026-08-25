import 'dart:async';

import 'package:flutter/material.dart';

import 'inappstory_plugin_platform_interface.dart';
import 'src/data/data.dart' show CacheSize;
import 'src/helpers/tags_validator.dart';

export 'src/callbacks/callbacks.dart';
export 'src/controllers/controllers.dart';
export 'src/data/data.dart';
export 'src/generated/banner_place_generated.g.dart' show BannerData;
export 'src/generated/checkout_generated.g.dart'
    show ProductCart, ProductCartOffer;
export 'src/generated/pigeon_generated.g.dart'
    hide
        InAppStoryManagerHostApi,
        AppearanceManagerHostApi,
        IASSingleStoryHostApi,
        IASInAppMessagesHostApi,
        GameReaderCallbackFlutterApi,
        ErrorCallbackFlutterApi,
        CallToActionCallbackFlutterApi;
export 'src/widgets/decorators/decorators.dart';
export 'src/widgets/placeholders/placeholders.dart';
export 'src/widgets/widgets.dart';

class InAppStoryPlugin {
  factory InAppStoryPlugin() => _singleton ??= InAppStoryPlugin._private();

  InAppStoryPlugin._private();

  static InAppStoryPlugin? _singleton;

  /// The [InAppStoryPlugin] initialization method.
  ///
  /// Invalid [tags] are dropped: initialization then proceeds with no tags
  /// rather than throwing.
  Future<void> initWith(
    String apiKey,
    String userId, {
    bool anonymous = false,
    String? userSign,
    Locale? locale,
    CacheSize? cacheSize,
    List<String>? tags,
  }) async {
    await InappstoryPluginPlatform.instance.initWith(
      apiKey,
      userId,
      anonymous: anonymous,
      userSign: userSign,
      languageCode: locale?.languageCode,
      languageRegion: locale?.countryCode,
      cacheSize: cacheSize?.name,
      tags: tags == null ? null : sanitizeTags(tags),
    );
  }

  Future<bool> isInitialized() async {
    return InappstoryPluginPlatform.instance.isInitialized();
  }
}
