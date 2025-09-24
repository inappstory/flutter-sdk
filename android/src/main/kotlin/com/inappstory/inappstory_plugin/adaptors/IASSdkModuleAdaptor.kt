package com.inappstory.inappstory_plugin.adaptors

import InappstorySdkModuleHostApi
import com.inappstory.inappstory_plugin.callbacks.CallToActionCallbackAdaptor
import com.inappstory.inappstory_plugin.callbacks.ErrorCallbackAdaptor
import com.inappstory.inappstory_plugin.callbacks.InAppMessageCallbackAdaptor
import com.inappstory.inappstory_plugin.callbacks.InAppStoryCallbacksAdaptor
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.externalapi.ExternalPlatforms
import com.inappstory.sdk.externalapi.InAppStoryAPI
import com.inappstory.sdk.lrudiskcache.CacheSize
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.util.Locale

class InappstorySdkModuleAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val activityHolder: ActivityHolder,
) : InappstorySdkModuleHostApi {

    private val inAppStoryAPI = InAppStoryAPI()
    private val appearanceManager = AppearanceManager()
    private lateinit var appearanceManagerAdaptor: AppearanceManagerAdaptor
    private lateinit var inAppStoryManager: InAppStoryManager
    private lateinit var iasManagerAdaptor: IASManagerAdaptor
    private lateinit var statManagerAdaptor: IASStatisticsManagerAdaptor

    private lateinit var inAppStoryCallbacks: InAppStoryCallbacksAdaptor
    private lateinit var inAppMessageCallbacks: InAppMessageCallbackAdaptor

    private lateinit var favorites: IASStoryListAdaptor
    private lateinit var singleStoryApi: IASSingleStoryAdaptor
    private lateinit var iasOnboardings: IASOnboardingsAdaptor

    private lateinit var iasGames: IASGamesAdaptor

    private lateinit var iasMessages: IASMessagesAdaptor

    private var feedListAdaptors: MutableList<IASStoryListAdaptor> = mutableListOf()

    override fun initWith(
        apiKey: String,
        userID: String,
        anonymous: Boolean,
        userSign: String?,
        languageCode: String?,
        languageRegion: String?,
        cacheSize: String?,
        callback: (Result<Unit>) -> Unit
    ) {
        try {
            var locale: Locale? = null
            if (!languageCode.isNullOrEmpty() && !languageRegion.isNullOrEmpty()) {
                locale = Locale(languageCode, languageRegion)
            }
            inAppStoryAPI.setExternalPlatform(ExternalPlatforms.FLUTTER_SDK);
            feedListAdaptors.clear()

            val cacheSizeNative = when (cacheSize) {
                "small" -> CacheSize.SMALL
                "medium" -> CacheSize.MEDIUM
                "large" -> CacheSize.LARGE
                null -> CacheSize.MEDIUM
                else ->
                    CacheSize.MEDIUM
            }

            if (anonymous) {
                inAppStoryManager = createAnonymousInAppStoryManager(
                    apiKey,
                    locale,
                    cacheSizeNative,
                )
            } else {
                inAppStoryManager = inAppStoryAPI.inAppStoryManager.create(
                    apiKey,
                    userID,
                    userSign,
                    locale,
                    null,
                    null,
                    null,
                    null,
                    false,
                    true,
                    cacheSizeNative,
                    false,
                )
            }

            val iasStoryList = inAppStoryAPI.storyList

            favorites = IASFavoritesListAdaptor(
                flutterPluginBinding,
                appearanceManager,
                iasStoryList,
                inAppStoryAPI,
                activityHolder,
            )

            inAppStoryManager.setCallToActionCallback(
                CallToActionCallbackAdaptor(
                    flutterPluginBinding
                )
            )

            inAppStoryManager.setErrorCallback(ErrorCallbackAdaptor(flutterPluginBinding))

            iasManagerAdaptor =
                IASManagerAdaptor(flutterPluginBinding, inAppStoryAPI, inAppStoryManager)
            statManagerAdaptor = IASStatisticsManagerAdaptor(flutterPluginBinding, inAppStoryAPI)
            inAppStoryCallbacks =
                InAppStoryCallbacksAdaptor(
                    flutterPluginBinding,
                    inAppStoryAPI.callbacks
                ) { slideData ->
                    feedListAdaptors.forEach {
                        it.apiSubscriber.scrollToStory(slideData)
                    }
                }

            inAppMessageCallbacks =
                InAppMessageCallbackAdaptor(flutterPluginBinding, inAppStoryManager)

            appearanceManagerAdaptor =
                AppearanceManagerAdaptor(flutterPluginBinding, appearanceManager, activityHolder)

            singleStoryApi = IASSingleStoryAdaptor(
                flutterPluginBinding,
                appearanceManager,
                inAppStoryAPI.singleStory,
                activityHolder,
            )

            iasOnboardings =
                IASOnboardingsAdaptor(
                    flutterPluginBinding,
                    appearanceManager,
                    inAppStoryAPI.onboardings
                )

            iasMessages = IASMessagesAdaptor(
                flutterPluginBinding,
                inAppStoryAPI.inAppMessage,
                inAppStoryManager,
                activityHolder,
                null
            )

            iasGames = IASGamesAdaptor(flutterPluginBinding, inAppStoryAPI.games)
            callback(Result.success(Unit))
        } catch (throwable: Throwable) {
            callback(Result.failure(throwable))
        }
    }

    override fun createListAdaptor(feed: String) {
        val iasStoryList = inAppStoryAPI.storyList

        val newFeed = IASStoryListAdaptor(
            flutterPluginBinding,
            appearanceManager,
            iasStoryList,
            inAppStoryAPI,
            activityHolder,
            uniqueId = feed
        )
        feedListAdaptors.add(newFeed)
    }


    override fun removeListAdaptor(feed: String) {
        val iterator = feedListAdaptors.iterator()
        while (iterator.hasNext()) {
            if (iterator.next().uniqueId == feed) {
                iterator.remove()
            }
        }
    }

    private fun createAnonymousInAppStoryManager(
        apiKey: String?,
        lang: Locale?,
        cacheSize: Int?,
    ): InAppStoryManager {
        var builder = InAppStoryManager.Builder()
        builder.lang(Locale.getDefault())

        if (lang != null) {
            builder = builder.lang(lang)
        }

        if (cacheSize != null) {
            builder = builder.cacheSize(cacheSize)
        }

        builder = builder.gameDemoMode(false)

        return builder.apiKey(apiKey).anonymous(true).create()
    }
}