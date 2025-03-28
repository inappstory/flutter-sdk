package com.example.inappstory_plugin

import InappstorySdkModuleHostApi
import android.app.Activity
import android.app.Application
import com.inappstory.sdk.InAppStoryManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** InappstoryPlugin */
class InappstoryPlugin : FlutterPlugin, MethodCallHandler, ActivityHolder, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "inappstory_plugin")
        channel.setMethodCallHandler(this)

        InAppStoryManager.initSDK(flutterPluginBinding.applicationContext, true)

        InappstorySdkModuleHostApi.setUp(
            flutterPluginBinding.binaryMessenger,
            api = InappstorySdkModuleAdaptor(flutterPluginBinding, activityHolder = this),
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    override var activity: Activity? = null

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        InappstorySdkModuleHostApi.setUp(binding.binaryMessenger, api = null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }
}
