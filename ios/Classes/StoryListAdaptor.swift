//
//  IASStoryListAdaptor.swift
//  inappstory_plugin
//
//  Created by Sergey Salnikov on 31.10.2024.
//

import Foundation
import Flutter
@_spi(IAS_API) import InAppStorySDK

class StoryListAdaptor: IASStoryListHostApi {
    init(binaryMessenger: FlutterBinaryMessenger, storyListAPI: StoryListAPI, uniqueId: String) {
        self.binaryMessenger = binaryMessenger
        
        self.uniqueId = uniqueId
        
        self.storyListAPI = storyListAPI
        
        StoriesListUpdateHandlerAdaptor(binaryMessenger: binaryMessenger, storyListAPI: storyListAPI, uniqueId:  uniqueId)
        
        IASStoryListHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: self, messageChannelSuffix: uniqueId)
    }
    
    private var uniqueId: String
    
    private var binaryMessenger: FlutterBinaryMessenger
    
    private var storyListAPI: StoryListAPI
    
    func load(feed: String) throws {
        storyListAPI.setNewFeed(feed)
    }
    
    func openStoryReader(storyId: Int64) throws {
        storyListAPI.selectStoryCellWith(id: String(storyId))
    }
    
    func showFavoriteItem() throws {
        storyListAPI.setVisibleFavorite()
    }
    
    func updateVisiblePreviews(storyIds: [Int64]) throws {
        self.storyListAPI.setVisibleWith(storyIDs: storyIds.map{ String($0) })
    }
}
