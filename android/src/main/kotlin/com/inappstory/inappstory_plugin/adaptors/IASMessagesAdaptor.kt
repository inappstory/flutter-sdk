package com.inappstory.inappstory_plugin.adaptors

import IASInAppMessagesHostApi
import androidx.activity.OnBackPressedCallback
import androidx.fragment.app.FragmentActivity
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.core.api.IASInAppMessage
import com.inappstory.sdk.inappmessage.InAppMessageLoadCallback
import com.inappstory.sdk.inappmessage.InAppMessageOpenSettings
import com.inappstory.sdk.inappmessage.InAppMessagePreloadSettings
import com.inappstory.sdk.inappmessage.InAppMessageScreenActions
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin


class IASMessagesAdaptor(
    flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val iasMessages: IASInAppMessage,
    private val iasManager: InAppStoryManager,
    private val activityHolder: ActivityHolder,
    private var onBackPressedCallback: OnBackPressedCallback?,
) : IASInAppMessagesHostApi {

    init {
        IASInAppMessagesHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
        val fragmentActivity = (activityHolder.activity as FragmentActivity)
        onBackPressedCallback = object : OnBackPressedCallback(false) {
            override fun handleOnBackPressed() {
                iasManager.let {
                    if (it.onBackPressed())
                        return
                }
            }
        }
        fragmentActivity.onBackPressedDispatcher.addCallback(
            onBackPressedCallback = onBackPressedCallback!!
        )
    }

    override fun showById(messageId: String, onlyPreloaded: Boolean) {
        val settings = InAppMessageOpenSettings()
            .id(messageId.toInt())
            .showOnlyIfLoaded(onlyPreloaded)
        iasMessages.show(
            settings,
            (activityHolder.activity as FragmentActivity).supportFragmentManager,
            FlutterFragmentActivity.FRAGMENT_CONTAINER_ID,
            object : InAppMessageScreenActions {
                override fun readerIsOpened() {
                    onBackPressedCallback?.isEnabled = true
                }

                override fun readerOpenError(p0: String?) {
                    onBackPressedCallback?.isEnabled = false
                    onBackPressedCallback?.remove()
                }

                override fun readerIsClosed() {
                    onBackPressedCallback?.isEnabled = false
                    onBackPressedCallback?.remove()
                }
            })
    }

    override fun showByEvent(event: String, onlyPreloaded: Boolean) {
        val fragmentManager = (activityHolder.activity as FragmentActivity).supportFragmentManager
        (activityHolder.activity as FragmentActivity).onBackPressedDispatcher.addCallback(
            onBackPressedCallback = object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    iasManager.let {
                        if (it.onBackPressed())
                            return
                    }
                }

            })
        val settings = InAppMessageOpenSettings()
            .event(event)
            .showOnlyIfLoaded(onlyPreloaded)
        iasMessages.show(
            settings,
            fragmentManager,
            FlutterFragmentActivity.FRAGMENT_CONTAINER_ID,
            object : InAppMessageScreenActions {
                override fun readerIsOpened() {
                    onBackPressedCallback?.isEnabled = true
                }

                override fun readerOpenError(p0: String?) {
                    onBackPressedCallback?.isEnabled = false
                    onBackPressedCallback?.remove()
                }

                override fun readerIsClosed() {
                    onBackPressedCallback?.isEnabled = false
                    onBackPressedCallback?.remove()
                }
            })
    }

    override fun preloadMessages(ids: List<String>?, callback: (Result<Boolean>) -> Unit) {
        val preloadSettings = InAppMessagePreloadSettings()
        iasMessages.preload(preloadSettings, object : InAppMessageLoadCallback {
            override fun loaded(p0: Int) {
            }

            override fun allLoaded() {
                callback(Result.success(true))
            }

            override fun loadError(p0: Int) {
            }

            override fun loadError() {
                callback(Result.success(false))
            }

            override fun isEmpty() {
            }
        })
    }
}