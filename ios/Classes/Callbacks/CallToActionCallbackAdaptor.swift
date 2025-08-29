//
//  CallToActionCallbackAdaptor.swift
//  inappstory_plugin
//
//  Created by Sergey Salnikov on 31.10.2024.
//

import Flutter
import Foundation
import InAppStorySDK

class CallToActionCallbackAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger

        callToActionCallbackFlutterApi = CallToActionCallbackFlutterApi(
            binaryMessenger: binaryMessenger
        )

        InAppStory.shared.onActionWith = onActionWith
    }

    private var binaryMessenger: FlutterBinaryMessenger

    private var callToActionCallbackFlutterApi: CallToActionCallbackFlutterApi

    private func onActionWith(
        target: String,
        type: InAppStorySDK.ActionType,
        storyType: InAppStorySDK.StoriesType?
    ) {
        DispatchQueue.main.async { [self] in
            self.callToActionCallbackFlutterApi.callToAction(
                slideData: nil,
                url: target,
                clickAction: self.mapClickActionDto(arg: type),
                completion: { _ in }
            )
        }
    }

    private func mapClickActionDto(arg: InAppStorySDK.ActionType)
        -> ClickActionDto
    {
        switch arg {
        case .button: return ClickActionDto.bUTTON
        case .deeplink: return ClickActionDto.dEEPLINK
        case .game: return ClickActionDto.gAME
        case .swipe: return ClickActionDto.sWIPE
        @unknown default:
            fatalError()
        }
    }
}
