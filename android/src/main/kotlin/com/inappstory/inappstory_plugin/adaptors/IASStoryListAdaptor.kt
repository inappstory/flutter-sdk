package com.inappstory.inappstory_plugin.adaptors

import IASStoryListHostApi
import android.app.Activity
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.core.api.IASStoryList
import com.inappstory.sdk.externalapi.InAppStoryAPI
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.DisposableHandle

open class IASStoryListAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    internal val appearanceManager: AppearanceManager,
    internal val iASStoryList: IASStoryList,
    private val inAppStoryAPI: InAppStoryAPI,
    internal val activityHolder: ActivityHolder,
    val uniqueId: String = "feed",
) : IASStoryListHostApi, DisposableHandle {

    init {
        IASStoryListHostApi.setUp(flutterPluginBinding.binaryMessenger, this, uniqueId)
        inAppStoryAPI.addSubscriber(
            InAppStoryAPIListSubscriberAdaptor(
                flutterPluginBinding,
                uniqueId
            )
        )
    }

    override fun dispose() {
        IASStoryListHostApi.setUp(flutterPluginBinding.binaryMessenger, null, uniqueId)
    }

    override fun load(feed: String) {
        iASStoryList.load(feed, feed, true, false, mutableListOf<String>())
    }

    override fun reloadFeed(feed: String) {
        iASStoryList.load(feed, feed, true, false, mutableListOf<String>())
    }

    override fun openStoryReader(storyId: Long, feed: String) {
        iASStoryList.openStoryReader(
            activityHolder.activity,
            feed,
            storyId.toInt(),
            appearanceManager,
        )
    }

    override fun showFavoriteItem(feed: String) {
        iASStoryList.showFavoriteItem(feed)
    }

    override fun updateVisiblePreviews(storyIds: List<Long>, feed: String) {
        iASStoryList.showFavoriteItem(feed)
        iASStoryList.updateVisiblePreviews(storyIds.map { it.toInt() }, feed)
    }

    override fun removeSubscriber(feed: String) {
        inAppStoryAPI.removeSubscriber(feed)
    }
}

class IASFavoritesListAdaptor(
    flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    appearanceManager: AppearanceManager,
    iASStoryList: IASStoryList,
    inAppStoryAPI: InAppStoryAPI,
    activityHolder: ActivityHolder,
) : IASStoryListAdaptor(
    flutterPluginBinding,
    appearanceManager,
    iASStoryList,
    inAppStoryAPI,
    activityHolder,
    uniqueId = "favorites"
) {
    override fun load(feed: String) {
        iASStoryList.load(feed, uniqueId, true, true, mutableListOf())
    }

    override fun reloadFeed(feed: String) {
        iASStoryList.load(feed, uniqueId, true, true, mutableListOf())
    }

    override fun openStoryReader(storyId: Long, feed: String) {
        iASStoryList.openStoryReader(
            activityHolder.activity,
            uniqueId,
            storyId.toInt(),
            appearanceManager,
        )
    }
}

interface ActivityHolder {
    val activity: Activity?
}