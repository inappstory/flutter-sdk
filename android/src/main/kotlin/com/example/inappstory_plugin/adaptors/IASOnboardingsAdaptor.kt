package com.example.inappstory_plugin.adaptors

import IASOnboardingsHostApi
import com.example.inappstory_plugin.callbacks.OnboardingLoadCallbackAdaptor
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.core.api.IASOnboardings
import io.flutter.embedding.engine.plugins.FlutterPlugin

class IASOnboardingsAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val appearanceManager: AppearanceManager,
    private val iasOnboardings: IASOnboardings,
) : IASOnboardingsHostApi {
    init {
        IASOnboardingsHostApi.setUp(flutterPluginBinding.binaryMessenger, this)

        iasOnboardings.loadCallback(OnboardingLoadCallbackAdaptor(flutterPluginBinding))
    }

    override fun show(limit: Long, feed: String, tags: List<String>) {
        iasOnboardings.show(
            flutterPluginBinding.applicationContext,
            feed,
            appearanceManager,
            tags,
            limit.toInt(),
        )
    }
}
