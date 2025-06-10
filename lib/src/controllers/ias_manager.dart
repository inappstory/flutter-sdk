import 'package:flutter/material.dart';

import '../pigeon_generated.g.dart' show InAppStoryManagerHostApi;

class InAppStoryManager {
  InAppStoryManager._private();

  static final instance = InAppStoryManager._private();

  Future<void> setPlaceholders(Map<String, String> placeholders) async {
    await InAppStoryManagerHostApi().setPlaceholders(placeholders);
  }

  Future<void> setTags(List<String> tags) async {
    await InAppStoryManagerHostApi().setTags(tags);
  }

  Future<void> changeUser(String userId) async {
    await InAppStoryManagerHostApi().changeUser(userId);
  }

  Future<void> closeReaders() async {
    await InAppStoryManagerHostApi().closeReaders();
  }

  Future<void> clearCache() async {
    await InAppStoryManagerHostApi().clearCache();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.countryCode?.isEmpty ?? true) {
      return;
    }
    await InAppStoryManagerHostApi()
        .setLang(locale.languageCode, locale.countryCode!);
  }
}
