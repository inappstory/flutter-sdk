import 'dart:async';

abstract class InappstorySdkModule {
  FutureOr<void> initWith(String apiKey, String userID, bool sendStatistics);
}

abstract class InAppStoryAPI {
  FutureOr<IASSDKVersion> getVersion();
}

abstract class IASSDKVersion {
  String get apiVersion;

  String get version;

  int get build;
}
