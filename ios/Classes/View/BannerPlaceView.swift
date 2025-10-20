import Flutter
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK
import UIKit

class BannerPlaceView: NSObject, FlutterPlatformView, BannerPlaceManagerHostApi
{
    private var _bannersView: IASBannersView!

    private var callbackFlutterApi: BannerPlaceCallbackFlutterApi
    private var bannerLoadFlutterApi: BannerLoadCallbackFlutterApi

    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger,
        pluginRegistrar registrar: FlutterPluginRegistrar
    ) {
        _view = UIView()

        callbackFlutterApi = BannerPlaceCallbackFlutterApi.init(
            binaryMessenger: messenger
        )

        bannerLoadFlutterApi = BannerLoadCallbackFlutterApi.init(
            binaryMessenger: messenger
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

        BannerPlaceManagerHostApiSetup.setUp(
            binaryMessenger: messenger,
            api: self
        )

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

        _bannersView.bannersDidUpdated = { isContent, count, listHeight in
            DispatchQueue.main.async { [self] in
                bannerLoadFlutterApi.onBannersLoaded(
                    size: Int64(count),
                    widgetHeight: Int64(listHeight),
                    completion: { _ in }
                )
                callbackFlutterApi.onBannerPlaceLoaded(
                    size: Int64(count),
                    widgetHeight: Int64(listHeight),
                    completion: { _ in }
                )
            }
        }

        _bannersView.onActionWith = { target in

            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onActionWith(
                    target: target,
                    completion: { _ in }
                )
            }
        }

        _bannersView.bannersDidScroll = { index in
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onBannerScroll(
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

    func loadBannerPlace(placeId: String) throws {
        _bannersView.create()
    }

    func preloadBannerPlace(placeId: String) throws {
        InAppStory.shared.preloadBanners(placeID: placeId) { result in }
    }

    func showNext() throws {
        _bannersView.showNext()
    }

    func showPrevious() throws {
        _bannersView.showPrevious()

    }

    func showByIndex(index: Int64) throws {
        _bannersView.showBannerWith(index: Int(index))
    }

    func pauseAutoscroll() throws {
        _bannersView.pause()
    }

    func resumeAutoscroll() throws {
        _bannersView.resume()
    }
}
