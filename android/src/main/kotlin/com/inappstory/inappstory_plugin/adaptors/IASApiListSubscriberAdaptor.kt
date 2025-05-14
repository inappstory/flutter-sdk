package com.inappstory.inappstory_plugin.adaptors

import InAppStoryAPIListSubscriberFlutterApi
import StoryAPIDataDto
import StoryFavoriteItemAPIDataDto
import com.inappstory.inappstory_plugin.mapStoryData
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.externalapi.StoryAPIData
import com.inappstory.sdk.externalapi.StoryFavoriteItemAPIData
import com.inappstory.sdk.externalapi.storylist.IASStoryListSessionData
import com.inappstory.sdk.externalapi.subscribers.InAppStoryAPIListSubscriber
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

open class InAppStoryAPIListSubscriberAdaptor(
    private val flutterPluginBinding: FlutterPluginBinding,
    uniqueId: String,
) :
    InAppStoryAPIListSubscriber(uniqueId) {
    private val storyListSubscriber =
        InAppStoryAPIListSubscriberFlutterApi(flutterPluginBinding.binaryMessenger, uniqueId)
    private val sessionData = InAppStoryManager.getInstance()?.iasCore()?.sessionManager()?.session?.sessionData()

    override fun updateStoryData(storyAPIData: StoryAPIData, storySessionData: IASStoryListSessionData?) {
        flutterPluginBinding.runOnMainThread {
            storyListSubscriber.updateStoryData(mapStoryAPIData(storyAPIData, storySessionData?.previewAspectRatio() ?: getAspectRatio())) {}
        }
    }

    override fun updateStoriesData(list: MutableList<StoryAPIData>, storySessionData: IASStoryListSessionData?) {
        flutterPluginBinding.runOnMainThread {
            storyListSubscriber.updateStoriesData(list.map { mapStoryAPIData(it, storySessionData?.previewAspectRatio() ?: getAspectRatio()) }) {}
        }
    }

    override fun updateFavoriteItemData(list: MutableList<StoryFavoriteItemAPIData>) {
        flutterPluginBinding.runOnMainThread {
            storyListSubscriber.updateFavoriteStoriesData(list.map { mapFavorite(it) }) {}
        }
    }

    private fun getAspectRatio(): Float {
        var aspectRatio = 1.0f
        if (sessionData != null) {
            aspectRatio = sessionData.previewAspectRatio
        }
        return aspectRatio
    }

    private fun mapStoryAPIData(p0: StoryAPIData, aspectRatio: Float): StoryAPIDataDto {
        return StoryAPIDataDto(
            imageFilePath = p0.imageFilePath,
            backgroundColor = p0.backgroundColor,
            id = p0.id.toLong(),
            hasAudio = p0.hasAudio,
            videoFilePath = p0.videoFilePath,
            title = p0.title,
            titleColor = p0.titleColor,
            opened = p0.opened,
            storyData = mapStoryData(p0.storyData),
            aspectRatio = aspectRatio.toDouble(),
        )
    }

    private fun mapFavorite(arg: StoryFavoriteItemAPIData): StoryFavoriteItemAPIDataDto {
        return StoryFavoriteItemAPIDataDto(
            id = arg.id.toLong(),
            imageFilePath = arg.imageFilePath,
            backgroundColor = arg.backgroundColor,
        )
    }
}
