//
//  IASMessages.swift
//
//
//  Created by Alexander Sungurov on 13.05.2025.
//

import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK
import UIKit

class IASMessagesAdaptor: IASInAppMessagesHostApi {

    private var inAppMessagesApi: InAppStorySDK.InAppMessagesAPI
    private var binaryMessenger: FlutterBinaryMessenger
    private var tokenMap: [String: InAppStorySDK.CancellationToken] = [:]

    private weak var pluginRegistrar: FlutterPluginRegistrar?

    private var overlayWindow: IAMOverlayWindow?
    private weak var overlayContainerView: IAMPassthroughView?

    private var pendingBottomPadding: CGFloat = 0

    init(
        binaryMessenger: FlutterBinaryMessenger,
        pluginRegistrar: FlutterPluginRegistrar,
        inAppMessagesApi: InAppStorySDK.InAppMessagesAPI
    ) {
        self.binaryMessenger = binaryMessenger
        self.pluginRegistrar = pluginRegistrar
        self.inAppMessagesApi = InAppStoryAPI.shared.inappmessagesAPI
        IASInAppMessagesHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )

        InAppStory.shared.inAppMessageWillShow = { [weak self] _, _, presentType in
            guard let self else { return nil }
            let isToast = (presentType == .toast)
            return self.makeOverlayContainerView(
                isToast: isToast,
                bottomPadding: self.pendingBottomPadding
            )
        }

        InAppStory.shared.inAppMessageDidClose = { [weak self] in
            self?.dismissOverlay()
        }
    }

    func showById(
        messageId: String,
        token: String,
        onlyPreloaded: Bool,
        bottomPadding: Double?
    ) throws {
        pendingBottomPadding = CGFloat(bottomPadding ?? 0)
        let cancellationToken = inAppMessagesApi.showInAppMessageWith(
            id: messageId,
            targetView: try flutterHostView(),
            onlyPreloaded: onlyPreloaded
        ) { [weak self] show in
            if !show { self?.dismissOverlay() }
        }
        tokenMap[token] = cancellationToken
    }

    func showByEvent(
        event: String,
        token: String,
        onlyPreloaded: Bool,
        bottomPadding: Double?
    ) throws {
        pendingBottomPadding = CGFloat(bottomPadding ?? 0)
        let cancellationToken = inAppMessagesApi.showInAppMessageWith(
            event: event,
            targetView: try flutterHostView(),
            onlyPreloaded: onlyPreloaded
        ) { [weak self] show in
            if !show { self?.dismissOverlay() }
        }
        tokenMap[token] = cancellationToken
    }

    func cancelByToken(token: String) throws -> Bool {
        if tokenMap[token] != nil {
            let result = tokenMap[token]!.cancel()
            tokenMap.removeValue(forKey: token)
            if result { dismissOverlay() }
            return result
        }
        return false
    }

    func preloadMessages(
        ids: [String]?,
        completion: @escaping (Result<Bool, any Error>) -> Void
    ) {
        if ids?.isEmpty ?? true {
            inAppMessagesApi.preloadInAppMessages { result in
                switch result {
                case .success:
                    completion(.success(true))
                    break
                case .failure:
                    completion(.success(false))
                    break
                }
            }
        } else {
            inAppMessagesApi.preloadInAppMessages(ids: ids) { result in
                switch result {
                case .success:
                    completion(.success(true))
                    break
                case .failure:
                    completion(.success(false))
                    break
                }
            }
        }
    }


    private func flutterHostView() throws -> UIView {
        guard let host = pluginRegistrar?.viewController?.view else {
            throw PigeonError(
                code: "no_container",
                message: "There is no Flutter view to show InAppMessage in",
                details: nil
            )
        }
        return host
    }

    private func makeOverlayContainerView(isToast: Bool, bottomPadding: CGFloat) -> UIView {
        if let existing = overlayContainerView {
            existing.isPassthroughEnabled = isToast
            existing.bottomPadding = bottomPadding
            overlayWindow?.isHidden = false
            overlayWindow?.isUserInteractionEnabled = true
            return existing
        }

        let window: IAMOverlayWindow
        if #available(iOS 13.0, *),
           let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            window = IAMOverlayWindow(windowScene: scene)
            window.frame = scene.coordinateSpace.bounds
        } else {
            let frame = pluginRegistrar?.viewController?.view.window?.bounds
                ?? UIScreen.main.bounds
            window = IAMOverlayWindow(frame: frame)
        }

        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC
        window.windowLevel = .alert - 1
        window.backgroundColor = .clear
        window.isHidden = false
        window.isUserInteractionEnabled = true

        let container = IAMPassthroughView()
        container.attach(to: rootVC.view)
        container.isPassthroughEnabled = isToast
        container.bottomPadding = bottomPadding

        window.passthroughView = container
        self.overlayWindow = window
        self.overlayContainerView = container

        return container
    }

    private func dismissOverlay() {
        overlayContainerView?.subviews.forEach { $0.removeFromSuperview() }
        overlayWindow?.isUserInteractionEnabled = false
        overlayWindow?.isHidden = true
    }
}