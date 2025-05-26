package com.inappstory.inappstory_plugin_example

import android.app.Application
import com.inappstory.inappstory_plugin.InAppStoryPlugin

class ExampleApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        InAppStoryPlugin.initSDK(this)
    }
}
