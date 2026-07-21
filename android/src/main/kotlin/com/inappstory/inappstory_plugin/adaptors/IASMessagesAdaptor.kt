package com.inappstory.inappstory_plugin.adaptors

import FlutterError
import IASInAppMessagesHostApi
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import com.inappstory.inappstory_plugin.R
import com.inappstory.inappstory_plugin.activity.BackPressManagerHandler
import com.inappstory.inappstory_plugin.activity.InAppStoryActivity
import com.inappstory.sdk.CancellationToken
import com.inappstory.sdk.CancellationTokenCancelResult
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.externalapi.inappmessage.IASInAppMessageExternalAPI
import com.inappstory.sdk.inappmessage.InAppMessageLoadCallback
import com.inappstory.sdk.inappmessage.InAppMessageOpenSettings
import com.inappstory.sdk.inappmessage.InAppMessagePreloadSettings
import com.inappstory.sdk.inappmessage.InAppMessageScreenActions
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin


class IASMessagesAdaptor(
    flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val iasMessages: IASInAppMessageExternalAPI,
    private val iasManager: InAppStoryManager,
    private val activityHolder: ActivityHolder,
) : IASInAppMessagesHostApi {

    private var fragmentActivity: InAppStoryActivity? = null

    private var currentContainer: Fragment? = null

    private val tokenMap = mutableMapOf<String, CancellationToken>()

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

    override fun showById(
        messageId: String,
        token: String,
        onlyPreloaded: Boolean,
        bottomPadding: Double?
    ) {
        val settings =
            InAppMessageOpenSettings().id(messageId.toInt()).showOnlyIfLoaded(onlyPreloaded)
        showIAM(settings, token, bottomPadding)
    }

    override fun showByEvent(
        event: String,
        token: String,
        onlyPreloaded: Boolean,
        bottomPadding: Double?
    ) {
        val settings = InAppMessageOpenSettings().event(event).showOnlyIfLoaded(onlyPreloaded)
        showIAM(settings, token, bottomPadding)
    }

    private fun showIAM(
        settings: InAppMessageOpenSettings,
        token: String,
        bottomPadding: Double?
    ) {
        val activity = activityHolder.activity as? FragmentActivity
            ?: throw FlutterError(
                "no_container",
                "There is no FragmentActivity to show InAppMessage in"
            )
        val containerFragment = Fragment(R.layout.ias_message_container)
        activity.supportFragmentManager.beginTransaction()
            .add(FlutterFragmentActivity.FRAGMENT_CONTAINER_ID, containerFragment)
            .commitNow()
        currentContainer = containerFragment

        containerFragment.view?.let { view ->
            val bottom = ((bottomPadding ?: 0.0) * view.resources.displayMetrics.density).toInt()
            view.setPadding(view.paddingLeft, view.paddingTop, view.paddingRight, bottom)
        }

        val cancellationToken = iasMessages.show(
            settings,
            activity.supportFragmentManager,
            R.id.ias_message_fragment_container,
            object : InAppMessageScreenActions {
                override fun readerIsOpened() {
                    fragmentActivity?.backPressManager?.isManagerEnabled = true
                }

                override fun readerOpenError(p0: String?) {
                    fragmentActivity?.backPressManager?.isManagerEnabled = false
                    removeContainer()
                }

                override fun readerIsClosed() {
                    fragmentActivity?.backPressManager?.isManagerEnabled = false
                    removeContainer()
                }
            })

        tokenMap[token] = cancellationToken
    }

    private fun removeContainer() {
        val fragment = currentContainer ?: return
        currentContainer = null

        val activity = activityHolder.activity as? FragmentActivity ?: return
        if (fragment.isAdded) {
            activity.supportFragmentManager.beginTransaction()
                .remove(fragment)
                .commitAllowingStateLoss()
        }
    }

    override fun cancelByToken(token: String): Boolean {
        if (tokenMap.containsKey(token)) {
            val result = tokenMap[token]?.cancel()
            tokenMap.remove(token)
            if (result == CancellationTokenCancelResult.SUCCESS) {
                removeContainer()
            }
            return result == CancellationTokenCancelResult.SUCCESS
        }
        return false
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