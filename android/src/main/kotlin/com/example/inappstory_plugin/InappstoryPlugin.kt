package com.example.inappstory_plugin

import InAppStoryAPI
import InappstorySdkModuleHostApi
import com.inappstorysdk.InAppStory
import com.inappstorysdk.InappstorySdkModule
import com.inappstorysdk.ReactApplicationContext
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** InappstoryPlugin */
class InappstoryPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "inappstory_plugin")
        channel.setMethodCallHandler(this)

        InAppStory.initSDK(flutterPluginBinding.applicationContext)

        val module =
            InappstorySdkModule(ReactApplicationContext(flutterPluginBinding.applicationContext))

        InappstorySdkModuleHostApi.setUp(
            flutterPluginBinding.binaryMessenger,
            api = InappstorySdkModuleAdaptor(module, flutterPluginBinding)
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        InappstorySdkModuleHostApi.setUp(binding.binaryMessenger, api = null)
        InAppStoryAPI.setUp(binding.binaryMessenger, api = null)
    }
}
