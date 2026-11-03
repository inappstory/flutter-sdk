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

    public var callToActionCallbackFlutterApi: CallToActionCallbackFlutterApi

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
        -> ClickActionDto?
    {
        switch arg {
        case .button: return ClickActionDto.button
        case .deeplink: return ClickActionDto.deeplink
        case .game: return ClickActionDto.game
        case .swipe: return ClickActionDto.swipe
        @unknown default:
            return nil
        }
    }
}
