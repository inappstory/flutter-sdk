package com.inappstory.inappstory_plugin.adaptors

import InAppStoryManagerHostApi
import com.inappstory.inappstory_plugin.helpers.CustomOpenStoriesReader
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.externalapi.InAppStoryAPI
import com.inappstory.sdk.stories.ui.reader.ForceCloseReaderCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import java.util.Locale

class IASManagerAdaptor(
    flutterPluginBinding: FlutterPluginBinding,
    private val inAppStoryAPI: InAppStoryAPI,
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

    override fun changeUser(userId: String, userSign: String?, callback: (Result<Unit>) -> Unit) {
        inAppStoryManager.setUserId(userId, userSign)
        callback(Result.success(Unit))
    }

    override fun userLogout() {
        inAppStoryManager.userLogout()
    }

    override fun closeReaders() {
        InAppStoryManager.closeStoryReader(
            true, ForceCloseReaderCallback {})
    }

    override fun clearCache() {
        inAppStoryAPI.clearCache()
    }

    override fun setTransparentStatusBar() {
        inAppStoryManager.setOpenStoriesReader(CustomOpenStoriesReader())
    }

    override fun changeSound(value: Boolean) {
        inAppStoryManager.soundOn(value)
    }

    override fun setLang(languageCode: String, languageRegion: String) {
        val locale = Locale(languageCode, languageRegion)
        inAppStoryManager.setLang(locale)
    }
}