import Foundation
import Flutter
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class IASSingleStoryAdaptor : IASSingleStoryHostApi {
    init(binaryMessenger: FlutterBinaryMessenger, singleStoryAPI: SingleStoryAPI) {
        self.binaryMessenger = binaryMessenger
        
        self.singleStoryAPI = singleStoryAPI
        
        self.showStoryCallback = IShowStoryOnceCallbackFlutterApi(binaryMessenger: binaryMessenger)
        
        IASSingleStoryHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: self)
    }
    
    private var binaryMessenger: FlutterBinaryMessenger
    
    private var singleStoryAPI: SingleStoryAPI
    
    private var showStoryCallback: IShowStoryOnceCallbackFlutterApi
    
    func showOnce(storyId: Int64) throws {
        singleStoryAPI.showStoryOnce(with: String(storyId), complete: showOnceComplete)
    }
    
    func show(storyId: Int64, slide: Int64) throws {
        singleStoryAPI.showStory(with: String(storyId), complete: showComplete)
    }
    
    private func showOnceComplete(show: Bool) {
        if (show) {
            showStoryCallback.onShow(completion: {_ in })
        } else {
            showStoryCallback.alreadyShown(completion: {_ in })
        }
 
    }
    
    private func showComplete(show: Bool) {
        if (show) {
            showStoryCallback.onShow(completion: {_ in })
        } else {
            showStoryCallback.onError(completion: {_ in })
        }
    }
}
