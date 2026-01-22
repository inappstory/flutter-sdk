import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class GameEventCallbackAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger) {
        gameReaderCallbackFlutterApi = GameReaderCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        InAppStory.shared.gameEvent = gameEvent
    }
    private var gameReaderCallbackFlutterApi: GameReaderCallbackFlutterApi

    private func gameEvent(event: IASEvent.Game) {

        switch event {
        case .startGame(let gameData):
            DispatchQueue.main.async { [self] in
                gameReaderCallbackFlutterApi.startGame(
                    contentData: mapContentData(arg: gameData),
                    completion: { _ in }
                )
            }
        case .closeGame(let gameData):
            DispatchQueue.main.async { [self] in
                gameReaderCallbackFlutterApi.closeGame(
                    contentData: mapContentData(arg: gameData),
                    completion: { _ in }
                )
            }
//        case .finishGame(let gameData, let result):
//            DispatchQueue.main.async { [self] in
//                gameReaderCallbackFlutterApi.finishGame(
//                    contentData: mapContentData(arg: gameData),
//                    result: result,
//                    completion: { _ in }
//                )
//            }
        case .eventGame(let gameData, let name, let payload):
            DispatchQueue.main.async { [self] in
                gameReaderCallbackFlutterApi.eventGame(
                    contentData: mapContentData(arg: gameData),
                    gameId: nil,
                    eventName: name,
                    payload: payload,
                    completion: { _ in }
                )
            }
        case .gameFailure(let gameData, let message):
            DispatchQueue.main.async { [self] in
                gameReaderCallbackFlutterApi.gameError(
                    contentData: mapContentData(arg: gameData),
                    message: message,
                    completion: { _ in }
                )
            }
        @unknown default:
            NSLog("WARNING: unknown failureEvent")
        }
    }

    private func mapContentType(arg: StoryType?) -> ContentTypeDto {
        switch arg {
        case .story: return ContentTypeDto.sTORY
        case .iam: return ContentTypeDto.iNAPPMESSAGE
        case .storyUGC: return ContentTypeDto.uGC
        @unknown default:
            NSLog("WARNING: unknown StoryType")
            return ContentTypeDto.sTORY
        }
    }

    private func mapSourceType(arg: StorySource?) -> SourceTypeDto {
        switch arg {
        case .single: return SourceTypeDto.sINGLE
        case .onboarding: return SourceTypeDto.oNBOARDING
        case .favorite: return SourceTypeDto.fAVORITE
        case .list: return SourceTypeDto.lIST
        @unknown default:
            NSLog("WARNING: unknown StorySource")
            return SourceTypeDto.sINGLE
        }
    }

    private func mapContentData(arg: GameStoryData) -> ContentDataDto {
        return ContentDataDto(
            contentType: mapContentType(arg: arg.slideData?.storyData?.type),
            sourceType: mapSourceType(arg: arg.slideData?.storyData?.source)
        )
    }
}
