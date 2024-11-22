//
//  InappstorySdkModuleAdaptor.swift
//  inappstory_plugin
//
//  Created by Sergey Salnikov on 29.10.2024.
//

import Foundation
import Flutter
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class InappstorySdkModuleAdaptor: InappstorySdkModuleHostApi {
    init(binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
        
        self.appearanceManagerAdaptor = AppearanceManagerAdaptor(binaryMessenger: binaryMessenger)
        
        InappstorySdkModuleHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: self)
    }
    
    var binaryMessenger: FlutterBinaryMessenger
    
    var storyListAPI = StoryListAPI()
    
    var appearanceManagerAdaptor: AppearanceManagerAdaptor
        
    func initWith(apiKey: String, userID: String, sendStatistics: Bool) throws {
        // the parameter is responsible for logging to the XCode console
        InAppStory.shared.isLoggingEnabled = true
        // the parameter is responsible for displaying the shading under cell headers
        InAppStory.shared.cellGradientEnabled = true
        // the parameter is responsible for the color of the cell gradient of the unread story.
        InAppStory.shared.cellBorderColor = UIColor.blue
        // the parameter is responsible for displaying the bottom panel in the story card (likes, favorites and share)
        // additionally should be configured in the console
        //        InAppStory.shared.panelSettings = PanelSettings(like: self._hasLike, favorites: self._hasFavorites, share: self._hasShare)
        // the parameter is responsible for animation of the reader display when you tap on a story cell
        InAppStory.shared.presentationStyle = .zoom
        
        InAppStory.shared.sandBox = false; // Deprecated
        
        InAppStory.shared.isStatisticDisabled = !sendStatistics
        
        InAppStory.shared.initWith(serviceKey: apiKey, settings: Settings(userID: userID))
        
        StoryListAdaptor(binaryMessenger: binaryMessenger, storyListAPI: storyListAPI)
        
        StoriesListUpdateHandlerAdaptor(binaryMessenger: binaryMessenger, storyListAPI: storyListAPI)
        
        CallToActionCallbackAdaptor(binaryMessenger:  binaryMessenger)
    }
    
    func getStories(feed: String) throws {
        self.storyListAPI.setNewFeed(feed)
    }
    
    func setPlaceholders(newPlaceholders: [String : String]) throws {
        InAppStory.shared.placeholders = newPlaceholders
    }
    
    func setTags(tags: [String]) throws {
        InAppStory.shared.settings?.tags = tags
        InAppStory.shared.setTags(tags)
    }
}
