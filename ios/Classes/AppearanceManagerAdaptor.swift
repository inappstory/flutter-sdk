import Foundation
import Flutter
@_spi(IAS_API) import InAppStorySDK

class AppearanceManagerAdaptor: AppearanceManagerHostApi {
    init(binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
        
        self.panelSettings = PanelSettings()
        
        AppearanceManagerHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: self)
    }
    
    private var binaryMessenger: FlutterBinaryMessenger
    
    private var panelSettings: PanelSettings
    
    func setHasLike(value: Bool) throws {
        panelSettings.like = value
        InAppStory.shared.panelSettings = panelSettings
    }
    
    func setHasFavorites(value: Bool) throws {
        panelSettings.favorites = value
        InAppStory.shared.panelSettings = panelSettings
    }
    
    func setHasShare(value: Bool) throws {
        panelSettings.share = value
        InAppStory.shared.panelSettings = panelSettings
    }
}
