package com.inappstory.inappstory_plugin.adaptors

import InAppStoryManagerHostApi
import com.inappstory.inappstory_plugin.helpers.CustomOpenStoriesReader
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.banners.BannerPlaceLoadSettings
import com.inappstory.sdk.core.data.models.InAppStoryUserSettings
import com.inappstory.sdk.externalapi.InAppStoryAPI
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

    override fun closeReaders(callback: (Result<Unit>) -> Unit) {
        InAppStoryManager.closeStoryReader(
            true
        ) {
            callback.invoke(Result.success(Unit))
        }
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

    override fun setUserSettings(
        anonymous: Boolean?,
        userId: String?,
        userSign: String?,
        newLanguageCode: String?,
        newLanguageRegion: String?,
        newTags: List<String>?,
        newPlaceholders: Map<String, String>?
    ) {
        var newLocale: Locale? = null;
        if (!newLanguageCode.isNullOrEmpty() && !newLanguageRegion.isNullOrEmpty()) {
            newLocale = Locale(newLanguageCode, newLanguageRegion)
        }
        var settings = InAppStoryUserSettings()
        if (anonymous != null) {
            settings = settings.anonymous(anonymous)
        }
        inAppStoryManager.userSettings(
            settings
                .userId(userId, userSign)
                .lang(newLocale)
                .tags(newTags)
                .placeholders(newPlaceholders)
        )
    }

    override fun setLang(languageCode: String, languageRegion: String) {
        val locale = Locale(languageCode, languageRegion)
        inAppStoryManager.setLang(locale)
    }

    override fun loadBannerPlace(placeId: String, tags: List<String>?) {
        inAppStoryManager.loadBannerPlace(
            BannerPlaceLoadSettings()
                .placeId(placeId)
                .tags(tags)
        )
    }

    override fun setOptionKeys(options: Map<String, String>) {
        inAppStoryManager.setOptions(options)
    }
}