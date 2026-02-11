import Flutter
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK
import UIKit

class BannerPlaceFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    private var registrar: FlutterPluginRegistrar

    private var bannerManager: BannerPlaceManagerAdaptor

    private var bannerPlaceCallbackManager: BannerPlaceCallbackManager

    init(messenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
        self.messenger = messenger
        self.registrar = registrar

        self.bannerManager = BannerPlaceManagerAdaptor(
            binaryMessenger: self.messenger
        )
        self.bannerPlaceCallbackManager = BannerPlaceCallbackManager()
        super.init()

        InAppStory.shared.iasBannerEvent = {
            switch $0 {
            case .bannersLoaded(let placeID):
                print(
                    "Banners loaded with place id: \(String(describing: placeID))"
                )
                break
            case .widgetEvent(let bannerData, let name, let data):
                self.bannerPlaceCallbackManager.sendEvent(
                    bannerData: self.bannerDataToDto(data: bannerData),
                    name: name,
                    data: data,
                )
                break
            case .preloaded(let placeID, let banners):
                break
            case .show(let bannerData):
                break
            case .clickOnButton(let bannerData, let link):
                print("clickOnButton: \(bannerData), \(link)")
                break
            @unknown default:
                print("default")
            }
        }

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
            bannerPlaceCallbackManager: self.bannerPlaceCallbackManager,
            binaryMessenger: messenger,
            pluginRegistrar: self.registrar
        )
    }

    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    private func bannerDataToDto(data: IASBannerData) -> BannerData {
        return BannerData(
            id: data.id,
            bannerPlace: data.placeID,
            payload: nil
        )
    }
}
