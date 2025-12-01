package com.inappstory.inappstory_plugin

import ContentDataDto
import ContentTypeDto
import InAppMessageDataDto
import SlideDataDto
import SourceTypeDto
import StoryDataDto
import StoryTypeDto
import android.os.Handler
import com.inappstory.sdk.inappmessage.InAppMessageData
import com.inappstory.sdk.stories.outercallbacks.common.reader.ContentData
import com.inappstory.sdk.stories.outercallbacks.common.reader.SlideData
import com.inappstory.sdk.stories.outercallbacks.common.reader.StoryData
import io.flutter.embedding.engine.plugins.FlutterPlugin

fun FlutterPlugin.FlutterPluginBinding.runOnMainThread(callback: () -> Unit) {
    Handler(applicationContext.mainLooper).post(callback)
}

fun mapStoryData(storyData: StoryData): StoryDataDto {
    return StoryDataDto(
        id = storyData.id().toLong(),
        title = storyData.title(),
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
        story = mapStoryData(slideData.story()),
        index = slideData.index().toLong(),
        payload = slideData.payload(),
    )
}

fun mapContentDataDto(contentData: ContentData): ContentDataDto {
    return ContentDataDto(
        contentType = ContentTypeDto.ofRaw(contentData.contentType().ordinal),
        sourceType = SourceTypeDto.ofRaw(contentData.sourceType().ordinal),
    );
}

fun mapInAppMessageDataDto(inAppMessageData: InAppMessageData): InAppMessageDataDto {
    return InAppMessageDataDto(
        id = inAppMessageData.id().toLong(),
        title = inAppMessageData.title(),
        event = inAppMessageData.event(),
    )
}