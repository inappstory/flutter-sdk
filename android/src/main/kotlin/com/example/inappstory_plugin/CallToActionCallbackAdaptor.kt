package com.example.inappstory_plugin

import CallToActionCallbackFlutterApi
import android.content.Context
import com.inappstory.sdk.stories.outercallbacks.common.reader.CallToActionCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.ClickAction
import com.inappstory.sdk.stories.outercallbacks.common.reader.SlideData
import io.flutter.embedding.engine.plugins.FlutterPlugin
import ClickActionDto

class CallToActionCallbackAdaptor(
        flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
) : CallToActionCallback {
    private val api = CallToActionCallbackFlutterApi(flutterPluginBinding.binaryMessenger)

    override fun callToAction(p0: Context?, slideData: SlideData?, url: String?, clickAction: ClickAction?) {
        api.callToAction(
                slideDataArg = slideData?.let { mapSlideDataDto(it) },
                urlArg = url,
                clickActionArg = clickAction?.let { ClickActionDto.ofRaw(it.ordinal) }
        ) {}
    }
}

