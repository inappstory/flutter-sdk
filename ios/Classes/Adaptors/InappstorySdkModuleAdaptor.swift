//
//  InappstorySdkModuleAdaptor.swift
//  inappstory_plugin
//
//  Created by Sergey Salnikov on 29.10.2024.
//

import Flutter
import Foundation
@_spi(IAS_API) import InAppStorySDK

class InappstorySdkModuleAdaptor: InappstorySdkModuleHostApi {
    init(pluginRegistrar: FlutterPluginRegistrar) {
        self.pluginRegistrar = pluginRegistrar

        self.binaryMessenger = pluginRegistrar.messenger()

        self.appearanceManagerAdaptor = AppearanceManagerAdaptor(
            binaryMessenger: binaryMessenger,
            pluginRegistrar: pluginRegistrar
        )

        self.favoriteStoryListAdaptor = FavoritesStoryListAdaptor(
            binaryMessenger: binaryMessenger
        )

        self.iasSingleStoryAdaptor = IASSingleStoryAdaptor(
            binaryMessenger: binaryMessenger,
            singleStoryAPI: InAppStoryAPI.shared.singleStoryAPI
        )

        self.iasOnboardingsAdaptor = IASOnboardingsAdaptor(
            binaryMessenger: binaryMessenger,
            onboardingsAPI: InAppStoryAPI.shared.onboardingsAPI
        )

        self.iasGamesAdaptor = IASGamesAdaptor(
            binaryMessenger: binaryMessenger,
            gamesApi: InAppStoryAPI.shared.gamesAPI
        )

        self.iasMessagesAdaptor = IASMessagesAdaptor(
            binaryMessenger: binaryMessenger,
            inAppMessagesApi: InAppStoryAPI.shared.inappmessagesAPI
        )

        self.inAppStoryManagerAdaptor = InAppStoryManagerAdaptor(
            binaryMessenger: binaryMessenger
        )

        self.statManagerAdaptor = IASStatisticsManagerAdaptor(
            binaryMessenger: binaryMessenger
        )

        InappstorySdkModuleHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }

    var binaryMessenger: FlutterBinaryMessenger

    var pluginRegistrar: FlutterPluginRegistrar

    var favoriteStoryListAdaptor: StoryListAdaptor

    var appearanceManagerAdaptor: AppearanceManagerAdaptor

    var iasSingleStoryAdaptor: IASSingleStoryAdaptor

    var iasOnboardingsAdaptor: IASOnboardingsAdaptor

    var iasGamesAdaptor: IASGamesAdaptor

    var iasMessagesAdaptor: IASMessagesAdaptor

    var inAppStoryManagerAdaptor: InAppStoryManagerAdaptor

    var statManagerAdaptor: IASStatisticsManagerAdaptor

    var feedStoryListAdaptors: [FeedStoryListAdaptor] = []

    func initWith(
        apiKey: String,
        userID: String,
        anonymous: Bool,
        userSign: String?,
        languageCode: String?,
        languageRegion: String?,
        cacheSize: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        InAppStory.shared.isLoggingEnabled = true
        //InAppStory.shared.cellGradientEnabled = true
        //InAppStory.shared.cellBorderColor = UIColor.blue
        //InAppStory.shared.presentationStyle = .zoom

        InAppStory.shared.logger = LoggerCallbackAdaptor(binaryMessenger: binaryMessenger)
        
        var locale: String? = nil
        if (languageCode != nil) && (languageRegion != nil) {
            let str2: String = "_"
            locale = "\(languageCode!)\(str2)\(languageRegion!)"
        }

        InAppStoryAPI.shared.plaform = ExternalPlatforms.flutter

        InAppStory.shared.initWith(
            serviceKey: apiKey,
            settings: Settings(
                userID: userID,
                sign: userSign,
                anonymous: anonymous,
                lang: locale
            )
        )

        GameEventCallbackAdaptor(binaryMessenger: binaryMessenger)

        CallbacksAdaptor(binaryMessenger: binaryMessenger)

        InAppMessageCallbacksAdaptor(binaryMessenger: binaryMessenger)

        CallToActionCallbackAdaptor(binaryMessenger: binaryMessenger)

        completion(.success(()))
    }

    func createListAdaptor(feed: String) {
        let newAdaptor = FeedStoryListAdaptor(
            binaryMessenger: binaryMessenger,
            feed: feed
        )
        feedStoryListAdaptors.append(newAdaptor)
    }

    func removeListAdaptor(feed: String) {
        feedStoryListAdaptors.removeAll { $0.uniqueId == feed }
    }
}
