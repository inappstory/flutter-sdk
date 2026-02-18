import Flutter
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK
import UIKit

class BannerPlaceView: NSObject, FlutterPlatformView, BannerViewHostApi {

    private var _bannersView: IASBannersView?

    private weak var bannerPlaceManagerAdaptor: BannerPlaceManagerAdaptor?
    private var callbackFlutterApi: BannerPlaceCallbackFlutterApi?
    private weak var bannerPlaceCallbackManager: BannerPlaceCallbackManager?

    private weak var registrar: FlutterPluginRegistrar?

    private var _view: UIView?

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
        bannerPlaceCallbackManager: BannerPlaceCallbackManager,
        pluginRegistrar registrar: FlutterPluginRegistrar,
    ) {
        _view = UIView()

        self.placeId = (args as! [String: Any])["placeId"] as! String
        bannerWidgetId =
        (args as! [String: Any])["bannerWidgetId"] as! String

        self.bannerPlaceManagerAdaptor = bannerManager

        self.bannerPlaceCallbackManager = bannerPlaceCallbackManager

        self.registrar = registrar

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
            binaryMessenger: registrar.messenger(),
            api: self,
            messageChannelSuffix: bannerWidgetId
        )

        self.bannerPlaceCallbackManager!.onProgress = {
            [weak self]
            bannerData,
            name,
            data in
            guard let self else { return }
            if bannerData.bannerPlace != self.placeId {
                return
            }
            DispatchQueue.main.async {
                [weak self] in
                guard let self else { return }
                self.callbackFlutterApi?.onActionWith(
                    bannerData: bannerData,
                    widgetEventName: name,
                    widgetData: data,
                    completion: { _ in }
                )
            }
        }

        self.loadBannerPlaceToken = self.bannerPlaceManagerAdaptor?.subscribe(
            LoadBannerPlace()
        ) {
            [weak self]
            payload in
            guard let self else { return }
            if payload == self.placeId {
                self._bannersView?.create()
            }
        }

        self.reloadBannerPlaceToken = self.bannerPlaceManagerAdaptor?.subscribe(
            ReloadBannerPlace()
        ) {
            [weak self]
            payload in
            guard let self else { return }
            if payload == self.placeId {
                self._bannersView?.refresh()
            }
        }
        self.preloadBannerPlaceToken = self.bannerPlaceManagerAdaptor?
            .subscribe(
                PreloadBannerPlace()
            ) {
                [weak self]
                payload in
                guard let self else { return }
                if payload == self.placeId {
                    DispatchQueue.main.async {
                        InAppStory.shared
                            .preloadBanners(placeID: self.placeId) {
                                [weak self]
                                result in
                                guard let self else { return }
                                do {
                                    if try result.get() {
                                        self.callbackFlutterApi?
                                            .onBannerPlacePreloaded(
                                                completion: { _ in }
                                            )
                                    } else {
                                        self.callbackFlutterApi?
                                            .onBannerPlacePreloadedError(
                                                completion: { _ in }
                                            )
                                    }
                                } catch {
                                    self.callbackFlutterApi?
                                        .onBannerPlacePreloadedError(
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
        self.showNextToken = self.bannerPlaceManagerAdaptor?
            .subscribe(ShowNext()) {
                [weak self]
                payload in
                guard let self else { return }
                if payload == self.placeId {
                    self._bannersView?.showNext()
                }
            }
        self.showPreviousToken = self.bannerPlaceManagerAdaptor?
            .subscribe(ShowPrevious()) {
                [weak self]
                payload in
                guard let self else { return }
                if payload == self.placeId {
                    self._bannersView?.showPrevious()
                }
            }
        self.showByIndexToken = self.bannerPlaceManagerAdaptor?
            .subscribe(ShowByIndex()) {
                [weak self]
                payload in
                guard let self else { return }
                if payload.placeId == self.placeId {
                    self._bannersView?.showBannerWith(index: Int(payload.index))
                }
            }
        self.pauseAutoscrollToken = self.bannerPlaceManagerAdaptor?.subscribe(
            PauseAutoscroll()
        ) {
            [weak self]
            payload in
            guard let self else { return }
            if payload == self.placeId {
                self._bannersView?.pause()
            }
        }
        self.resumeAutoscrollToken = self.bannerPlaceManagerAdaptor?.subscribe(
            ResumeAutoscroll()
        ) {
            [weak self]
            payload in
            guard let self else { return }
            if payload == self.placeId {
                self._bannersView?.resume()
            }
        }
        self.callbackFlutterApi = BannerPlaceCallbackFlutterApi(
            binaryMessenger: registrar.messenger(),
            messageChannelSuffix: bannerWidgetId
        )
        if let _view {
            createNativeView(view: _view, args: args! as! [String: Any])
        } else {
            _view = UIView()
            createNativeView(view: _view!, args: args! as! [String: Any])
        }
    }

    func view() -> UIView {
        return _view ?? UIView()
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
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.callbackFlutterApi?.onBannerPlaceLoaded(
                    size: Int64(count),
                    widgetHeight: Int64(listHeight),
                    completion: { _ in }
                )
            }
        }

        self._bannersView?.bannersDidScroll = { [weak self] index in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.callbackFlutterApi?.onBannerScroll(
                    index: Int64(index),
                    completion: { _ in }
                )
            }
        }
    }

    func changeBannerPlaceId(newPlaceId: String) throws {
        self.placeId = newPlaceId
        createBannerView()
        guard let bannersView = _bannersView, let view = _view else { return }
        _view?.addSubview(_bannersView!)
        NSLayoutConstraint.activate([
            bannersView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannersView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannersView.topAnchor.constraint(equalTo: view.topAnchor),
            bannersView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
            self._bannersView?.bannersDidUpdated = nil
            self._bannersView?.bannersDidScroll = nil
            self._bannersView?.removeFromSuperview()
            _bannersView = nil
        }
        self._view?.removeFromSuperview()

        self._view = nil

        self.callbackFlutterApi = nil

        if let loadBannerPlaceToken = self.loadBannerPlaceToken {
            self.bannerPlaceManagerAdaptor?.unsubscribe(loadBannerPlaceToken)
        }
        if let reloadBannerPlaceToken = self.reloadBannerPlaceToken {
            self.bannerPlaceManagerAdaptor?.unsubscribe(reloadBannerPlaceToken)
        }
        if let pauseAutoscrollToken = self.pauseAutoscrollToken {
            self.bannerPlaceManagerAdaptor?.unsubscribe(pauseAutoscrollToken)
        }
        if let resumeAutoscrollToken = self.resumeAutoscrollToken {
            self.bannerPlaceManagerAdaptor?.unsubscribe(resumeAutoscrollToken)
        }
        if let preloadBannerPlaceToken = self.preloadBannerPlaceToken {
            self.bannerPlaceManagerAdaptor?.unsubscribe(preloadBannerPlaceToken)
        }
        if let showNextToken = self.showNextToken {
            self.bannerPlaceManagerAdaptor?.unsubscribe(showNextToken)
        }
        if let showPreviousToken = self.showPreviousToken {
            self.bannerPlaceManagerAdaptor?.unsubscribe(showPreviousToken)
        }
        if let showByIndexToken = self.showByIndexToken {
            self.bannerPlaceManagerAdaptor?.unsubscribe(showByIndexToken)
        }
        self.bannerPlaceManagerAdaptor = nil
        self.bannerPlaceCallbackManager?.onProgress = nil
        self.bannerPlaceCallbackManager = nil

        if let registrar = self.registrar {
            BannerViewHostApiSetup.setUp(
                binaryMessenger: registrar.messenger(),
                api: nil,
                messageChannelSuffix: self.bannerWidgetId
            )
        }

    }
}

class BannerPlaceCallbackManager {
    var onProgress: ((BannerData, String, [String: Any]?) -> Void)?

    func sendEvent(bannerData: BannerData, name: String, data: [String: Any]?) {
        onProgress?(bannerData, name, data)
    }
}
