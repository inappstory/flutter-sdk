package com.inappstory.inappstory_plugin.helpers

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.os.Build
import com.inappstory.sdk.stories.outercallbacks.common.objects.DefaultOpenStoriesReader
import com.inappstory.sdk.stories.utils.StatusBarController

class CustomOpenStoriesReader : DefaultOpenStoriesReader() {

    private var sbColor: Int = Color.TRANSPARENT

    override fun onHideStatusBar(context: Context?) {
        if (context is Activity) {
            if (Build.VERSION.SDK_INT < 35) {
                sbColor = context.window.statusBarColor
                context.window.statusBarColor = Color.TRANSPARENT
            }
            StatusBarController.hideStatusBar(context, false)
        }
    }

    override fun onRestoreStatusBar(context: Context?) {
        if (context is Activity) {
            if (Build.VERSION.SDK_INT < 35) {
                context.window.statusBarColor = sbColor
            }
            StatusBarController.showStatusBar(context)
        }
    }
}