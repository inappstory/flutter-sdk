package com.inappstory.inappstory_plugin.callbacks

import SingleLoadCallbackFlutterApi
import com.inappstory.inappstory_plugin.mapStoryData
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.stories.outercallbacks.common.reader.StoryData
import com.inappstory.sdk.stories.outercallbacks.common.single.SingleLoadCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin

class SingleLoadCallbackAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
) : SingleLoadCallback {
    private val flutterApi = SingleLoadCallbackFlutterApi(flutterPluginBinding.binaryMessenger)

    override fun singleLoadSuccess(storyData: StoryData?) {
        if (storyData == null) return

        flutterPluginBinding.runOnMainThread {
            flutterApi.singleLoadSuccess(mapStoryData(storyData)) {}
        }
    }

    override fun singleLoadError(p0: String?, p1: String?) {
        flutterPluginBinding.runOnMainThread {
            flutterApi.singleLoadError(p0, p1) {}
        }
    }
}