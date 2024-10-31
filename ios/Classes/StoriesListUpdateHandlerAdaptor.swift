//
//  StoriesListUpdateHandlerAdaptor.swift
//  inappstory_plugin
//
//  Created by Sergey Salnikov on 29.10.2024.
//

import Foundation
import Flutter
@_spi(IAS_API) import InAppStorySDK

class StoriesListUpdateHandlerAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger, storyListAPI: StoryListAPI) {
        self.binaryMessenger = binaryMessenger
        
        self.flutter = InAppStoryAPIListSubscriberFlutterApi(binaryMessenger: binaryMessenger)
        
        self.storyListAPI = storyListAPI
        
        storyListAPI.storyListUpdate = storiesListUpdateHandler
        
        storyListAPI.storyUpdate = storyUpdateHandler
    }
    
    private var binaryMessenger: FlutterBinaryMessenger
    
    private var storyListAPI: StoryListAPI
    
    private var flutter: InAppStoryAPIListSubscriberFlutterApi
    
    private lazy var storiesListUpdateHandler: StoriesListUpdateHandler = { storiesList, isFavorite, feed in
        self.storyListAPI.setVisibleWith(storyIDs: storiesList.map{ $0.storyID })
        
        self.flutter.updateStoriesData(list: storiesList.map(self.mapStoryAPIData), completion: {_ in })
    }
    
    private lazy var storyUpdateHandler: StoryUpdateHandler = { storyCellData in
        self.flutter.updateStoryData(var1: self.mapStoryAPIData(arg: storyCellData), completion: {_ in })
    }
    
    private func mapStoryAPIData(arg: StoryCellData) -> StoryAPIDataDto {
        return StoryAPIDataDto(
            id: Int64(arg.storyID)!,
            storyData: mapStoryData(arg: arg.storyData),
            imageFilePath: arg.coverImagePath,
            videoFilePath: arg.coverVideoPath,
            hasAudio: arg.hasAudio,
            title: arg.title,
            titleColor: arg.titleColor,
            backgroundColor: arg.backgroundColor,
            opened: arg.opened,
            aspectRatio: Double(storyListAPI.cellRatio)
        )
    }
    
    private func mapStoryData(arg: StoryData) -> StoryDataDto {
        return StoryDataDto(
            id: Int64(arg.id ?? "-1")!,
            title: arg.title ?? "",
            tags: "", // TODO map array of tags to string
            feed: arg.feed,
            sourceType: mapStorySource(arg: arg.source),
            slidesCount: Int64(arg.slidesCount),
            storyType: mapStoryType(arg: arg.type)
        )
    }

    private func mapStoryType(arg: StoryType) -> StoryTypeDto {
        switch arg {
        case .story: return StoryTypeDto.cOMMON
        case .storyUGC: return StoryTypeDto.uGC
        }
    }

    private func mapStorySource(arg: StorySource) -> SourceTypeDto {
        switch arg {
        case .favorite: return SourceTypeDto.fAVORITE
        case .list: return SourceTypeDto.lIST
        case .onboarding: return SourceTypeDto.oNBOARDING
        case .single: return SourceTypeDto.sINGLE
    //    case FIXME NO stack: return SourceTypeDto.sTACK
        }
    }
}
