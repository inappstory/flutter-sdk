package com.inappstory.inappstory_plugin.views

import PlaceholderDecorationDto
import android.content.Context
import android.view.View
import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Global banner loading placeholder, set from `AppearanceManager.setBannersPlaceholder`
 * and read lazily by every banner carousel and grid when the SDK asks for a loader.
 */
class BannerPlaceholderStore(
    private val buildView: (context: Context, decoration: PlaceholderDecorationDto) -> View,
) {
    constructor(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) : this(
        { context, decoration ->
            buildPlaceholderView(
                context,
                decoration.color,
                decoration.image,
                flutterPluginBinding.flutterAssets,
                flutterPluginBinding.applicationContext,
            )
        }
    )

    @Volatile
    var decoration: PlaceholderDecorationDto? = null

    /** Returns null when no custom placeholder is set, so the SDK default loader is used. */
    fun createView(context: Context): View? {
        val current = decoration ?: return null
        if (current.color == null && current.image == null) return null
        return buildView(context, current)
    }
}
