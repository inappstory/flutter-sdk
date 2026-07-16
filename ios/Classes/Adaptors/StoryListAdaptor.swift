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
        // TEMP DIAGNOSTIC: remove before release.
        NSLog("[IAS-NATIVE] StoryListAdaptor INIT feed=\(feed) uid=\(uniqueId)")
    }

    // TEMP DIAGNOSTIC: remove before release. If this never fires after a feed
    // is unmounted, the SDK is still holding storyListAPI and the orphan lives.
    deinit {
        NSLog("[IAS-NATIVE] StoryListAdaptor DEINIT feed=\(feed) uid=\(uniqueId)")
    }

    internal func setupAdaptors() {
        updateHandlerAdaptor = StoriesListUpdateHandlerAdaptor(
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

    func dispose() {
        // TEMP DIAGNOSTIC: remove before release.
        NSLog("[IAS-NATIVE] dispose feed=\(feed) uid=\(uniqueId)")
        IASStoryListHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: nil,
            messageChannelSuffix: uniqueId
        )
        storyListAPI.storyListUpdate = nil
        storyListAPI.storyUpdate = nil
        storyListAPI.favoritesUpdate = nil
        storyListAPI.scrollUpdate = nil
        storyListAPI.storiesUpdateFailure = nil
        updateHandlerAdaptor = nil
    }

    public var uniqueId: String
    public var feed: String

    internal var binaryMessenger: FlutterBinaryMessenger

    var storyListAPI: StoryListAPI

    /// Strong owner of the update handler; without it the handler survives only
    /// via a retain cycle with storyListAPI. Cleared in `dispose()`.
    internal var updateHandlerAdaptor: StoriesListUpdateHandlerAdaptor?

    func load(feed: String, uniqueId: String) throws {
        // Noop use impls for Feed & Favorites
    }

    func reloadFeed(feed: String) throws {
        // TEMP DIAGNOSTIC: remove before release.
        NSLog("[IAS-NATIVE] reloadFeed ENTER feed=\(feed) uid=\(uniqueId) "
            + "self.feed=\(self.feed)")
        if self.feed != feed {
            storyListAPI.setNewFeed(feed)
        } else {
            storyListAPI.refresh(feed)
        }
        self.feed = feed
        NSLog("[IAS-NATIVE] reloadFeed EXIT uid=\(uniqueId)")
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
        updateHandlerAdaptor = FavoriteStoriesListUpdateHandlerAdaptor(
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
