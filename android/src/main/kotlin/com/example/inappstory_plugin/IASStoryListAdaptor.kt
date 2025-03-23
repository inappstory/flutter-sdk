package com.example.inappstory_plugin

import IASStoryListHostApi
import android.app.Activity
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.externalapi.InAppStoryAPI
import com.inappstory.sdk.externalapi.storylist.IASStoryList
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.DisposableHandle

open class IASStoryListAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val appearanceManager: AppearanceManager,
    internal val iASStoryList: IASStoryList,
    private val inAppStoryAPI: InAppStoryAPI,
    private val activityHolder: ActivityHolder,
) : IASStoryListHostApi, DisposableHandle {
    open fun uniqueId(): String {
        return "feed"
    }

    init {
        IASStoryListHostApi.setUp(flutterPluginBinding.binaryMessenger, this, uniqueId())

        inAppStoryAPI.addSubscriber(InAppStoryAPIListSubscriberAdaptor(flutterPluginBinding, uniqueId()))
    }

    override fun dispose() {
        IASStoryListHostApi.setUp(flutterPluginBinding.binaryMessenger, null, uniqueId())
    }

    override fun load(feed: String) {
        iASStoryList.load(feed, uniqueId(), true, false, mutableListOf())
    }

    override fun openStoryReader(storyId: Long) {
        iASStoryList.openStoryReader(
            activityHolder.activity,
            uniqueId(),
            storyId.toInt(),
            appearanceManager,
        )
    }

    override fun showFavoriteItem() {
        iASStoryList.showFavoriteItem(uniqueId())
    }

    override fun updateVisiblePreviews(storyIds: List<Long>) {
        iASStoryList.showFavoriteItem(uniqueId())
        iASStoryList.updateVisiblePreviews(storyIds.map { it.toInt() }, uniqueId())
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
) {
    override fun uniqueId(): String {
        return "favorites"
    }

    override fun load(feed: String) {
        iASStoryList.load(feed, uniqueId(), true, true, mutableListOf())
    }
}

interface ActivityHolder {
    val activity: Activity?
}