import Foundation
import Flutter

@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class IASOnboardingsAdaptor : IASOnboardingsHostApi {
    init(binaryMessenger: FlutterBinaryMessenger, onboardingsAPI: OnboardingsAPI) {
        self.binaryMessenger = binaryMessenger
        
        self.onboardingsAPI = onboardingsAPI

        self.onboardingLoadCallbackFlutterApi = OnboardingLoadCallbackFlutterApi(binaryMessenger: binaryMessenger);
        
        IASOnboardingsHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: self)
    }
    
    private var binaryMessenger: FlutterBinaryMessenger
    
    private var onboardingsAPI: OnboardingsAPI
    
    private var onboardingLoadCallbackFlutterApi: OnboardingLoadCallbackFlutterApi
    
    func show(limit: Int64, feed: String, tags: [String]) throws {
        func complete(show: Bool) {
            if (show) {
                onboardingLoadCallbackFlutterApi.onboardingLoad(count: limit, feed: feed) { _ in }
            }
        }
        
        onboardingsAPI.showOnboarding(feed: feed, limit: Int(limit), with:tags, with:InAppStory.shared.panelSettings ,complete: complete)
    }
}
