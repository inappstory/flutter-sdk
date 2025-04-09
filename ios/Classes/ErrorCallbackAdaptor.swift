import Foundation
import Flutter
import InAppStorySDK

class ErrorCallbackAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger) {
        errorCallbackFlutterApi = ErrorCallbackFlutterApi(binaryMessenger: binaryMessenger)
        singleLoadCallbackFlutterApi = SingleLoadCallbackFlutterApi(binaryMessenger: binaryMessenger)
        
        InAppStory.shared.failureEvent = failureEvent
    }
    private var errorCallbackFlutterApi: ErrorCallbackFlutterApi
    private var singleLoadCallbackFlutterApi: SingleLoadCallbackFlutterApi
    
    private func failureEvent(failure: IASEvent.Failure) {
        DispatchQueue.main.async { [self] in
            switch failure {
            case .sessionFailure(message: let message):
                errorCallbackFlutterApi.sessionError() { _ in }
            case .storyFailure(message: let message):
                singleLoadCallbackFlutterApi.singleLoadError(storyId: nil, reason: message, completion: {_ in})
            case .currentStoryFailure(message: let message):
                singleLoadCallbackFlutterApi.singleLoadError(storyId: nil, reason: message, completion: {_ in})
            case .networkFailure(message: let message):
                errorCallbackFlutterApi.noConnection { _ in }
            case .requestFailure(message: let message, statusCode: let statusCode):
                errorCallbackFlutterApi.sessionError { _ in }
            @unknown default:
                NSLog("WARNING: unknown failureEvent")
            }
        }
    }
}
