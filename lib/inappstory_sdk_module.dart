import 'dart:async';

/// This is an abstract class that defines the interface for initializing the InAppStory SDK module.
abstract class InAppStorySdkModule {
  FutureOr<void> initWith(
    String apiKey,
    String userId, {
    bool anonymous,
    String? languageCode,
    String? languageRegion,
    String? userSign,
    String? cacheSize,
  });
}
