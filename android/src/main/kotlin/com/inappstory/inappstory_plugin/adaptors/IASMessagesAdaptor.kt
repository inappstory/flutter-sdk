package com.inappstory.inappstory_plugin.adaptors

import IASInAppMessagesHostApi
import androidx.fragment.app.FragmentActivity
import com.inappstory.sdk.core.api.IASInAppMessage
import com.inappstory.sdk.inappmessage.InAppMessageLoadCallback
import com.inappstory.sdk.inappmessage.InAppMessageOpenSettings
import com.inappstory.sdk.inappmessage.InAppMessagePreloadSettings
import com.inappstory.sdk.inappmessage.InAppMessageScreenActions
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin


class IASMessagesAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val iasMessages: IASInAppMessage,
    private val activityHolder: ActivityHolder,

    ) : IASInAppMessagesHostApi {

    init {
        IASInAppMessagesHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    override fun show(messageId: String) {
        val settings = InAppMessageOpenSettings(messageId.toInt(), false, "test", listOf())
        iasMessages.show(
            settings,
            (activityHolder.activity as FragmentActivity).supportFragmentManager,
            FlutterFragmentActivity.FRAGMENT_CONTAINER_ID,
            object :
                InAppMessageScreenActions {
                override fun readerIsOpened() {
                    print("readerIsOpened")
                }

                override fun readerOpenError(p0: String?) {
                    print("readerOpenError")
                }

                override fun readerIsClosed() {
                    print("readerIsClosed")
                }

            })
    }

    override fun preloadMessages(ids: List<String>?) {
        val preloadSettings = InAppMessagePreloadSettings();
        iasMessages.preload(preloadSettings, object : InAppMessageLoadCallback {
            override fun loaded(p0: Int) {
                print("loaded $p0")
            }

            override fun allLoaded() {
               print("allLoaded")
            }

            override fun loadError(p0: Int) {
                print("loadError $p0")
            }

            override fun loadError() {
                print("loadError")
            }

            override fun isEmpty() {
                print("isEmpty")
            }
        })
    }

    override fun close() {
    }

}