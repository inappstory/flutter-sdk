package com.inappstory.inappstory_plugin

import InappstorySdkModuleHostApi
import android.app.Activity
import android.app.Application
import com.inappstory.inappstory_plugin.adaptors.ActivityHolder
import com.inappstory.inappstory_plugin.adaptors.InappstorySdkModuleAdaptor
import com.inappstory.inappstory_plugin.views.BannerViewFactory
import com.inappstory.sdk.InAppStoryManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

/** InAppStoryPlugin */
class InAppStoryPlugin : FlutterPlugin, MethodCallHandler, ActivityHolder, ActivityAware {

    companion object {
        @JvmStatic
        fun initSDK(application: Application) {
            InAppStoryManager.initSDK(application, false)
        }
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "inappstory_plugin")
        channel.setMethodCallHandler(this)

        val inappstorySdkModuleAdaptor =
            InappstorySdkModuleAdaptor(flutterPluginBinding, activityHolder = this)
        InappstorySdkModuleHostApi.setUp(
            flutterPluginBinding.binaryMessenger,
            api = inappstorySdkModuleAdaptor,
        )

        flutterPluginBinding
            .platformViewRegistry
            .registerViewFactory(
                "banner-view",
                BannerViewFactory(
                    flutterPluginBinding,
                    inappstorySdkModuleAdaptor.appearanceManager
                )
            )
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
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
