package com.example.inappstory_plugin

import AppearanceManagerHostApi
import com.inappstory.sdk.AppearanceManager
import io.flutter.embedding.engine.plugins.FlutterPlugin

class AppearanceManagerAdaptor(
        private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
        val appearanceManager: AppearanceManager,
) : AppearanceManagerHostApi {
    init {
        AppearanceManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    override fun setHasLike(value: Boolean) {
        appearanceManager.csHasLike(value)
    }

    override fun setHasFavorites(value: Boolean) {
        appearanceManager.csHasFavorite(value)
    }

    override fun setHasShare(value: Boolean) {
        appearanceManager.csHasShare(value)
    }
}