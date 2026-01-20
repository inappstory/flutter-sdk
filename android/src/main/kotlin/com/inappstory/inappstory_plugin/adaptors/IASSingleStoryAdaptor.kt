package com.inappstory.inappstory_plugin.adaptors

import IASSingleStoryHostApi
import com.inappstory.inappstory_plugin.callbacks.IShowStoryCallbackAdaptor
import com.inappstory.inappstory_plugin.callbacks.SingleLoadCallbackAdaptor
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.externalapi.single.IASSingleStoryExternalAPI
import io.flutter.embedding.engine.plugins.FlutterPlugin

class IASSingleStoryAdaptor(
    flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val appearanceManager: AppearanceManager,
    private val iasSingleStory: IASSingleStoryExternalAPI,
    private val activityHolder: ActivityHolder,
) : IASSingleStoryHostApi {
    private val callback = IShowStoryCallbackAdaptor(flutterPluginBinding)

    init {
        IASSingleStoryHostApi.setUp(flutterPluginBinding.binaryMessenger, this)

        iasSingleStory.loadCallback(SingleLoadCallbackAdaptor(flutterPluginBinding))
    }

    override fun showOnce(storyId: String) {
        iasSingleStory.showOnce(
            activityHolder.activity,
            storyId,
            appearanceManager,
            callback,
        )
    }

    override fun show(storyId: String) {
        val cancelToken = iasSingleStory.show(
            activityHolder.activity,
            storyId,
            appearanceManager,
            callback,
            null,
        )
        cancelToken.cancel()
    }
}


