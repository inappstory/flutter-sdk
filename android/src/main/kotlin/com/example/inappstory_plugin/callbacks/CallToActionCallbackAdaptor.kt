package com.example.inappstory_plugin.callbacks

import CallToActionCallbackFlutterApi
import ClickActionDto
import android.content.Context
import com.example.inappstory_plugin.mapSlideDataDto
import com.example.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.stories.outercallbacks.common.reader.CallToActionCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.ClickAction
import com.inappstory.sdk.stories.outercallbacks.common.reader.ContentData
import com.inappstory.sdk.stories.outercallbacks.common.reader.InAppMessageData
import com.inappstory.sdk.stories.outercallbacks.common.reader.SlideData
import io.flutter.embedding.engine.plugins.FlutterPlugin

class CallToActionCallbackAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
) : CallToActionCallback {
    private val api = CallToActionCallbackFlutterApi(flutterPluginBinding.binaryMessenger)

    override fun callToAction(
        context: Context?,
        content: ContentData?,
        url: String?,
        action: ClickAction?
    ) {
        if (content is SlideData) {

            flutterPluginBinding.runOnMainThread {
                api.callToAction(
                    slideDataArg = content?.let { mapSlideDataDto(it) },
                    urlArg = url,
                    clickActionArg = action?.let { ClickActionDto.ofRaw(it.ordinal) }
                ) {}
            }
        } else if (content is InAppMessageData) {
            // TODO: implement InAppMessages
            val inAppMessageId: Int = content.id()
            val title: String? = content.title()
            val event: String? = content.event()
        }

    }
}


