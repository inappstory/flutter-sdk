//
//  IASStoryListAdaptor.swift
//  inappstory_plugin
//
//  Created by Sergey Salnikov on 31.10.2024.
//

import Flutter
import Foundation
@_spi(IAS_API) import InAppStorySDK

class StoryListAdaptor: IASStoryListHostApi {
    init(
        binaryMessenger: FlutterBinaryMessenger,
        storyListAPI: StoryListAPI,
        uniqueId: String
    ) {
        self.binaryMessenger = binaryMessenger

        self.uniqueId = uniqueId

        self.storyListAPI = storyListAPI

        StoriesListUpdateHandlerAdaptor(
            binaryMessenger: binaryMessenger,
            storyListAPI: storyListAPI,
            uniqueId: uniqueId
        )

        IASStoryListHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self,
            messageChannelSuffix: uniqueId
        )
    }

    private var uniqueId: String

    private var binaryMessenger: FlutterBinaryMessenger

    var storyListAPI: StoryListAPI

    func load(feed: String) throws {
        // Noop use impls for Feed & Favorites
    }

    func openStoryReader(storyId: Int64) throws {
        storyListAPI.selectStoryCellWith(id: String(storyId))
    }

    func showFavoriteItem() throws {
        storyListAPI.setVisibleFavorite()
    }

    func updateVisiblePreviews(storyIds: [Int64]) throws {
        self.storyListAPI.setVisibleWith(storyIDs: storyIds.map { String($0) })
    }
}

class FeedStoryListAdaptor: StoryListAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger) {
        super.init(
            binaryMessenger: binaryMessenger,
            storyListAPI: StoryListAPI(),
            uniqueId: "feed"
        )
    }

    override func load(feed: String) throws {
        storyListAPI.setNewFeed(feed)
    }
}

class FavoritesStoryListAdaptor: StoryListAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger) {
        super.init(
            binaryMessenger: binaryMessenger,
            storyListAPI: StoryListAPI(isFavorite: true),
            uniqueId: "favorites"
        )
    }

    override func load(feed: String) throws {
        storyListAPI.getStoriesList()
    }
}
