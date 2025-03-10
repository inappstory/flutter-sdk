package com.example.inappstory_plugin

import IASOnboardingsHostApi
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.externalapi.onboardings.IASOnboardings
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
