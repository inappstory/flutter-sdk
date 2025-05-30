import Flutter
import UIKit

public class InappstoryPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "inappstory_plugin",
            binaryMessenger: registrar.messenger()
        )
        let instance = InappstoryPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        InappstorySdkModuleAdaptor(binaryMessenger: registrar.messenger())
    }

    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
