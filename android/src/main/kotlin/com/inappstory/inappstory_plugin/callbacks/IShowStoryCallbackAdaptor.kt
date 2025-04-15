package com.inappstory.inappstory_plugin.callbacks

import IShowStoryCallbackFlutterApi
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.stories.callbacks.IShowStoryOnceCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin

class IShowStoryCallbackAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
) : IShowStoryOnceCallback {
    override fun onShow() {
        flutterPluginBinding.runOnMainThread {
            IShowStoryCallbackFlutterApi(flutterPluginBinding.binaryMessenger).onShow { }
        }
    }

    override fun onError() {
        flutterPluginBinding.runOnMainThread {
            IShowStoryCallbackFlutterApi(flutterPluginBinding.binaryMessenger).onError { }
        }
    }

    override fun alreadyShown() {
        flutterPluginBinding.runOnMainThread {
            IShowStoryCallbackFlutterApi(flutterPluginBinding.binaryMessenger).alreadyShown { }
        }
    }
}
