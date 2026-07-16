import Flutter
import Foundation
import InAppStorySDK

final class LoggerCallbackAdaptor: IASLoggerProtocol {

    private var loggerFlutterApi: LoggerFlutterApi

    init(binaryMessenger: FlutterBinaryMessenger) {
        self.loggerFlutterApi = LoggerFlutterApi(
            binaryMessenger: binaryMessenger
        )
    }

    // TEMP DIAGNOSTIC: .all instead of [.initializ, .network, .profiling] to
    // capture every category the SDK emits (reader/iam/banner/js/cache too).
    var level: [IASLogLevel] = [.all]  // logging level

    // log data capture
    func log(object: IASLogObject) {
        // TEMP DIAGNOSTIC: dump the whole object — note `warning` is dropped by
        // the dispatch below, so it never reaches Dart. cURL is multi-line and
        // gets truncated at the first newline in the system log, so flatten it.
        let flatCurl = (object.cURL ?? "-")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\\", with: "")
        NSLog("[IAS-SDKLOG] msg=\(object.message ?? "-") "
            + "warn=\(object.warning ?? "-") "
            + "err=\(object.error ?? "-")")
        if object.cURL != nil {
            NSLog("[IAS-SDKCURL] \(flatCurl)")
        }
        DispatchQueue.main.async {
            if object.error != nil {
                self.loggerFlutterApi.errorLog(
                    tag: nil,
                    message: object.error,
                    completion: { _ in }
                )
                return
            }
            if object.message != nil {
                self.loggerFlutterApi.debugLog(
                    tag: nil,
                    message: object.message,
                    completion: { _ in }
                )
                return
            }
            if object.cURL != nil {
                self.loggerFlutterApi.debugLog(
                    tag: nil,
                    message: object.cURL,
                    completion: { _ in }
                )
                return
            }
        }
    }
}
