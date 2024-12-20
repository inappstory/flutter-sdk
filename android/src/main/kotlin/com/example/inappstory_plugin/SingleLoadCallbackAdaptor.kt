package com.example.inappstory_plugin

import SingleLoadCallbackFlutterApi
import com.inappstory.sdk.stories.outercallbacks.common.reader.StoryData
import com.inappstory.sdk.stories.outercallbacks.common.single.SingleLoadCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin


class SingleLoadCallbackAdaptor(
        private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
) : SingleLoadCallback {
    private val flutterApi = SingleLoadCallbackFlutterApi(flutterPluginBinding.binaryMessenger)
    override fun singleLoad(storyData: StoryData?) {
        if (storyData == null) return

        flutterPluginBinding.runOnMainThread {
            flutterApi.singleLoad(mapStoryData(storyData)) {}
        }
    }
}