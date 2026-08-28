import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class IASOnboardingsAdaptor: IASOnboardingsHostApi {
    init(
        binaryMessenger: FlutterBinaryMessenger,
        onboardingsAPI: OnboardingsAPI
    ) {
        self.binaryMessenger = binaryMessenger

        self.onboardingsAPI = onboardingsAPI

        self.onboardingLoadCallbackFlutterApi =
            OnboardingLoadCallbackFlutterApi(binaryMessenger: binaryMessenger)

        IASOnboardingsHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }

    private var binaryMessenger: FlutterBinaryMessenger

    private var onboardingsAPI: OnboardingsAPI

    private var onboardingLoadCallbackFlutterApi:
        OnboardingLoadCallbackFlutterApi

    private var tokenMap: [String: InAppStorySDK.CancellationToken] = [:]

    func show(limit: Int64, feed: String, token: String, tags: [String]) throws
    {
        func complete(show: Bool) {
            if show {
                onboardingLoadCallbackFlutterApi.onboardingLoadSuccess(
                    count: limit,
                    feed: feed
                ) { _ in }
            } else {
                onboardingLoadCallbackFlutterApi.onboardingLoadError(
                    feed: feed,
                    reason: "Onboarding load error"
                ) { _ in }
            }
        }

        let cancellationToken = onboardingsAPI.showOnboarding(
            feed: feed,
            limit: Int(limit),
            with: tags,
            with: InAppStory.shared.panelSettings,
            complete: complete
        )
        tokenMap[token] = cancellationToken
    }

    func cancelByToken(token: String) throws -> Bool {
        if tokenMap[token] != nil {
            let result = tokenMap[token]!.cancel()
            tokenMap.removeValue(forKey: token)
            return result
        }
        return false
    }
}
