package com.inappstory.inappstory_plugin

import ContentDataDto
import ContentTypeDto
import InAppMessageDataDto
import InAppMessageTypeDto
import SlideDataDto
import SourceTypeDto
import StoryDataDto
import StoryTypeDto
import android.os.Handler
import com.inappstory.sdk.inappmessage.InAppMessageData
import com.inappstory.sdk.inappmessage.InAppMessageType
import com.inappstory.sdk.stories.api.models.ContentType
import com.inappstory.sdk.stories.outercallbacks.common.reader.ContentData
import com.inappstory.sdk.stories.outercallbacks.common.reader.SlideData
import com.inappstory.sdk.stories.outercallbacks.common.reader.SourceType
import com.inappstory.sdk.stories.outercallbacks.common.reader.StoryData
import io.flutter.embedding.engine.plugins.FlutterPlugin

fun FlutterPlugin.FlutterPluginBinding.runOnMainThread(callback: () -> Unit) {
    Handler(applicationContext.mainLooper).post(callback)
}

private fun SourceType.toDto(): SourceTypeDto = when (this) {
    SourceType.SINGLE -> SourceTypeDto.SINGLE
    SourceType.ONBOARDING -> SourceTypeDto.ONBOARDING
    SourceType.LIST -> SourceTypeDto.LIST
    SourceType.FAVORITE -> SourceTypeDto.FAVORITE
    SourceType.STACK -> SourceTypeDto.STACK
    SourceType.EVENT_IN_APP_MESSAGE,
    SourceType.SINGLE_IN_APP_MESSAGE -> SourceTypeDto.IN_APP_MESSAGE
    SourceType.BANNERS -> SourceTypeDto.BANNERS
}

private fun ContentType.toContentTypeDto(): ContentTypeDto? = when (this) {
    ContentType.STORY -> ContentTypeDto.STORY
    ContentType.UGC -> ContentTypeDto.UGC
    ContentType.IN_APP_MESSAGE -> ContentTypeDto.IN_APP_MESSAGE
    ContentType.BANNER -> null 
}

private fun ContentType.toStoryTypeDto(): StoryTypeDto = when (this) {
    ContentType.STORY -> StoryTypeDto.COMMON
    ContentType.UGC -> StoryTypeDto.UGC
    ContentType.IN_APP_MESSAGE -> StoryTypeDto.IAM
    ContentType.BANNER -> StoryTypeDto.BANNER
}

private fun InAppMessageType.toDto(): InAppMessageTypeDto = when (this) {
    InAppMessageType.FULLSCREEN -> InAppMessageTypeDto.FULL_SCREEN
    InAppMessageType.POPUP -> InAppMessageTypeDto.POP_UP
    InAppMessageType.BOTTOM_SHEET -> InAppMessageTypeDto.BOTTOM_SHEET
    InAppMessageType.TOAST -> InAppMessageTypeDto.TOAST
    InAppMessageType.UNDEFINED -> InAppMessageTypeDto.UNDEFINED
}

fun mapStoryData(storyData: StoryData): StoryDataDto {
    return StoryDataDto(
        id = storyData.id().toLong(),
        title = storyData.title(),
        // TODO: Add tags
        // tags = storyData.tags,
        feed = storyData.feed(),
        slidesCount = storyData.slidesCount().toLong(),
        storyType = storyData.contentType()?.toStoryTypeDto(),
        sourceType = storyData.sourceType()?.toDto(),
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
        contentType = contentData.contentType()?.toContentTypeDto(),
        sourceType = contentData.sourceType()?.toDto(),
    )
}

fun mapInAppMessageDataDto(inAppMessageData: InAppMessageData): InAppMessageDataDto {
    return InAppMessageDataDto(
        id = inAppMessageData.id().toLong(),
        title = inAppMessageData.title(),
        event = inAppMessageData.event(),
        messageType = inAppMessageData.messageType()?.toDto()
    )
}
