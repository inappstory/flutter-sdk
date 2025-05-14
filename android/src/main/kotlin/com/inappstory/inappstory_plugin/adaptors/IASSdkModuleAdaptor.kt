package com.inappstory.inappstory_plugin.adaptors

import InappstorySdkModuleHostApi
import com.inappstory.inappstory_plugin.callbacks.CallToActionCallbackAdaptor
import com.inappstory.inappstory_plugin.callbacks.ErrorCallbackAdaptor
import com.inappstory.inappstory_plugin.callbacks.InAppStoryCallbacksAdaptor
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.externalapi.InAppStoryAPI
import com.inappstory.sdk.lrudiskcache.CacheSize
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.lang.reflect.Field

class InappstorySdkModuleAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val activityHolder: ActivityHolder,
) : InappstorySdkModuleHostApi {

    private val inAppStoryAPI = InAppStoryAPI()
    private val appearanceManager = AppearanceManager()
    private val appearanceManagerAdaptor =
        AppearanceManagerAdaptor(flutterPluginBinding, appearanceManager)
    private lateinit var inAppStoryManager: InAppStoryManager
    private lateinit var feed: IASStoryListAdaptor
    private lateinit var favorites: IASStoryListAdaptor
    private lateinit var inAppStoryCallbacks: InAppStoryCallbacksAdaptor

    private val singleStoryApi =
        IASSingleStoryAdaptor(
            flutterPluginBinding,
            appearanceManager,
            inAppStoryAPI.singleStory,
            activityHolder,
        )
    private val iasOnboardings =
        IASOnboardingsAdaptor(flutterPluginBinding, appearanceManager, inAppStoryAPI.onboardings)
    private lateinit var iasManagerAdaptor: IASManagerAdaptor

    private val iasGames =
        IASGamesAdaptor(flutterPluginBinding, inAppStoryAPI.games)

    private val iasMessages =
        IASMessagesAdaptor(flutterPluginBinding, inAppStoryAPI.inAppMessage, activityHolder)

    override fun initWith(
        apiKey: String, userID: String, sendStatistics: Boolean, callback: (Result<Unit>) -> Unit
    ) {
        try {
            inAppStoryManager = inAppStoryAPI.inAppStoryManager.create(
                apiKey,
                userID,
                null,
                null,
                null,
                null,
                null,
                null,
                true,
                null,
                CacheSize.MEDIUM,
                false,
            )
            inAppStoryManager.let {
                val f1: Field = it.javaClass.getDeclaredField("sendStatistic")
                f1.isAccessible = true
                f1.set(it, sendStatistics)
            }

            val iasStoryList = inAppStoryAPI.storyList

            feed = IASStoryListAdaptor(
                flutterPluginBinding,
                appearanceManager,
                iasStoryList,
                inAppStoryAPI,
                activityHolder,
            )

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
                IASManagerAdaptor(flutterPluginBinding, inAppStoryManager)
            inAppStoryCallbacks =
                InAppStoryCallbacksAdaptor(flutterPluginBinding, inAppStoryAPI.callbacks)

            callback(Result.success(Unit))
        } catch (throwable: Throwable) {
            callback(Result.failure(throwable))
        }
    }
}