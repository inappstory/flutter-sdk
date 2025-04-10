package com.inappstory.inappstory_plugin.callbacks

import ErrorCallbackFlutterApi
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.stories.outercallbacks.common.errors.ErrorCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class ErrorCallbackAdaptor(private val flutterPluginBinding: FlutterPluginBinding) : ErrorCallback {
    private val errorCallbackFlutterApi =
        ErrorCallbackFlutterApi(flutterPluginBinding.binaryMessenger)

    override fun loadListError(p0: String) {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.loadListError(p0) {}
        }
    }

    override fun cacheError() {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.cacheError {}
        }
    }

    override fun emptyLinkError() {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.emptyLinkError {}
        }
    }

    override fun sessionError() {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.sessionError {}
        }
    }

    override fun noConnection() {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.noConnection {}
        }
    }
}