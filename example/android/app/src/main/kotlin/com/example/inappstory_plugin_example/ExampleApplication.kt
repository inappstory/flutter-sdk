package com.example.inappstory_plugin_example

import android.app.Application
import com.example.inappstory_plugin.InappstoryPlugin


class ExampleApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        InappstoryPlugin.initSDK(this)
    }
}