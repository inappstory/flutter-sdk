package com.inappstory.inappstory_plugin.callbacks

import OnboardingLoadCallbackFlutterApi
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.stories.outercallbacks.common.onboarding.OnboardingLoadCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin

class OnboardingLoadCallbackAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
) : OnboardingLoadCallback {
    private val flutterApi = OnboardingLoadCallbackFlutterApi(flutterPluginBinding.binaryMessenger)

    override fun onboardingLoadSuccess(count: Int, feed: String?) {
        flutterPluginBinding.runOnMainThread {
            flutterApi.onboardingLoadSuccess(count.toLong(), feed!!) {}
        }
    }

    override fun onboardingLoadError(feed: String?, reason: String?) {
        flutterPluginBinding.runOnMainThread {
            flutterApi.onboardingLoadError(feed!!, reason) {}
        }
    }
}
