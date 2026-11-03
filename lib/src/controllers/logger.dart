import 'dart:developer';

import '../generated/pigeon_generated_private.g.dart' show LoggerFlutterApi;

/// Receives debug and error log messages from the native InAppStory SDK.
///
/// Messages are stored in [logStore], forwarded to [onDebugLog] or
/// [onErrorLog], and optionally printed to the console.
class IASLogger implements LoggerFlutterApi {
  /// Called with the tag and message of each debug log entry.
  final Function(String? tag, String? message)? onDebugLog;

  /// Called with the tag and message of each error log entry.
  final Function(String? tag, String? message)? onErrorLog;

  /// All received messages, each keyed by the time it was received.
  final List<Map<DateTime, String?>> logStore = [];

  /// Whether received messages are also printed to the console.
  bool printToConsole = false;

  /// Creates a logger and registers it to receive native SDK logs.
  ///
  /// The new logger replaces any previously registered one. [onDebugLog] and
  /// [onErrorLog] are optional handlers for debug and error messages.
  /// Messages are printed to the console if [printToConsole] is `true`.
  IASLogger.create({
    this.onDebugLog,
    this.onErrorLog,
    this.printToConsole = false,
  }) {
    LoggerFlutterApi.setUp(this);
  }

  /// Records a debug [message] with its [tag].
  ///
  /// Empty or `null` messages are ignored.
  @override
  Future<void> debugLog(String? tag, String? message) async {
    if (message?.isEmpty ?? true) {
      return;
    }

    logStore.add({DateTime.now(): message});
    onDebugLog?.call(tag, message);
    if (printToConsole) {
      log(message!, name: 'IASLogger', time: DateTime.now());
    }
  }

  /// Records an error [message] with its [tag].
  ///
  /// Empty or `null` messages are ignored.
  @override
  Future<void> errorLog(String? tag, String? message) async {
    if (message?.isEmpty ?? true) {
      return;
    }
    logStore.add({DateTime.now(): message});
    onErrorLog?.call(tag, message);
    if (printToConsole) {
      log(message!, name: 'IASLogger', time: DateTime.now());
    }
  }
}
