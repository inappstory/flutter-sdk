package com.example.inappstory_plugin

import AppearanceManagerHostApi
import Position
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.stories.ui.reader.StoriesGradientObject
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

    override fun setClosePosition(position: Position) {
        appearanceManager.csClosePosition(position.raw + 1)
    }

    override fun setTimerGradientEnable(isEnabled: Boolean) {
        appearanceManager.csTimerGradientEnable(isEnabled)
    }

    override fun getTimerGradientEnable(): Boolean {
        return appearanceManager.csTimerGradientEnable()
    }

    override fun setTimerGradient(colors: List<Long>, locations: List<Double>) {
        val gradient = StoriesGradientObject()
        gradient.csColors(colors.map { it.toInt() })
        if (locations.size == colors.size) {
            gradient.csLocations(locations.map { it.toFloat() })
        }
        appearanceManager.csTimerGradient(gradient)
    }

    override fun setReaderBackgroundColor(color: Long) {
        appearanceManager.csReaderBackgroundColor(color.toInt())
    }

    override fun setReaderCornerRadius(radius: Long) {
        appearanceManager.csReaderRadius(radius.toInt())
    }
}