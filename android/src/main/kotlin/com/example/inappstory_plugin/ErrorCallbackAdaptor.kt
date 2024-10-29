package com.example.inappstory_plugin

import ErrorCallbackFlutterApi
import com.inappstory.sdk.stories.outercallbacks.common.errors.ErrorCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

class ErrorCallbackAdaptor(private val flutterPluginBinding: FlutterPluginBinding) : ErrorCallback {
    private val errorCallbackFlutterApi = ErrorCallbackFlutterApi(flutterPluginBinding.binaryMessenger)
    override fun loadListError(p0: String) {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.loadListError(p0) {}
        }
    }

    override fun loadOnboardingError(p0: String) {
        TODO("Not yet implemented")
    }

    override fun loadSingleError() {
        TODO("Not yet implemented")
    }

    override fun cacheError() {
        TODO("Not yet implemented")
    }

    override fun readerError() {
        TODO("Not yet implemented")
    }

    override fun emptyLinkError() {
        TODO("Not yet implemented")
    }

    override fun sessionError() {
        TODO("Not yet implemented")
    }

    override fun noConnection() {
        TODO("Not yet implemented")
    }
}