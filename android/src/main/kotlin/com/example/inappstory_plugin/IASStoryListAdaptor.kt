package com.example.inappstory_plugin

import IASStoryListHostApi
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.externalapi.InAppStoryAPI
import com.inappstory.sdk.externalapi.storylist.IASStoryList
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.DisposableHandle

class IASStoryListAdaptor(
        private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
        private val appearanceManager: AppearanceManager,
        private val iASStoryList: IASStoryList,
        private val inAppStoryAPI: InAppStoryAPI,
        private val uniqueId: String,
) : IASStoryListHostApi, DisposableHandle {
    init {
        IASStoryListHostApi.setUp(flutterPluginBinding.binaryMessenger, this, uniqueId)

        inAppStoryAPI.addSubscriber(InAppStoryAPIListSubscriberAdaptor(flutterPluginBinding, uniqueId))
    }

    override fun dispose() {
        IASStoryListHostApi.setUp(flutterPluginBinding.binaryMessenger, null, uniqueId)
    }

    override fun load(feed: String) {
        iASStoryList.load(feed, uniqueId, true, false, mutableListOf())
    }

    override fun openStoryReader(storyId: Long) {
        iASStoryList.openStoryReader(
                flutterPluginBinding.applicationContext,
                uniqueId,
                storyId.toInt(),
                appearanceManager,
        )
    }

    override fun showFavoriteItem() {
        iASStoryList.showFavoriteItem(uniqueId)
    }

    override fun updateVisiblePreviews(storyIds: List<Long>) {
        iASStoryList.showFavoriteItem(uniqueId)
        iASStoryList.updateVisiblePreviews(storyIds.map { it.toInt() }, uniqueId)
    }
}