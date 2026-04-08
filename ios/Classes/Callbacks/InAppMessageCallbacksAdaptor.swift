import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class InAppMessageCallbacksAdaptor {
    init(
        binaryMessenger: FlutterBinaryMessenger,
        ctaCallback: CallToActionCallbackFlutterApi
    ) {
        iamCallbackFlutterApi = IASInAppMessagesCallbacksFlutterApi(
            binaryMessenger: binaryMessenger
        )
        self.ctaCallback = ctaCallback

        InAppStory.shared.inAppMessagesEvent = inAppMessagesEvent
    }

    private var iamCallbackFlutterApi: IASInAppMessagesCallbacksFlutterApi
    private var ctaCallback: CallToActionCallbackFlutterApi

    private func inAppMessagesEvent(event: IASEvent.IAMessage) {
        switch event {
        case .preloaded(_):
            break
        case .show(let iamData):
            let messageData = mapInAppMessageData(arg: iamData)
            self.iamCallbackFlutterApi.onShowInAppMessage(
                inAppMessageData: messageData
            ) { _ in }
            break
        case .close(let iamData):
            let messageData = mapInAppMessageData(arg: iamData)
            self.iamCallbackFlutterApi.onCloseInAppMessage(
                inAppMessageData: messageData
            ) { _ in }
            break
        case .clickOnButton(let iamData, let link):
            self.ctaCallback.callToAction(
                slideData: nil,
                url: link,
                clickAction: nil
            ) { _ in }
            break
        case .widgetEvent(let iamData, let name, let data):
            let messageData = mapInAppMessageData(arg: iamData)
            self.iamCallbackFlutterApi.onInAppMessageWidgetEvent(
                inAppMessageData: messageData,
                name: name,
                data: data
            ) { _ in }
            return
        case .showSlide(let iamSlideData):
            break
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
            event: arg.campaign
        )
    }
}
