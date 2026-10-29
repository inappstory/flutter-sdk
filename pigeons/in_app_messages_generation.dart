import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/in_app_messages_generated.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/src/main/kotlin/com/inappstory/inappstory_plugin/InAppMessagesGenerated.g.kt',
  kotlinOptions: KotlinOptions(includeErrorClass: false),
  swiftOut:
      'ios/inappstory_plugin/Sources/inappstory_plugin/InAppMessagesGenerated.g.swift',
  swiftOptions: SwiftOptions(includeErrorClass: false),
))
// IASInAppMessagesHostApi

enum InAppMessageTypeDto { fullScreen, bottomSheet, popUp, toast, undefined }

@HostApi()
abstract class IASInAppMessagesHostApi {
  void showById(String messageId, String token,
      {bool onlyPreloaded = false, double? bottomPadding, List<String>? tags});

  void showByEvent(String event, String token,
      {bool onlyPreloaded = false, double? bottomPadding, List<String>? tags});

  @asyncCallback
  bool preloadMessages({List<String>? ids});

  bool cancelByToken({required String token});
}

/// Represents data for an in-app message.
///
/// This class contains information about an in-app message, including its
/// unique identifier, title, and associated event.
class InAppMessageDataDto {
  /// The unique identifier of the in-app message.
  late int id;

  /// The title of the in-app message, or `null` if not available.
  late String? title;

  /// The event associated with the in-app message, or `null` if not available.
  late String? event;

  late InAppMessageTypeDto? messageType;

  late Map<String, String>? extraFields;
}

@FlutterApi()
abstract class IASInAppMessagesCallbacksFlutterApi {
  @asyncCallback
  void onShowInAppMessage(InAppMessageDataDto? inAppMessageData);

  @asyncCallback
  void onCloseInAppMessage(InAppMessageDataDto? inAppMessageData);

  @asyncCallback
  void onInAppMessageWidgetEvent(InAppMessageDataDto? inAppMessageData,
      String? name, Map<String?, Object?>? data);
}
