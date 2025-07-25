package com.inappstory.inappstory_plugin.adaptors

import InappstorySdkModuleHostApi
import com.inappstory.inappstory_plugin.callbacks.CallToActionCallbackAdaptor
import com.inappstory.inappstory_plugin.callbacks.ErrorCallbackAdaptor
import com.inappstory.inappstory_plugin.callbacks.InAppMessageCallbackAdaptor
import com.inappstory.inappstory_plugin.callbacks.InAppStoryCallbacksAdaptor
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.InAppStoryManager
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
    private val appearanceManagerAdaptor =
        AppearanceManagerAdaptor(flutterPluginBinding, appearanceManager)
    private lateinit var inAppStoryManager: InAppStoryManager
    private lateinit var favorites: IASStoryListAdaptor
    private lateinit var inAppStoryCallbacks: InAppStoryCallbacksAdaptor
    private lateinit var inAppMessageCallbacks: InAppMessageCallbackAdaptor
    private lateinit var statManagerAdaptor: IASStatisticsManagerAdaptor

    private val singleStoryApi = IASSingleStoryAdaptor(
        flutterPluginBinding,
        appearanceManager,
        inAppStoryAPI.singleStory,
        activityHolder,
    )
    private val iasOnboardings =
        IASOnboardingsAdaptor(flutterPluginBinding, appearanceManager, inAppStoryAPI.onboardings)
    private lateinit var iasManagerAdaptor: IASManagerAdaptor

    private val iasGames = IASGamesAdaptor(flutterPluginBinding, inAppStoryAPI.games)

    private val iasMessages =
        IASMessagesAdaptor(flutterPluginBinding, inAppStoryAPI.inAppMessage, activityHolder)

    private var feedListAdaptors: MutableList<IASStoryListAdaptor> = mutableListOf()

    override fun initWith(
        apiKey: String,
        userID: String,
        languageCode: String?,
        languageRegion: String?,
        callback: (Result<Unit>) -> Unit
    ) {
        try {
            var locale: Locale? = null
            if (!languageCode.isNullOrEmpty() && !languageRegion.isNullOrEmpty()) {
                locale = Locale(languageCode, languageRegion)
            }
            feedListAdaptors.clear()
            inAppStoryManager = inAppStoryAPI.inAppStoryManager.create(
                apiKey,
                userID,
                null,
                locale,
                null,
                null,
                null,
                null,
                true,
                null,
                CacheSize.MEDIUM,
                false,
            )

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

            iasManagerAdaptor = IASManagerAdaptor(flutterPluginBinding, inAppStoryManager)
            statManagerAdaptor = IASStatisticsManagerAdaptor(flutterPluginBinding, inAppStoryAPI)
            inAppStoryCallbacks =
                InAppStoryCallbacksAdaptor(flutterPluginBinding, inAppStoryAPI.callbacks)

            inAppMessageCallbacks =
                InAppMessageCallbackAdaptor(flutterPluginBinding, inAppStoryManager)

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
}