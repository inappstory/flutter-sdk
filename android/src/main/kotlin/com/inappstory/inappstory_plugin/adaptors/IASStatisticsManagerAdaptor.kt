package com.inappstory.inappstory_plugin.adaptors

import InAppStoryStatManagerHostApi
import com.inappstory.sdk.InAppStoryManager
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import java.lang.reflect.Field

class IASStatisticsManagerAdaptor(
    flutterPluginBinding: FlutterPluginBinding,
    private val inAppStoryManager: InAppStoryManager,
) : InAppStoryStatManagerHostApi {
    init {
        InAppStoryStatManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    override fun sendStatistics(enabled: Boolean) {
        inAppStoryManager.let {
            val f1: Field = it.javaClass.getDeclaredField("sendStatistic")
            f1.isAccessible = true
            f1.set(it, enabled)
        }
    }
}