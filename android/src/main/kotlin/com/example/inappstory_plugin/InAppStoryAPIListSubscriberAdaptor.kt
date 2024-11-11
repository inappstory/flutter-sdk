package com.example.inappstory_plugin

import InAppStoryAPIListSubscriberFlutterApi
import StoryAPIDataDto
import android.os.Handler
import com.inappstory.sdk.InAppStoryService
import com.inappstory.sdk.externalapi.StoryAPIData
import com.inappstory.sdk.externalapi.StoryFavoriteItemAPIData
import com.inappstory.sdk.externalapi.storylist.IASStoryList
import com.inappstory.sdk.externalapi.subscribers.InAppStoryAPIListSubscriber
import com.inappstory.sdk.stories.api.models.CachedSessionData
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class InAppStoryAPIListSubscriberAdaptor(
        private val flutterPluginBinding: FlutterPluginBinding,
) :
        InAppStoryAPIListSubscriber("feed") {
    private val storyListSubscriber = InAppStoryAPIListSubscriberFlutterApi(flutterPluginBinding.binaryMessenger)
    private val storyDownloadManager = InAppStoryService.getInstance().storyDownloadManager
    private val sessionData = CachedSessionData.getInstance(flutterPluginBinding.applicationContext)
    override fun updateStoryData(storyAPIData: StoryAPIData) {
        flutterPluginBinding.runOnMainThread {
            storyListSubscriber.updateStoryData(mapStoryAPIData(storyAPIData, getAspectRatio())) {}
        }
    }

    override fun updateStoriesData(list: MutableList<StoryAPIData>) {
        Handler(flutterPluginBinding.applicationContext.mainLooper).post {
            storyListSubscriber.updateStoriesData(list.map { mapStoryAPIData(it, getAspectRatio()) }) {}
        }
    }

    override fun updateFavoriteItemData(p0: MutableList<StoryFavoriteItemAPIData>) {
        TODO("Not yet implemented")
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
}
