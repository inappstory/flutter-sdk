import Flutter
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK
import UIKit

class BannerPlaceView: NSObject, FlutterPlatformView
{
    private var _bannersView: IASBannersView!

    private var bannerManager: BannerPlaceManagerAdaptor
    private var callbackFlutterApi: BannerPlaceCallbackFlutterApi
    private var bannerLoadFlutterApi: BannerLoadCallbackFlutterApi

    private var _view: UIView

    private var placeId: String

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        bannerPlaceManager bannerManager: BannerPlaceManagerAdaptor,
        callbackFlutterApi callbackFlutterApi:BannerPlaceCallbackFlutterApi,
        binaryMessenger messenger: FlutterBinaryMessenger,
        pluginRegistrar registrar: FlutterPluginRegistrar
    ) {
        _view = UIView()

        self.placeId = (args as! [String: Any])["placeId"] as! String
        
        self.bannerManager = bannerManager

        self.callbackFlutterApi = callbackFlutterApi

        bannerLoadFlutterApi = BannerLoadCallbackFlutterApi.init(
            binaryMessenger: messenger,
            messageChannelSuffix: self.placeId
        )

        var decoration: BannerDecorationDTO?

        if let args = args as? [String: Any] {
            decoration = BannerDecorationDTO(
                color: args["color"] as? Int64,
                image: args["image"] as? String,
            )
        }

        if decoration != nil {
            let placeholder = CustomPlaceholderView()
            placeholder.setDecoration(decoration, registrar: registrar)
            InAppStory.shared.placeholderView = placeholder
        }

        super.init()
        // iOS views can be created here

        self.bannerManager.subscribe(LoadBannerPlace()) {
            payload in
            if payload == self.placeId {
                self._bannersView.create()
            }
        }
        self.bannerManager.subscribe(PreloadBannerPlace()) {
            payload in
            if payload == self.placeId {
                InAppStory.shared.preloadBanners(placeID: self.placeId) { result in
                    do {
                        if try result.get() {
                            self.callbackFlutterApi.onBannerPlacePreloaded(
                                placeId: self.placeId,
                                completion: { _ in }
                            )
                        } else {
                            self.callbackFlutterApi.onBannerPlacePreloadedError(
                                placeId: self.placeId,
                                completion: { _ in }
                            )
                        }
                    } catch {
                        self.callbackFlutterApi.onBannerPlacePreloadedError(
                            placeId: self.placeId,
                            completion: { _ in })
                        print(
                            "Failed to preload banner for placeId: \(self.placeId), error: \(error)"
                        )
                    }
                }
            }
        }
        self.bannerManager.subscribe(ShowNext()) {
            payload in
            if payload == self.placeId {
                self._bannersView.showNext()
            }
        }
        self.bannerManager.subscribe(ShowPrevious()) {
            payload in
            if payload == self.placeId {
                self._bannersView.showPrevious()
            }
        }
        self.bannerManager.subscribe(ShowByIndex()) {
            payload in
            if payload.placeId == self.placeId {
                self._bannersView.showBannerWith(index: Int(payload.index))
            }
        }
        self.bannerManager.subscribe(PauseAutoscroll()) {
            payload in
            if payload == self.placeId {
                self._bannersView.pause()
            }
        }
        self.bannerManager.subscribe(ResumeAutoscroll()) {
            payload in
            if payload == self.placeId {
                self._bannersView.resume()
            }
        }
        createNativeView(view: _view, args: args! as! [String: Any])
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView, args _args: [String: Any]) {

        let shouldLoop = _args["loop"] as? Bool
        let sideInset = _args["bannerOffset"] as? NSNumber
        let interItemSpacing = _args["bannersGap"] as? NSNumber
        let cornerRadius = _args["cornerRadius"] as? NSNumber

        if shouldLoop != nil && sideInset != nil && interItemSpacing != nil
            && cornerRadius != nil
        {
            let bannersAppearance = IASBannersAppearance(
                shouldLoop: shouldLoop!,
                sideInset: CGFloat(sideInset!),
                interItemSpacing: CGFloat(interItemSpacing!),
                cornerRadius: CGFloat(cornerRadius!)
            )

            _bannersView = IASBannersView(
                placeID: _args["placeId"] as! String,
                appearance: bannersAppearance,
                frame: .zero
            )
        } else {
            _bannersView = IASBannersView(
                placeID: _args["placeId"] as! String,
                appearance: .init(),
                frame: .zero
            )
        }

        _bannersView.translatesAutoresizingMaskIntoConstraints = false

        InAppStory.shared.iasBannerEvent = {
            switch $0 {
            case .bannersLoaded(let placeID):
                print(
                    "Banners loaded with place id: \(String(describing: placeID))"
                )
                break
            case .widgetEvent(let bannerData, let name, let data):
                print(
                    "Banner widget event with name: \(name) and data: \(String(describing: data))"
                )
                break
            case .preloaded(let placeID, let banners):
                break
            case .show(let bannerData):
                break
            case .clickOnButton(let bannerData, let link):
                break
            @unknown default:
                print("default")
            }
        }

        _bannersView.bannersDidUpdated = { isContent, count, listHeight in
            DispatchQueue.main.async { [self] in
                bannerLoadFlutterApi.onBannersLoaded(
                    size: Int64(count),
                    widgetHeight: Int64(listHeight),
                    completion: { _ in }
                )
                callbackFlutterApi.onBannerPlaceLoaded(
                    placeId: self.placeId,
                    size: Int64(count),
                    widgetHeight: Int64(listHeight),
                    completion: { _ in }
                )
            }
        }

        _bannersView.onActionWith = { target in
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onActionWith(
                    placeId: self.placeId,
                    target: target,
                    completion: { _ in }
                )
            }
        }

        _bannersView.bannersDidScroll = { index in
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onBannerScroll(
                    placeId: self.placeId,
                    index: Int64(index),
                    completion: { _ in }
                )
            }
        }

        _view.addSubview(_bannersView)

        var allConstraints: [NSLayoutConstraint] = []  // настройка констрайнов
        let horConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(0)-[_bannersView]-(0)-|",
            options: [.alignAllLeading, .alignAllTrailing],
            metrics: nil,
            views: ["_bannersView": _bannersView!]
        )
        allConstraints += horConstraint
        let vertConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(0)-[_bannersView]-(0)-|",
            options: [.alignAllTop, .alignAllBottom],
            metrics: nil,
            views: ["_bannersView": _bannersView!]
        )
        allConstraints += vertConstraint
        NSLayoutConstraint.activate(allConstraints)
    }
}
