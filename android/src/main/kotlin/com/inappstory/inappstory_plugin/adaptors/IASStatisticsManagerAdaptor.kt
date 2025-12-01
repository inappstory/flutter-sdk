package com.inappstory.inappstory_plugin.adaptors

import InAppStoryStatManagerHostApi
import com.inappstory.sdk.externalapi.InAppStoryAPI
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class IASStatisticsManagerAdaptor(
    flutterPluginBinding: FlutterPluginBinding,
    private val inAppStoryApi: InAppStoryAPI
) : InAppStoryStatManagerHostApi {
    init {
        InAppStoryStatManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    override fun sendStatistics(
        enabled: Boolean,
        callback: (Result<Unit>) -> Unit
    ) {
        inAppStoryApi.settings.sendStatistic(enabled)
        callback.invoke(Result.success(Unit))
    }
}