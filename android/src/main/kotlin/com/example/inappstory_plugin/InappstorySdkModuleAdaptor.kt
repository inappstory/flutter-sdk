package com.example.inappstory_plugin

import InappstorySdkModuleHostApi
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.externalapi.InAppStoryAPI
import com.inappstory.sdk.externalapi.storylist.IASStoryList
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.lang.reflect.Field

class InappstorySdkModuleAdaptor(
        private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
) : InappstorySdkModuleHostApi {

    private val inAppStoryAPI = InAppStoryAPI()
    private val appearanceManager = AppearanceManager()
    private val appearanceManagerAdaptor = AppearanceManagerAdaptor(flutterPluginBinding, appearanceManager)
    private lateinit var inAppStoryManager: InAppStoryManager
    private lateinit var feed: IASStoryListAdaptor
    private lateinit var favorites: IASStoryListAdaptor

    override fun initWith(
            apiKey: String,
            userID: String,
            sendStatistics: Boolean
    ) {
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
                false,
        )
        inAppStoryManager.let {
            val f1: Field = it.javaClass.getDeclaredField("sendStatistic")
            f1.isAccessible = true
            f1.set(it, sendStatistics)
        }

        val iasStoryList = IASStoryList()

        feed = IASStoryListAdaptor(
                flutterPluginBinding,
                appearanceManager,
                iasStoryList,
                inAppStoryAPI,
        )

        favorites = IASFavoritesListAdaptor(
                flutterPluginBinding,
                appearanceManager,
                iasStoryList,
                inAppStoryAPI,
        )

        inAppStoryManager.setCallToActionCallback(CallToActionCallbackAdaptor(flutterPluginBinding))

        inAppStoryManager.setErrorCallback(ErrorCallbackAdaptor(flutterPluginBinding))
    }

    override fun setPlaceholders(newPlaceholders: Map<String, String>) {
        inAppStoryManager.placeholders = newPlaceholders
    }

    override fun setTags(tags: List<String>) {
        val arrayList = ArrayList<String>()
        arrayList.addAll(tags)
        inAppStoryManager.tags = arrayList
    }
}