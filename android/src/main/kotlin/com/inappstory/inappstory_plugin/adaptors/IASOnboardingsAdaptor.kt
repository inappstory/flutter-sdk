package com.inappstory.inappstory_plugin.adaptors

import IASOnboardingsHostApi
import com.inappstory.inappstory_plugin.callbacks.OnboardingLoadCallbackAdaptor
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.externalapi.onboardings.IASOnboardingsExternalAPI
import io.flutter.embedding.engine.plugins.FlutterPlugin

class IASOnboardingsAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val appearanceManager: AppearanceManager,
    private val iasOnboardings: IASOnboardingsExternalAPI,
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
