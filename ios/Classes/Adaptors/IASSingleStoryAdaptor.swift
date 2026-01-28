import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class IASSingleStoryAdaptor: IASSingleStoryHostApi {
    init(
        binaryMessenger: FlutterBinaryMessenger,
        singleStoryAPI: SingleStoryAPI
    ) {
        self.binaryMessenger = binaryMessenger

        self.singleStoryAPI = singleStoryAPI

        self.showStoryCallback = IShowStoryCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        IASSingleStoryHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }

    private var tokenMap: [String: InAppStorySDK.CancellationToken] = [:]

    private var binaryMessenger: FlutterBinaryMessenger

    private var singleStoryAPI: SingleStoryAPI

    private var showStoryCallback: IShowStoryCallbackFlutterApi

    func showOnce(storyId: String, token: String) throws {
        let cancellationToken = singleStoryAPI.showStoryOnce(
            with: storyId,
            complete: showOnceComplete
        )
        tokenMap[token] = cancellationToken
    }

    func show(storyId: String, token: String) throws {
        let cancellationToken = singleStoryAPI.showStory(
            with: storyId,
            complete: showComplete
        )
        tokenMap[token] = cancellationToken
    }

    func cancelByToken(token: String) throws {
        if tokenMap[token] != nil {
            let result = tokenMap[token]!.cancel()
            tokenMap.removeValue(forKey: token)
        }
    }

    private func showOnceComplete(show: Bool) {
        if show {
            showStoryCallback.onShow(completion: { _ in })
        } else {
            showStoryCallback.alreadyShown(completion: { _ in })
        }

    }

    private func showComplete(show: Bool) {
        if show {
            showStoryCallback.onShow(completion: { _ in })
        } else {
            showStoryCallback.onError(completion: { _ in })
        }
    }
}
