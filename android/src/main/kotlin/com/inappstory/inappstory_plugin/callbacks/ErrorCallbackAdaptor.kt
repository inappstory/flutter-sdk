package com.inappstory.inappstory_plugin.callbacks

import ErrorCallbackFlutterApi
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.stories.outercallbacks.common.errors.ErrorCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class ErrorCallbackAdaptor(
    private val flutterPluginBinding: FlutterPluginBinding,
    private val onLoadListError: (feed: String) -> Unit = {},
) : ErrorCallback {
    private val errorCallbackFlutterApi =
        ErrorCallbackFlutterApi(flutterPluginBinding.binaryMessenger)

    override fun loadListError(p0: String) {
        onLoadListError(p0)
    }

    override fun cacheError() {}

    override fun emptyLinkError() {}

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