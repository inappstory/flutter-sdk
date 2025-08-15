package com.inappstory.inappstory_plugin.helpers

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.view.View
import android.widget.FrameLayout
import androidx.appcompat.widget.AppCompatImageView
import com.inappstory.inappstory_plugin.R.layout

class IASCustomIcon(context: Context) : FrameLayout(context) {
    private var image: AppCompatImageView? = null

    init {
        this.init(context)
    }

    @SuppressLint("UseCompatLoadingForDrawables")
    fun setIconId(iconId: Int): IASCustomIcon {
        image?.setImageDrawable(this.resources.getDrawable(iconId))
        return this
    }

    fun setIconBitmap(bitmap: Bitmap): IASCustomIcon {
        image?.setImageBitmap(bitmap)
        return this
    }

    private fun init(context: Context) {
        inflate(context, layout.flutter_custom_icon, this)
        this.image =
            findViewById<View>(com.inappstory.inappstory_plugin.R.id.image) as AppCompatImageView
        image?.isEnabled = true
        image?.isActivated = true
    }

    @SuppressLint("UseCompatLoadingForDrawables")
    fun updateState(active: Boolean, enabled: Boolean) {
        image?.isEnabled = enabled
        image?.isActivated = active
    }
}