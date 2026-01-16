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
        feed: String,
        uniqueId: String
    ) {
        self.binaryMessenger = binaryMessenger

        self.uniqueId = uniqueId
        self.feed = feed

        self.storyListAPI = storyListAPI

        setupAdaptors()
    }

    internal func setupAdaptors() {
        StoriesListUpdateHandlerAdaptor(
            binaryMessenger: binaryMessenger,
            storyListAPI: storyListAPI,
            feed: feed,
            uniqueId: uniqueId
        )
        IASStoryListHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self,
            messageChannelSuffix: uniqueId
        )
    }

    public var uniqueId: String
    public var feed: String

    internal var binaryMessenger: FlutterBinaryMessenger

    var storyListAPI: StoryListAPI

    func load(feed: String, uniqueId: String) throws {
        // Noop use impls for Feed & Favorites
    }

    func reloadFeed(feed: String) throws {
        storyListAPI.refresh(feed)
    }

    func openStoryReader(storyId: Int64, feed: String) throws {
        storyListAPI.selectStoryCellWith(id: String(storyId))
    }

    func showFavoriteItem(feed: String) throws {
        storyListAPI.setVisibleFavorite()
    }

    func updateVisiblePreviews(storyIds: [Int64], feed: String) throws {
        self.storyListAPI.setVisibleWith(storyIDs: storyIds.map { String($0) })
    }

    func removeSubscriber(feed: String) throws {
        // not used in iOS
    }
}

class FeedStoryListAdaptor: StoryListAdaptor {
    init(
        binaryMessenger: FlutterBinaryMessenger,
        feed: String,
        uniqueId: String
    ) {
        super.init(
            binaryMessenger: binaryMessenger,
            storyListAPI: StoryListAPI(feed: feed),
            feed: feed,
            uniqueId: uniqueId
        )
    }

    override func load(feed: String, uniqueId: String) throws {
        storyListAPI.getStoriesList()
    }
}

class FavoritesStoryListAdaptor: StoryListAdaptor {
    init(binaryMessenger: FlutterBinaryMessenger) {
        super.init(
            binaryMessenger: binaryMessenger,
            storyListAPI: StoryListAPI(isFavorite: true),
            feed: "favorites",
            uniqueId: "favorites"
        )
    }

    override func setupAdaptors() {
        FavoriteStoriesListUpdateHandlerAdaptor(
            binaryMessenger: binaryMessenger,
            storyListAPI: storyListAPI,
            feed: feed,
            uniqueId: uniqueId
        )

        IASStoryListHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self,
            messageChannelSuffix: uniqueId
        )
    }

    override func load(feed: String, uniqueId: String) throws {
        storyListAPI.getStoriesList()
    }
}
