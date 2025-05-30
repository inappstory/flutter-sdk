package com.inappstory.inappstory_plugin.callbacks

import IASInAppMessagesCallbacksFlutterApi
import com.inappstory.inappstory_plugin.mapInAppMessageDataDto
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.inappmessage.InAppMessageWidgetCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.InAppMessageData
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class InAppMessageCallbackAdaptor(
    private val flutterPluginBinding: FlutterPluginBinding,
    inAppStoryManager: InAppStoryManager,
) {
    private val api: IASInAppMessagesCallbacksFlutterApi =
        IASInAppMessagesCallbacksFlutterApi(flutterPluginBinding.binaryMessenger)

    init {
        inAppStoryManager.setShowInAppMessageCallback { iamData ->
            flutterPluginBinding.runOnMainThread {
                api.onShowInAppMessage(iamData?.let {
                    mapInAppMessageDataDto(
                        it
                    )
                }) {}
            }
        }

        inAppStoryManager.setCloseInAppMessageCallback { iamData ->
            flutterPluginBinding.runOnMainThread {
                api.onCloseInAppMessage(iamData?.let {
                    mapInAppMessageDataDto(
                        it
                    )
                }) {}
            }
        }

        inAppStoryManager.setInAppMessageWidgetCallback(object : InAppMessageWidgetCallback {
            override fun inAppMessageWidget(
                inAppMessageData: InAppMessageData?,
                name: String?,
                data: MutableMap<String, String>?
            ) {
                val inAppMessageDataDto = inAppMessageData?.let { mapInAppMessageDataDto(it) }
                val dataDto: Map<String?, Any?>? = data?.toMap<String?, Any?>()
                flutterPluginBinding.runOnMainThread {
                    api.onInAppMessageWidgetEvent(
                        inAppMessageDataArg = inAppMessageDataDto,
                        nameArg = name,
                        dataArg = dataDto
                    ) {}
                }
            }

        })
    }
}