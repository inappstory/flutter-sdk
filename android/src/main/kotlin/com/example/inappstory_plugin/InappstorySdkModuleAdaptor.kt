package com.example.inappstory_plugin

import InappstorySdkModuleHostApi
import com.inappstorysdk.InappstorySdkModule
import io.flutter.embedding.engine.plugins.FlutterPlugin

class InappstorySdkModuleAdaptor(
        private val adapted: InappstorySdkModule,
        private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding
) : InappstorySdkModuleHostApi {

    override fun initWith(
            apiKey: String,
            userID: String,
            sandbox: Boolean,
            sendStatistics: Boolean
    ) {
        adapted.initWith(
                apiKey = apiKey,
                userID = userID,
                sandbox = sandbox,
                sendStatistics = sendStatistics
        )

        IASStoryListAdaptor(flutterPluginBinding, adapted.appearanceManager!!, uniqueId = "feed")

        adapted.api?.addSubscriber(InAppStoryAPIListSubscriberAdaptor(flutterPluginBinding))

        adapted.ias?.setCallToActionCallback(CallToActionCallbackAdaptor(flutterPluginBinding))

        adapted.ias?.setErrorCallback(ErrorCallbackAdaptor(flutterPluginBinding))
    }

    override fun getStories(feed: String) {
        adapted.getStories(feed = feed)
    }

    override fun setPlaceholders(newPlaceholders: Map<String, String>) {
        adapted.setPlaceholders(newPlaceholders)
    }

    override fun setTags(tags: List<String>) {
        adapted.setTags(tags)
    }
}