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
    private weak var containerView: IAMContainerView?

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

        InAppStory.shared.inAppMessageDidClose = { [weak self] in
            self?.removeContainer()
        }
    }

    func showById(
        messageId: String,
        token: String,
        onlyPreloaded: Bool,
        bottomPadding: Double?
    ) throws {
        let cancellationToken = inAppMessagesApi.showInAppMessageWith(
            id: messageId,
            targetView: try container(bottomPadding: bottomPadding),
            onlyPreloaded: onlyPreloaded
        ) { [weak self] show in
            if !show { self?.removeContainer() }
        }
        tokenMap[token] = cancellationToken
    }

    func showByEvent(
        event: String,
        token: String,
        onlyPreloaded: Bool,
        bottomPadding: Double?
    ) throws {
        let cancellationToken = inAppMessagesApi.showInAppMessageWith(
            event: event,
            targetView: try container(bottomPadding: bottomPadding),
            onlyPreloaded: onlyPreloaded
        ) { [weak self] show in
            if !show { self?.removeContainer() }
        }
        tokenMap[token] = cancellationToken
    }

    func cancelByToken(token: String) throws -> Bool {
        if tokenMap[token] != nil {
            let result = tokenMap[token]!.cancel()
            tokenMap.removeValue(forKey: token)
            if result { removeContainer() }
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

    private func container(bottomPadding: Double?) throws -> IAMContainerView {
        let view = try containerView ?? makeContainer()
        view.bottomPadding = CGFloat(bottomPadding ?? 0)
        return view
    }

    private func makeContainer() throws -> IAMContainerView {
        guard let host = pluginRegistrar?.viewController?.view else {
            throw PigeonError(
                code: "no_container",
                message: "There is no Flutter view to show InAppMessage in",
                details: nil
            )
        }
        let view = IAMContainerView()
        view.attach(to: host)
        containerView = view
        return view
    }

    private func removeContainer() {
        containerView?.removeFromSuperview()
        containerView = nil
    }
}
