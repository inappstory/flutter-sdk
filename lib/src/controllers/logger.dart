import 'dart:developer';

import '../generated/pigeon_generated_private.g.dart' show LoggerFlutterApi;

enum IASLogLevel {
  all,
  flutter,
  native,
}

class IASLogger implements LoggerFlutterApi {
  final Function(String? tag, String? message)? onDebugLog;
  final Function(String? tag, String? message)? onErrorLog;

  final List<Map<DateTime, String?>> logStore = [];

  bool printToConsole = false;

  var logLevel = IASLogLevel.all;

  IASLogger.create({
    this.onDebugLog,
    this.onErrorLog,
    this.printToConsole = false,
    this.logLevel = IASLogLevel.flutter,
  }) {
    LoggerFlutterApi.setUp(this);
  }

  void flutterDebugLog(String tag, String message) {
    if (logLevel == IASLogLevel.native) {
      return;
    }
    final now = DateTime.now();
    logStore.add({now: message});
    onDebugLog?.call(tag, message);
    if (printToConsole) {
      log(message, name: 'IASLogger | $tag', time: now);
    }
  }

  void flutterErrorLog(String tag, String message) {
    if (logLevel == IASLogLevel.native) {
      return;
    }
    final now = DateTime.now();
    logStore.add({now: message});
    onErrorLog?.call(tag, message);
    if (printToConsole) {
      log(message, name: 'IASLogger | $tag', time: now);
    }
  }

  @override
  void debugLog(String? tag, String? message) {
    if (logLevel == IASLogLevel.flutter) {
      return;
    }
    if (message?.isEmpty ?? true) {
      return;
    }
    final now = DateTime.now();
    logStore.add({now: message});
    onDebugLog?.call(tag, message);
    if (printToConsole) {
      log(message!, name: 'IASLogger | $tag', time: now);
    }
  }

  @override
  void errorLog(String? tag, String? message) {
    if (logLevel == IASLogLevel.flutter) {
      return;
    }
    if (message?.isEmpty ?? true) {
      return;
    }
    final now = DateTime.now();
    logStore.add({now: message});
    onErrorLog?.call(tag, message);
    if (printToConsole) {
      log(message!, name: 'IASLogger | $tag', time: now);
    }
  }
}
