package com.example.inappstory_plugin

import IASStoryListHostApi
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.externalapi.storylist.IASStoryList
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.DisposableHandle

class IASStoryListAdaptor(
        private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
        private val appearanceManager: AppearanceManager,
        private val uniqueId: String,
) : IASStoryListHostApi, DisposableHandle {
    init {
        IASStoryListHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    override fun dispose() {
        IASStoryListHostApi.setUp(flutterPluginBinding.binaryMessenger, null)
    }

    private val adapted = IASStoryList()
    override fun load(feed: String, hasFavorite: Boolean, isFavorite: Boolean) {
        adapted.load(feed, uniqueId, hasFavorite, isFavorite, mutableListOf())
    }

    override fun openStoryReader(storyId: Long) {
        adapted.openStoryReader(
                flutterPluginBinding.applicationContext,
                uniqueId,
                storyId.toInt(),
                appearanceManager,
        )
    }

    override fun showFavoriteItem() {
        TODO("Not yet implemented")
    }

    override fun updateVisiblePreviews(storyIds: List<Long>) {
        TODO("Not yet implemented")
    }


}