import 'package:flutter/material.dart';

import '../pigeon_generated.g.dart' show InAppStoryManagerHostApi;

class InAppStoryManager {
  InAppStoryManager._private();

  final _iasManager = InAppStoryManagerHostApi();

  static final instance = InAppStoryManager._private();

  Future<void> setPlaceholders(Map<String, String> placeholders) async {
    await _iasManager.setPlaceholders(placeholders);
  }

  Future<void> setTags(List<String> tags) async {
    await _iasManager.setTags(tags);
  }

  Future<void> changeUser(String userId) async {
    await _iasManager.changeUser(userId);
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
}
