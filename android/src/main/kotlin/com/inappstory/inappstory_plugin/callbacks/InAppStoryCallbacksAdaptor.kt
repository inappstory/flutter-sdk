package com.inappstory.inappstory_plugin.callbacks

import IASCallBacksFlutterApi
import com.inappstory.inappstory_plugin.mapSlideDataDto
import com.inappstory.inappstory_plugin.mapStoryData
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.externalapi.callbacks.IASCallbacksExternalAPI
import com.inappstory.sdk.stories.outercallbacks.common.reader.LikeDislikeStoryCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.SlideData
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

        callbacks.likeDislikeStory(object : LikeDislikeStoryCallback {
            override fun likeStory(
                slide: SlideData?,
                value: Boolean
            ) {
                flutterPluginBinding.runOnMainThread {
                    val slideDataDto = slide?.let { mapSlideDataDto(it) }
                    api.onLikeStoryTap(slideDataDto, value) {}
                }
            }

            override fun dislikeStory(
                slide: SlideData?,
                value: Boolean
            ) {
                flutterPluginBinding.runOnMainThread {
                    val slideDataDto = slide?.let { mapSlideDataDto(it) }
                    api.onDislikeStoryTap(slideDataDto, value) {}
                }
            }
        })

        callbacks.clickOnShareStory { slide: SlideData? ->
            flutterPluginBinding.runOnMainThread {
                val slideDataDto = slide?.let { mapSlideDataDto(it) }
                api.onShareStory(slideDataDto) {}
            }
        }

        callbacks.showSlide { slide ->
            flutterPluginBinding.runOnMainThread {
                val slideDataDto = slide?.let { mapSlideDataDto(it) }
                api.onShowSlide(slideDataDto) {}
            }
        }

        callbacks.storyWidget { slideData, widgetEventName, widgetData ->
            flutterPluginBinding.runOnMainThread {
                val slideDataDto = slideData?.let { mapSlideDataDto(it) }
                val widgetDataDto: Map<String?, Any?>? = widgetData?.toMap<String?, Any?>()
                api.onStoryWidgetEvent(slideDataDto, widgetDataDto) {}
            }
        }
    }
}