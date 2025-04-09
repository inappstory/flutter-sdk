package com.example.inappstory_plugin

import android.os.Handler
import com.inappstory.sdk.stories.outercallbacks.common.reader.SlideData
import com.inappstory.sdk.stories.outercallbacks.common.reader.StoryData
import io.flutter.embedding.engine.plugins.FlutterPlugin
import SlideDataDto
import SourceTypeDto
import StoryDataDto
import StoryTypeDto


fun FlutterPlugin.FlutterPluginBinding.runOnMainThread(callback: () -> Unit) {
    Handler(applicationContext.mainLooper).post(callback)
}

fun mapStoryData(storyData: StoryData): StoryDataDto {
    return StoryDataDto(
            id = storyData.id.toLong(),
            title = storyData.title,
            // TODO: Add tags
            // tags = storyData.tags,
            feed = storyData.feed(),
            slidesCount = storyData.slidesCount().toLong(),
            storyType = StoryTypeDto.ofRaw(storyData.contentType().ordinal),
            sourceType = SourceTypeDto.ofRaw(storyData.sourceType().ordinal),
    )
}

fun mapSlideDataDto(slideData: SlideData): SlideDataDto {
    return SlideDataDto(
            story = mapStoryData(slideData.story),
            index = slideData.index.toLong(),
            payload = slideData.payload,
    )
}