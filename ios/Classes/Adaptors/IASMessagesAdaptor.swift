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

class IASMessagesAdaptor: IASInAppMessagesHostApi {

    private var inAppMessagesApi: InAppStorySDK.InAppMessagesAPI
    private var binaryMessenger: FlutterBinaryMessenger

    init(
        binaryMessenger: FlutterBinaryMessenger,
        inAppMessagesApi: InAppStorySDK.InAppMessagesAPI
    ) {
        self.binaryMessenger = binaryMessenger
        self.inAppMessagesApi = InAppStoryAPI.shared.inappmessagesAPI
        IASInAppMessagesHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }

    func show(messageId: String, onlyPreloaded: Bool) throws {
        inAppMessagesApi.showInAppMessageWith(
            id: messageId,
            onlyPreloaded: onlyPreloaded
        ) { _ in }
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
}
