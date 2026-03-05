import Flutter
import Foundation
import InAppStorySDK

class ErrorCallbackAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger) {
        errorCallbackFlutterApi = ErrorCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )
        singleLoadCallbackFlutterApi = SingleLoadCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        InAppStory.shared.failureEvent = failureEvent
    }
    private var errorCallbackFlutterApi: ErrorCallbackFlutterApi
    private var singleLoadCallbackFlutterApi: SingleLoadCallbackFlutterApi

    private func failureEvent(failure: IASEvent.Failure) {
        DispatchQueue.main.async { [self] in
            switch failure {
            case .sessionFailure(_):
                errorCallbackFlutterApi.sessionError { _ in }
            case .storyFailure(let message):
                singleLoadCallbackFlutterApi.singleLoadError(
                    storyId: nil,
                    reason: message,
                    completion: { _ in }
                )
            case .currentStoryFailure(let message):
                singleLoadCallbackFlutterApi.singleLoadError(
                    storyId: nil,
                    reason: message,
                    completion: { _ in }
                )
            case .networkFailure(_):
                errorCallbackFlutterApi.noConnection { _ in }
            case .requestFailure(_, _):
                errorCallbackFlutterApi.sessionError { _ in }
            @unknown default:
                NSLog("WARNING: unknown failureEvent")
            }
        }
    }
}
