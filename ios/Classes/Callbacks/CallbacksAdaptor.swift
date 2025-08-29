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
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onShowStory(
                    storyData: mapStoryData(arg: storyData),
                    completion: { _ in }
                )
            }
            break
        case .closeStory(let slideData, let action):
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onCloseStory(
                    slideData: mapSlideData(arg: slideData),
                    completion: { _ in }
                )
            }
            break
        case .favoriteStory(let slideData, let value):
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onFavoriteTap(
                    slideData: mapSlideData(arg: slideData),
                    isFavorite: value,
                    completion: { _ in }
                )
            }
            break
        case .storiesLoaded(_, _):
            break
        case .ugcStoriesLoaded(_):
            break
        case .clickOnStory(_, _):
            break
        case .clickOnButton(_, _):
            break
        case .showSlide(let slideData):
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onShowSlide(
                    slideData: mapSlideData(arg: slideData),
                    completion: { _ in }
                )
            }
            break
        case .likeStory(let slideData, let value):
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onLikeStoryTap(
                    slideData: mapSlideData(arg: slideData),
                    isLike: value,
                    completion: { _ in }
                )
            }
            break
        case .dislikeStory(let slideData, let value):
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onDislikeStoryTap(
                    slideData: mapSlideData(arg: slideData),
                    isDislike: value,
                    completion: { _ in }
                )
            }
            break
        case .clickOnShareStory(let slideData):
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onShareStory(
                    slideData: mapSlideData(arg: slideData),
                    completion: { _ in }
                )
            }
            break
        case .storyWidgetEvent(let slideData, let name, let data):
            DispatchQueue.main.async { [self] in
                callbackFlutterApi.onStoryWidgetEvent(
                    slideData: mapSlideData(arg: slideData!),
                    widgetData: data,
                    completion: { _ in }
                )
            }
            break
        @unknown default:
            NSLog("WARNING: unknown failureEvent")
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
