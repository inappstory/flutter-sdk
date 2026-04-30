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

    var level: [IASLogLevel] = [.initializ, .network, .profiling]  // logging level

    // log data capture
    func log(object: IASLogObject) {
        DispatchQueue.main.async {
            if object.error != nil {
                self.loggerFlutterApi.errorLog(
                    tag: "IAS iOS SDK",
                    message: object.error,
                    completion: { _ in }
                )
                return
            }
            if object.message != nil {
                self.loggerFlutterApi.debugLog(
                    tag: "IAS iOS SDK",
                    message: object.message,
                    completion: { _ in }
                )
                return
            }
            if object.cURL != nil {
                self.loggerFlutterApi.debugLog(
                    tag: "IAS iOS SDK",
                    message: object.cURL,
                    completion: { _ in }
                )
                return
            }
        }
    }
}
