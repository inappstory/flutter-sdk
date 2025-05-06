//
//  CallbacksAdaptor.swift
//
//
//  Created by Alexander Sungurov on 29.04.2025.
//

import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class CallbacksAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger) {
        callbackFlutterApi = IASCallBacksFlutterApi(
            binaryMessenger: binaryMessenger
        )

        InAppStory.shared.storiesEvent = storiesEvent
    }

    private var callbackFlutterApi: IASCallBacksFlutterApi

    private func storiesEvent(event: IASEvent.Story) {
        switch event {
        case .showStory(let storyData, let action):
            callbackFlutterApi.onShowStory(
                storyData: mapStoryData(arg: storyData),
                completion: { _ in }
            )
        case .closeStory(let slideData, let action):
            callbackFlutterApi.onCloseStory(
                slideData: mapSlideData(arg: slideData),
                completion: { _ in }
            )
        case .favoriteStory(let slideData, let value):
            callbackFlutterApi.onFavoriteTap(
                slideData: mapSlideData(arg: slideData),
                isFavorite: value,
                completion: { _ in }
            )

        case .storiesLoaded(let feed, let stories):
            return
        case .ugcStoriesLoaded(let stories):
            return
        case .clickOnStory(let storyData, let index):
            return
        case .clickOnButton(let slideData, let link):
            return
        case .showSlide(let slideData):
            callbackFlutterApi.onShowSlide(
                slideData: mapSlideData(arg: slideData),
                completion: { _ in }
            )
            return
        case .likeStory(let slideData, let value):
            callbackFlutterApi.onLikeStoryTap(
                slideData: mapSlideData(arg: slideData),
                isLike: value,
                completion: { _ in }
            )
            return
        case .dislikeStory(let slideData, let value):
            callbackFlutterApi.onDislikeStoryTap(
                slideData: mapSlideData(arg: slideData),
                isDislike: value,
                completion: { _ in }
            )
            return
        case .clickOnShareStory(let slideData):
            callbackFlutterApi.onShareStory(
                slideData: mapSlideData(arg: slideData),
                completion: { _ in }
            )
            return
        case .storyWidgetEvent(let slideData, let name, let data):
            callbackFlutterApi.onStoryWidgetEvent(
                slideData: mapSlideData(arg: slideData!),
                widgetData: data,
                completion: { _ in }
            )
            return
        @unknown default:
            NSLog("WARNING: unknown failureEvent")
            return
        }
    }

    private func mapStoryData(arg: StoryData) -> StoryDataDto {
        return StoryDataDto(
            id: Int64(arg.id ?? "-1")!,
            title: arg.title,
            tags: "",  // TODO map array of tags to string
            feed: arg.feed,
            sourceType: mapStorySource(arg: arg.source),
            slidesCount: Int64(arg.slidesCount),
            storyType: mapStoryType(arg: arg.type)
        )
    }

    private func mapSlideData(arg: SlideData) -> SlideDataDto {
        var storyData: StoryDataDto? = nil
        if arg.storyData != nil {
            storyData = mapStoryData(arg: arg.storyData!)
        }
        return SlideDataDto(
            story: storyData,
            index: Int64(arg.index),
            payload: arg.payload ?? ""
        )
    }

    private func mapStoryType(arg: StoryType) -> StoryTypeDto {
        switch arg {
        case .story: return StoryTypeDto.cOMMON
        case .storyUGC: return StoryTypeDto.uGC
        @unknown default:
            return StoryTypeDto.cOMMON
        }
    }

    private func mapStorySource(arg: StorySource) -> SourceTypeDto {
        switch arg {
        case .favorite: return SourceTypeDto.fAVORITE
        case .list: return SourceTypeDto.lIST
        case .onboarding: return SourceTypeDto.oNBOARDING
        case .single: return SourceTypeDto.sINGLE
        @unknown default:
            return SourceTypeDto.sINGLE
        //    case FIXME NO stack: return SourceTypeDto.sTACK
        }
    }
}
