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
    init(binaryMessenger: FlutterBinaryMessenger, storyListAPI: StoryListAPI) {
        self.binaryMessenger = binaryMessenger
        
        self.storyListAPI = storyListAPI
        
        IASStoryListHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: self)
    }
    
    private var binaryMessenger: FlutterBinaryMessenger
    
    private var storyListAPI: StoryListAPI
    
    func load(feed: String, hasFavorite: Bool, isFavorite: Bool) throws {
    }
    
    func openStoryReader(storyId: Int64) throws {
        storyListAPI.selectStoryCellWith(id: String(storyId))
    }
    
    func showFavoriteItem() throws {
    }
    
    func updateVisiblePreviews(storyIds: [Int64]) throws {
    }
}
