package com.inappstory.inappstory_plugin.adaptors

import InAppStoryManagerHostApi
import com.inappstory.inappstory_plugin.helpers.CustomOpenStoriesReader
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.stories.ui.reader.ForceCloseReaderCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class IASManagerAdaptor(
    flutterPluginBinding: FlutterPluginBinding,
    private val inAppStoryManager: InAppStoryManager,
) : InAppStoryManagerHostApi {

    init {
        InAppStoryManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    override fun setPlaceholders(newPlaceholders: Map<String, String>) {
        inAppStoryManager.placeholders = newPlaceholders
    }

    override fun setTags(tags: List<String>) {
        val arrayList = ArrayList<String>()
        arrayList.addAll(tags)
        inAppStoryManager.tags = arrayList
    }

    override fun changeUser(userId: String, callback: (Result<Unit>) -> Unit) {
        inAppStoryManager.userId = userId

        callback(Result.success(Unit))
    }

    override fun closeReaders() {
        InAppStoryManager.closeStoryReader(
            true, ForceCloseReaderCallback {})
    }

    override fun setTransparentStatusBar() {
        inAppStoryManager.setOpenStoriesReader(CustomOpenStoriesReader())
    }
}