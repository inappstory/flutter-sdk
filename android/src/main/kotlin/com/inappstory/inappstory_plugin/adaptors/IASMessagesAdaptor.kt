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

    override fun showById(messageId: String, onlyPreloaded: Boolean) {
        val settings = InAppMessageOpenSettings(messageId.toInt(), onlyPreloaded, null, listOf())
        iasMessages.show(
            settings,
            (activityHolder.activity as FragmentActivity).supportFragmentManager,
            FlutterFragmentActivity.FRAGMENT_CONTAINER_ID,
            object : InAppMessageScreenActions {
                override fun readerIsOpened() {
                    print("IAM: readerIsOpened")
                }

                override fun readerOpenError(p0: String?) {
                    print("IAM: readerOpenError")
                }

                override fun readerIsClosed() {
                    print("IAM: readerIsClosed")
                }
            })
    }

    override fun showByEvent(event: String, onlyPreloaded: Boolean) {
        val settings = InAppMessageOpenSettings(null, onlyPreloaded, event, listOf())
        iasMessages.show(
            settings,
            (activityHolder.activity as FragmentActivity).supportFragmentManager,
            FlutterFragmentActivity.FRAGMENT_CONTAINER_ID,
            object : InAppMessageScreenActions {
                override fun readerIsOpened() {
                    print("IAM: readerIsOpened")
                }

                override fun readerOpenError(p0: String?) {
                    print("IAM: readerOpenError")
                }

                override fun readerIsClosed() {
                    print("IAM: readerIsClosed")
                }
            })
    }

    override fun preloadMessages(ids: List<String>?, callback: (Result<Boolean>) -> Unit) {
        val preloadSettings = InAppMessagePreloadSettings()
        iasMessages.preload(preloadSettings, object : InAppMessageLoadCallback {
            override fun loaded(p0: Int) {
                print("IAM: loaded $p0")
            }

            override fun allLoaded() {
                print("IAM: allLoaded")
                callback(Result.success(true))
            }

            override fun loadError(p0: Int) {
                print("IAM:  loadError $p0")
            }

            override fun loadError() {
                print("IIAM: loadError")
                callback(Result.success(false))
            }

            override fun isEmpty() {
                print("IAS: isEmpty")
            }
        })
    }
}