import Flutter
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK
import UIKit

class BannerPlaceView: NSObject, FlutterPlatformView, BannerViewHostApi {

    private var _bannersView: IASBannersView?

    private weak var bannerManager: BannerPlaceManagerAdaptor?
    private weak var callbackFlutterApi: BannerPlaceCallbackFlutterApi?
    private var bannerLoadFlutterApi: BannerLoadCallbackFlutterApi

    private var _view: UIView

    private var placeId: String
    private var bannerWidgetId: String

    private var bannersAppearance: IASBannersAppearance?

    private var loadBannerPlaceToken: UUID?
    private var reloadBannerPlaceToken: UUID?
    private var preloadBannerPlaceToken: UUID?
    private var showNextToken: UUID?
    private var showPreviousToken: UUID?
    private var showByIndexToken: UUID?
    private var pauseAutoscrollToken: UUID?
    private var resumeAutoscrollToken: UUID?

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        bannerPlaceManager bannerManager: BannerPlaceManagerAdaptor,
        callbackFlutterApi: BannerPlaceCallbackFlutterApi,
        binaryMessenger messenger: FlutterBinaryMessenger,
        pluginRegistrar registrar: FlutterPluginRegistrar
    ) {
        _view = UIView()

        self.placeId = (args as! [String: Any])["placeId"] as! String
        self.bannerWidgetId =
            (args as! [String: Any])["bannerWidgetId"] as! String

        self.bannerManager = bannerManager

        self.callbackFlutterApi = callbackFlutterApi

        self.bannerLoadFlutterApi = BannerLoadCallbackFlutterApi.init(
            binaryMessenger: messenger,
            messageChannelSuffix: self.bannerWidgetId
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

        BannerViewHostApiSetup.setUp(
            binaryMessenger: messenger,
            api: self,
            messageChannelSuffix: self.bannerWidgetId
        )

        self.loadBannerPlaceToken = self.bannerManager?.subscribe(
            LoadBannerPlace()
        ) {
            payload in
            if payload == self.placeId {
                self._bannersView?.create()
            }
        }

        self.reloadBannerPlaceToken = self.bannerManager?.subscribe(
            ReloadBannerPlace()
        ) {
            payload in
            if payload == self.placeId {
                self._bannersView?.refresh()
            }
        }
        self.preloadBannerPlaceToken = self.bannerManager?.subscribe(
            PreloadBannerPlace()
        ) {
            payload in
            if payload == self.placeId {
                DispatchQueue.main.async {
                    InAppStory.shared.preloadBanners(placeID: self.placeId) {
                        [weak self]
                        result in
                        guard let self else { return }
                        do {
                            if try result.get() {
                                self.callbackFlutterApi?.onBannerPlacePreloaded(
                                    placeId: self.placeId,
                                    completion: { _ in }
                                )
                            } else {
                                self.callbackFlutterApi?
                                    .onBannerPlacePreloadedError(
                                        placeId: self.placeId,
                                        completion: { _ in }
                                    )
                            }
                        } catch {
                            self.callbackFlutterApi?
                                .onBannerPlacePreloadedError(
                                    placeId: self.placeId,
                                    completion: { _ in }
                                )
                            print(
                                "Failed to preload banner for placeId: \(self.placeId), error: \(error)"
                            )
                        }
                    }
                }
            }
        }
        self.showNextToken = self.bannerManager?.subscribe(ShowNext()) {
            payload in
            if payload == self.placeId {
                self._bannersView?.showNext()
            }
        }
        self.showPreviousToken = self.bannerManager?.subscribe(ShowPrevious()) {
            payload in
            if payload == self.placeId {
                self._bannersView?.showPrevious()
            }
        }
        self.showByIndexToken = self.bannerManager?.subscribe(ShowByIndex()) {
            payload in
            if payload.placeId == self.placeId {
                self._bannersView?.showBannerWith(index: Int(payload.index))
            }
        }
        self.pauseAutoscrollToken = self.bannerManager?.subscribe(
            PauseAutoscroll()
        ) {
            payload in
            if payload == self.placeId {
                self._bannersView?.pause()
            }
        }
        self.resumeAutoscrollToken = self.bannerManager?.subscribe(
            ResumeAutoscroll()
        ) {
            payload in
            if payload == self.placeId {
                self._bannersView?.resume()
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
            self.bannersAppearance = IASBannersAppearance(
                shouldLoop: shouldLoop!,
                sideInset: CGFloat(sideInset!),
                interItemSpacing: CGFloat(interItemSpacing!),
                cornerRadius: CGFloat(cornerRadius!)
            )

        }

        createBannerView()

        _view.addSubview(_bannersView!)

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

    func createBannerView() {
        if self._bannersView != nil {
            self._bannersView?.removeFromSuperview()
            self._bannersView = nil
            //_view.willRemoveSubview(self._bannersView!)
        }
        if self.bannersAppearance != nil {

            self._bannersView = IASBannersView(
                placeID: self.placeId,
                appearance: self.bannersAppearance!,
                frame: .zero
            )
        } else {
            self._bannersView = IASBannersView(
                placeID: self.placeId,
                appearance: .init(),
                frame: .zero
            )
        }
        self._bannersView?.translatesAutoresizingMaskIntoConstraints = false
        self._bannersView?.bannersDidUpdated = {
            [weak self] isContent, count, listHeight in
            guard let self else { return }
            DispatchQueue.main.async { [self] in
                self.bannerLoadFlutterApi.onBannersLoaded(
                    size: Int64(count),
                    widgetHeight: Int64(listHeight),
                    completion: { _ in }
                )
                self.callbackFlutterApi?.onBannerPlaceLoaded(
                    placeId: self.placeId,
                    size: Int64(count),
                    widgetHeight: Int64(listHeight),
                    completion: { _ in }
                )
            }
        }

        self._bannersView?.bannersDidScroll = { [weak self] index in
            guard let self else { return }
            DispatchQueue.main.async { [self] in
                self.callbackFlutterApi?.onBannerScroll(
                    placeId: self.placeId,
                    index: Int64(index),
                    completion: { _ in }
                )
            }
        }
    }

    func changeBannerPlaceId(newPlaceId: String) throws {
        self.placeId = newPlaceId
        createBannerView()
        _view.addSubview(_bannersView!)
        _bannersView?.create()
    }

    func deInitBannerPlace() throws {
        clearBannerPlaceView()
    }

    deinit {
        clearBannerPlaceView()
    }

    func clearBannerPlaceView() {
        if _bannersView != nil {
            self._bannersView?.removeFromSuperview()
            _bannersView = nil
        }
        if let loadBannerPlaceToken = self.loadBannerPlaceToken {
            self.bannerManager?.unsubscribe(loadBannerPlaceToken)
        }
        if let pauseAutoscrollToken = self.pauseAutoscrollToken {
            self.bannerManager?.unsubscribe(pauseAutoscrollToken)
        }
        if let preloadBannerPlaceToken = self.preloadBannerPlaceToken {
            self.bannerManager?.unsubscribe(preloadBannerPlaceToken)
        }
        if let showNextToken = self.showNextToken {
            self.bannerManager?.unsubscribe(showNextToken)
        }
        if let showPreviousToken = self.showPreviousToken {
            self.bannerManager?.unsubscribe(showPreviousToken)
        }
        if let showByIndexToken = self.showByIndexToken {
            self.bannerManager?.unsubscribe(showByIndexToken)
        }
    }
}

