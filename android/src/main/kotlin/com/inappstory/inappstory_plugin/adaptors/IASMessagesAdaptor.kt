package com.inappstory.inappstory_plugin.adaptors

import IASInAppMessagesHostApi
import androidx.fragment.app.FragmentActivity
import com.inappstory.inappstory_plugin.activity.BackPressManagerHandler
import com.inappstory.inappstory_plugin.activity.InAppStoryActivity
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
) : IASInAppMessagesHostApi {

    private var fragmentActivity: InAppStoryActivity? = null

    init {
        IASInAppMessagesHostApi.setUp(flutterPluginBinding.binaryMessenger, this)

        if (activityHolder.activity is InAppStoryActivity) {
            fragmentActivity = (activityHolder.activity as InAppStoryActivity)

            fragmentActivity?.backPressManager?.isManagerEnabled = false

            fragmentActivity?.backPressManager?.overlayHandler =
                object : BackPressManagerHandler() {
                    override fun handleBackPress(): Boolean {
                        iasManager.let {
                            return it.onBackPressed()
                        }
                    }
                }
        }
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
                    fragmentActivity?.backPressManager?.isManagerEnabled = true
                }

                override fun readerOpenError(p0: String?) {
                    fragmentActivity?.backPressManager?.isManagerEnabled = false
                }

                override fun readerIsClosed() {
                    fragmentActivity?.backPressManager?.isManagerEnabled = false
                }
            })
    }

    override fun showByEvent(event: String, onlyPreloaded: Boolean) {
        val settings = InAppMessageOpenSettings()
            .event(event)
            .showOnlyIfLoaded(onlyPreloaded)
        iasMessages.show(
            settings,
            (activityHolder.activity as FragmentActivity).supportFragmentManager,
            FlutterFragmentActivity.FRAGMENT_CONTAINER_ID,
            object : InAppMessageScreenActions {
                override fun readerIsOpened() {
                    fragmentActivity?.backPressManager?.isManagerEnabled = true
                }

                override fun readerOpenError(p0: String?) {
                    fragmentActivity?.backPressManager?.isManagerEnabled = false

                }

                override fun readerIsClosed() {
                    fragmentActivity?.backPressManager?.isManagerEnabled = false
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