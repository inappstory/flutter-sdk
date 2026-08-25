package com.inappstory.inappstory_plugin.adaptors

import IASOnboardingsHostApi
import com.inappstory.inappstory_plugin.callbacks.OnboardingLoadCallbackAdaptor
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.CancellationToken
import com.inappstory.sdk.CancellationTokenCancelResult
import com.inappstory.sdk.InAppStoryManager
import io.flutter.embedding.engine.plugins.FlutterPlugin

class IASOnboardingsAdaptor(
    flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val appearanceManager: AppearanceManager,
    private val activityHolder: ActivityHolder,
) : IASOnboardingsHostApi {
    private val tokenMap = mutableMapOf<String, CancellationToken>()

    init {
        IASOnboardingsHostApi.setUp(flutterPluginBinding.binaryMessenger, this)

        InAppStoryManager.getInstance()
            ?.setOnboardingLoadCallback(OnboardingLoadCallbackAdaptor(flutterPluginBinding))
    }

    override fun show(limit: Long, feed: String, token: String, tags: List<String>) {
        val cancellationToken = InAppStoryManager.getInstance()?.showOnboardingStories(
            limit.toInt(),
            feed,
            tags,
            activityHolder.activity,
            appearanceManager,
        )
        if (cancellationToken != null) {
            tokenMap[token] = cancellationToken
        }
    }

    override fun cancelByToken(token: String): Boolean {
        if (tokenMap.containsKey(token)) {
            val result = tokenMap[token]?.cancel()
            tokenMap.remove(token)
            return result == CancellationTokenCancelResult.SUCCESS
        }
        return false
    }
}
