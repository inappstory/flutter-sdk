import 'dart:async';

abstract class InAppStorySdkModule {
  FutureOr<void> initWith(String apiKey, String userID, bool sendStatistics);
}
