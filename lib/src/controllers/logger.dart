import 'dart:developer';

import '../generated/pigeon_generated_private.g.dart' show LoggerFlutterApi;

class IASLogger implements LoggerFlutterApi {
  final Function(String? tag, String? message)? onDebugLog;
  final Function(String? tag, String? message)? onErrorLog;

  final List<String?> debugStore = [];
  final List<String?> errorStore = [];

  bool printToConsole = false;

  IASLogger.create({
    this.onDebugLog,
    this.onErrorLog,
    this.printToConsole = false,
  }) {
    LoggerFlutterApi.setUp(this);
  }

  @override
  void debugLog(String? tag, String? message) {
    if (message?.isEmpty ?? true) {
      return;
    }
    debugStore.add(message);
    onDebugLog?.call(tag, message);
    if (printToConsole) {
      log(message!, name: 'IASLogger', time: DateTime.now());
    }
  }

  @override
  void errorLog(String? tag, String? message) {
    if (message?.isEmpty ?? true) {
      return;
    }
    errorStore.add(message);
    onErrorLog?.call(tag, message);
    if (printToConsole) {
      log(message!, name: 'IASLogger', time: DateTime.now());
    }
  }
}
