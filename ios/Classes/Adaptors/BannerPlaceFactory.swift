import Flutter
import UIKit

class BannerPlaceFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    private var registrar: FlutterPluginRegistrar

    private var bannerManager: BannerPlaceManagerAdaptor
    private var callbackFlutterApi: BannerPlaceCallbackFlutterApi

    init(messenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
        self.messenger = messenger
        self.registrar = registrar

        self.bannerManager = BannerPlaceManagerAdaptor(
            binaryMessenger: self.messenger
        )
        self.callbackFlutterApi = BannerPlaceCallbackFlutterApi.init(
            binaryMessenger: self.messenger
        )
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return BannerPlaceView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            bannerPlaceManager: self.bannerManager,
            callbackFlutterApi: self.callbackFlutterApi,
            binaryMessenger: self.messenger,
            pluginRegistrar: self.registrar
        )
    }

    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
