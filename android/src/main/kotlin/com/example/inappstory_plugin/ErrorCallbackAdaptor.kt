package com.example.inappstory_plugin

import ErrorCallbackFlutterApi
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

    override fun loadOnboardingError(feed: String) {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.loadOnboardingError(feed) {}
        }
    }

    override fun loadSingleError() {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.loadSingleError {}
        }
    }

    override fun cacheError() {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.cacheError {}
        }
    }

    override fun readerError() {
        flutterPluginBinding.runOnMainThread {
            errorCallbackFlutterApi.readerError {}
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