package com.inappstory.inappstory_plugin.views

import android.content.Context
import android.widget.FrameLayout

internal class BannerGridContentLayout(context: Context) : FrameLayout(context) {
    var onContentLayout: ((Int) -> Unit)? = null
    private val pendingLoads = mutableListOf<() -> Unit>()

    fun whenWidthReady(load: () -> Unit) {
        if ((getChildAt(0)?.measuredWidth ?: 0) > 0) {
            load()
        } else {
            pendingLoads.add(load)
            requestLayout()
        }
    }

    fun dispose() {
        pendingLoads.clear()
        onContentLayout = null
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val content = getChildAt(0)
        if (content == null) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
            return
        }
        val width = MeasureSpec.getSize(widthMeasureSpec)
        // Flutter initially constrains the platform view to a loading height.
        // Measure every native row, not just the portion that currently fits.
        content.measure(
            MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
        )
        setMeasuredDimension(
            resolveSize(content.measuredWidth, widthMeasureSpec),
            resolveSize(content.measuredHeight, heightMeasureSpec)
        )
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        val content = getChildAt(0) ?: return
        content.layout(0, 0, content.measuredWidth, content.measuredHeight)
        if (content.measuredWidth > 0) {
            val loads = pendingLoads.toList()
            pendingLoads.clear()
            if (loads.isNotEmpty()) {
                loads.forEach { it() }
            } else {
                onContentLayout?.invoke(content.measuredHeight)
            }
        }
    }
}
