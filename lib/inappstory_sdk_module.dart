import 'dart:async';

/// This is an abstract class that defines the interface for initializing the InAppStory SDK module.
abstract class InAppStorySdkModule {
  FutureOr<void> initWith(String apiKey, String userId);
}
