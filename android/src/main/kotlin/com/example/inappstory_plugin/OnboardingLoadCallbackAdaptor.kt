package com.example.inappstory_plugin

import OnboardingLoadCallbackFlutterApi
import com.inappstory.sdk.stories.outercallbacks.common.onboarding.OnboardingLoadCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin

class OnboardingLoadCallbackAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
) : OnboardingLoadCallback {
    private val flutterApi = OnboardingLoadCallbackFlutterApi(flutterPluginBinding.binaryMessenger)

    override fun onboardingLoad(count: Int, feed: String?) {
        flutterPluginBinding.runOnMainThread {
            flutterApi.onboardingLoad(count.toLong(), feed!!) {}
        }
    }
}
