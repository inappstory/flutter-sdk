package com.example.inappstory_plugin

import IShowStoryOnceCallbackFlutterApi
import com.inappstory.sdk.stories.callbacks.IShowStoryOnceCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin

class IShowStoryOnceCallbackAdaptor(
        private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
) : IShowStoryOnceCallback {
    override fun onShow() {
        flutterPluginBinding.runOnMainThread {
            IShowStoryOnceCallbackFlutterApi(flutterPluginBinding.binaryMessenger).onShow { }

        }
    }

    override fun onError() {
        flutterPluginBinding.runOnMainThread {
            IShowStoryOnceCallbackFlutterApi(flutterPluginBinding.binaryMessenger).onError { }
        }
    }

    override fun alreadyShown() {
        flutterPluginBinding.runOnMainThread {
            IShowStoryOnceCallbackFlutterApi(flutterPluginBinding.binaryMessenger).alreadyShown { }
        }
    }
}
