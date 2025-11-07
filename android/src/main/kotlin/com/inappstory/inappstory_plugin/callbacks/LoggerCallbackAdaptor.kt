package com.inappstory.inappstory_plugin.callbacks

import LoggerFlutterApi
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.InAppStoryManager
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class IASLoggerImpl(private val flutterPluginBinding: FlutterPluginBinding) :
    InAppStoryManager.IASLogger {
    private val flutterApi = LoggerFlutterApi(flutterPluginBinding.binaryMessenger)

    override fun showDLog(tag: String?, message: String?) {
        flutterPluginBinding.runOnMainThread {
            flutterApi.debugLog(tag, message) {}
        }
    }

    override fun showELog(tag: String?, message: String?) {
        flutterPluginBinding.runOnMainThread {
            flutterApi.errorLog(tag, message) {}
        }
    }
}