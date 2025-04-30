package com.inappstory.inappstory_plugin.callbacks

import IASCallBacksFlutterApi
import com.inappstory.inappstory_plugin.mapSlideDataDto
import com.inappstory.inappstory_plugin.mapStoryData
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.externalapi.callbacks.IASCallbacksExternalAPI
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class InAppStoryCallbacksAdaptor(
    private val flutterPluginBinding: FlutterPluginBinding,
    callbacks: IASCallbacksExternalAPI,
) {
    private val api = IASCallBacksFlutterApi(flutterPluginBinding.binaryMessenger)

    init {
        callbacks.showStory { storyData, storyAction ->
            flutterPluginBinding.runOnMainThread { api.onShowStory(mapStoryData(storyData)) {} }
        }

        callbacks.closeStory { slideData, closeReader ->
            flutterPluginBinding.runOnMainThread {
                val slideDataDto = slideData?.let { mapSlideDataDto(it) }
                api.onCloseStory(slideDataDto) {}
            }
        }
        callbacks.favoriteStory { slideData, value ->
            flutterPluginBinding.runOnMainThread {
                val slideDataDto = slideData?.let { mapSlideDataDto(it) }
                api.onFavoriteTap(slideDataDto, value) {}
            }
        }
    }
}