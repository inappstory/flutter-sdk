package com.example.inappstory_plugin

import IASSingleStoryHostApi
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.externalapi.single.IASSingleStory
import io.flutter.embedding.engine.plugins.FlutterPlugin

class IASSingleStoryAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val appearanceManager: AppearanceManager,
    private val iasSingleStory: IASSingleStory,
    private val activityHolder: ActivityHolder,
) : IASSingleStoryHostApi {
    private val callback = IShowStoryOnceCallbackAdaptor(flutterPluginBinding)

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
        iasSingleStory.show(
            activityHolder.activity,
            storyId,
            appearanceManager,
            callback,
            null,
        )
    }
}


