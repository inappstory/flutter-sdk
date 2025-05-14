import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class InAppMessageCallbacksAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger) {
        iamCallbackFlutterApi = IASInAppMessagesCallbacksFlutterApi(
            binaryMessenger: binaryMessenger
        )

        InAppStory.shared.inAppMessagesEvent = inAppMessagesEvent
    }

    private var iamCallbackFlutterApi: IASInAppMessagesCallbacksFlutterApi

    private func inAppMessagesEvent(event: IASEvent.IAMessage) {
        switch event {
        case .preloaded(_):
            return
        case .show(let iamData):
            let messageData = mapInAppMessageData(arg: iamData)
            iamCallbackFlutterApi.onShowInAppMessage(
                inAppMessageData: messageData
            ) { _ in }
            return
        case .close(let iamData):
            let messageData = mapInAppMessageData(arg: iamData)
            iamCallbackFlutterApi.onCloseInAppMessage(
                inAppMessageData: messageData
            ) { _ in }
            return
        case .clickOnButton(_, _):
            return
        case .widgetEvent(let iamData, let name, let data):
            let messageData = mapInAppMessageData(arg: iamData)
            iamCallbackFlutterApi.onInAppMessageWidgetEvent(
                inAppMessageData: messageData,
                name: name,
                data: data,
            ) { _ in }
            return
        @unknown default:
            NSLog("WARNING: unknown inAppMessagesEvent")
            return
        }
    }

    private func mapInAppMessageData(arg: InAppMessageData)
        -> InAppMessageDataDto
    {
        return InAppMessageDataDto(
            id: Int64(arg.id ?? "0") ?? 0,
            title: nil,
            event: arg.campaign,
        )
    }
}
