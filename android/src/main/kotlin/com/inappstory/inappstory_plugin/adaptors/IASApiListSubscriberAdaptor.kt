package com.inappstory.inappstory_plugin.adaptors

import InAppStoryAPIListSubscriberFlutterApi
import StoryAPIDataDto
import StoryDataDto
import StoryFavoriteItemAPIDataDto
import com.inappstory.inappstory_plugin.mapStoryData
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.externalapi.StoryAPIData
import com.inappstory.sdk.externalapi.StoryFavoriteItemAPIData
import com.inappstory.sdk.externalapi.storylist.IASStoryListSessionData
import com.inappstory.sdk.externalapi.subscribers.InAppStoryAPIListSubscriber
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

open class InAppStoryAPIListSubscriberAdaptor(
    private val flutterPluginBinding: FlutterPluginBinding,
    private val feed: String,
    uniqueId: String,
) : InAppStoryAPIListSubscriber(uniqueId) {

    private val storyListSubscriber =
        InAppStoryAPIListSubscriberFlutterApi(flutterPluginBinding.binaryMessenger, uniqueId)

    override fun updateStoryData(
        storyAPIData: StoryAPIData,
        storySessionData: IASStoryListSessionData?
    ) {
        flutterPluginBinding.runOnMainThread {
            storyListSubscriber.updateStoryData(
                mapStoryAPIData(
                    storyAPIData,
                    storySessionData?.previewAspectRatio() ?: 1.0f
                )
            ) {}
        }
    }

    override fun updateStoriesData(
        list: MutableList<StoryAPIData>,
        storySessionData: IASStoryListSessionData?
    ) {
        flutterPluginBinding.runOnMainThread {
            storyListSubscriber.updateStoriesData(list.map {
                mapStoryAPIData(
                    it,
                    storySessionData?.previewAspectRatio() ?: 1.0f
                )
            }) {}
            storyListSubscriber.storiesLoaded(list.size.toLong(), uniqueId) {}
        }
    }

    override fun updateFavoriteItemData(list: MutableList<StoryFavoriteItemAPIData>) {
        flutterPluginBinding.runOnMainThread {
            storyListSubscriber.updateFavoriteStoriesData(list.map { mapFavorite(it) }) {}
        }
    }

    override fun readerIsClosed() {
        super.readerIsClosed()
    }

    fun scrollToStory(story: StoryDataDto?) {
        flutterPluginBinding.runOnMainThread {
            storyListSubscriber.scrollToStory(
                indexArg = (story?.id) ?: -1,
                feedArg = feed,
                uniqueIdArg = uniqueId
            ) {}
        }
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
