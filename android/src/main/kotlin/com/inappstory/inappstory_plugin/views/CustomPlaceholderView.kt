package com.inappstory.inappstory_plugin.views

import android.content.Context
import android.graphics.BitmapFactory
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import androidx.appcompat.widget.AppCompatImageView
import io.flutter.embedding.engine.plugins.FlutterPlugin

internal fun buildPlaceholderView(
    context: Context,
    color: Long?,
    image: String?,
    flutterAssets: FlutterPlugin.FlutterAssets,
    appContext: Context,
): View {
    val frame = FrameLayout(context)
    frame.layoutParams = FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT,
    )
    if (color != null) {
        frame.setBackgroundColor(color.toInt())
    }
    if (image != null) {
        val bitmap = try {
            val assetPath = flutterAssets.getAssetFilePathBySubpath(image)
            appContext.assets.open(assetPath).use { BitmapFactory.decodeStream(it) }
        } catch (_: Exception) {
            null
        }
        if (bitmap != null) {
            val imageView = AppCompatImageView(context)
            imageView.layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
            ).apply { gravity = Gravity.CENTER }
            imageView.setImageBitmap(bitmap)
            frame.addView(imageView)
        }
    }
    return frame
}
