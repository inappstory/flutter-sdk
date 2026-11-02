package com.inappstory.inappstory_plugin.views

import BannerPlaceCallbackFlutterApi
import BannerViewHostApi
import android.content.Context
import android.os.Handler
import android.view.View
import android.widget.FrameLayout
import com.inappstory.inappstory_plugin.adaptors.BannerPlaceLoadError
import com.inappstory.inappstory_plugin.adaptors.BannerPlacePreloadError
import com.inappstory.inappstory_plugin.adaptors.IASBannerPlaceManagerAdaptor
import com.inappstory.inappstory_plugin.adaptors.LoadBannerPlace
import com.inappstory.inappstory_plugin.adaptors.PauseAutoscroll
import com.inappstory.inappstory_plugin.adaptors.PreloadBannerPlace
import com.inappstory.inappstory_plugin.adaptors.ReloadBannerPlace
import com.inappstory.inappstory_plugin.adaptors.ResumeAutoscroll
import com.inappstory.inappstory_plugin.adaptors.SetInteraction
import com.inappstory.inappstory_plugin.adaptors.ShowByIndex
import com.inappstory.inappstory_plugin.adaptors.ShowNext
import com.inappstory.inappstory_plugin.adaptors.ShowPrevious
import com.inappstory.inappstory_plugin.adaptors.Subscription
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.banners.BannerData
import com.inappstory.sdk.banners.BannerPlaceLoadSettings
import com.inappstory.sdk.banners.BannerPlacePreloadCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.platform.PlatformView
import kotlin.math.ceil

abstract class BannerViewBase(
    protected val context: Context,
    creationParams: Map<String?, Any?>?,
    protected val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    protected val appearanceManager: AppearanceManager,
    private val bannerPlaceManagerAdaptor: IASBannerPlaceManagerAdaptor,
    private val bannerDataListener: BannerDataListener
) : PlatformView, BannerViewHostApi {

    protected var placeId: String =
        creationParams?.get("placeId") as String? ?: "customBannerPlace"
        private set
    protected val bannerWidgetId: String =
        creationParams?.get("bannerWidgetId") as String? ?: "bannerWidgetId"
    protected val bannerPlaceCallback = BannerPlaceCallbackFlutterApi(
        flutterPluginBinding.binaryMessenger,
        messageChannelSuffix = bannerWidgetId
    )
    protected val frame = FrameLayout(context)

    private var nativeBannerView: View? = null
    private var bannerLoadCallbackHandler: BannerPlaceLoadCallbackHandler? = null
    private val bannersData: BannersData = { bannerData, eventName, widgetData ->
        if (bannerData.bannerPlace == placeId) {
            flutterPluginBinding.runOnMainThread {
                bannerPlaceCallback.onActionWith(bannerData, eventName, widgetData) {}
            }
        }
    }

    private lateinit var loadError: Subscription
    private lateinit var preloadError: Subscription
    private lateinit var loadBannerPlace: Subscription
    private lateinit var reloadBannerPlace: Subscription
    private lateinit var preloadBannerPlace: Subscription
    private lateinit var showNextSubscription: Subscription
    private lateinit var showPreviousSubscription: Subscription
    private lateinit var showByIndexSubscription: Subscription
    private lateinit var pauseAutoscroll: Subscription
    private lateinit var resumeAutoscroll: Subscription
    private lateinit var setInteraction: Subscription

    protected abstract fun configureAppearance(creationParams: Map<String?, Any?>?)
    protected abstract fun createBannerView(
        placeId: String,
        loadCallback: BannerPlaceLoadCallbackHandler
    ): View
    protected abstract fun loadBanners()
    protected abstract fun reloadBanners()
    protected abstract fun pauseBanners()
    protected abstract fun resumeBanners()
    protected abstract fun disposeBannerView(view: View?)
    protected open val waitForContentLoaded: Boolean = true
    protected open val waitForLayout: Boolean = false
    protected open fun showNext() {}
    protected open fun showPrevious() {}
    protected open fun showByIndex(index: Int) {}

    protected fun initialize(creationParams: Map<String?, Any?>?) {
        frame.visibility = View.INVISIBLE
        BannerViewHostApi.setUp(
            flutterPluginBinding.binaryMessenger,
            this,
            messageChannelSuffix = bannerWidgetId
        )
        bannerDataListener.addListener(bannersData)
        configureAppearance(creationParams)
        nativeBannerView = createBannerView(placeId, createLoadCallback(placeId))
        frame.addView(nativeBannerView)
        subscribeToEvents()
        if (creationParams?.get("autoLoad") as? Boolean? ?: true) {
            reloadBanners()
        }
    }

    override fun getView(): View = frame

    override fun dispose() = deInitBannerPlace()

    private fun createLoadCallback(placeId: String): BannerPlaceLoadCallbackHandler {
        val mainHandler = Handler(context.mainLooper)
        return BannerPlaceLoadCallbackHandler(
            placeId = placeId,
            callbackApi = bannerPlaceCallback,
            toDp = { px ->
                val dp = context.toDp(px)
                if (waitForLayout) ceil(dp.toDouble()).toLong() else dp.toLong()
            },
            onVisibilityChanged = { visible ->
                frame.visibility = if (visible) View.VISIBLE else View.GONE
            },
            runOnMain = { action -> mainHandler.post(action) },
            waitForContentLoaded = waitForContentLoaded,
            waitForLayout = waitForLayout,
            cancelPendingCallbacks = { mainHandler.removeCallbacksAndMessages(null) }
        ).also { bannerLoadCallbackHandler = it }
    }

    private fun subscribeToEvents() {
        loadBannerPlace = bannerPlaceManagerAdaptor.subscribe(LoadBannerPlace) { payload ->
            if (payload == placeId) {
                recreateBannerView(placeId)
                loadBanners()
            }
        }
        reloadBannerPlace = bannerPlaceManagerAdaptor.subscribe(ReloadBannerPlace) { payload ->
            if (payload == placeId) {
                recreateBannerView(placeId)
                reloadBanners()
            }
        }
        preloadBannerPlace = bannerPlaceManagerAdaptor.subscribe(PreloadBannerPlace) { payload ->
            if (payload == placeId) preloadBannerPlace()
        }
        showNextSubscription = bannerPlaceManagerAdaptor.subscribe(ShowNext) { payload ->
            if (payload == placeId) showNext()
        }
        showPreviousSubscription = bannerPlaceManagerAdaptor.subscribe(ShowPrevious) { payload ->
            if (payload == placeId) showPrevious()
        }
        showByIndexSubscription = bannerPlaceManagerAdaptor.subscribe(ShowByIndex) { payload ->
            if (payload.placeId == placeId) showByIndex(payload.index.toInt())
        }
        pauseAutoscroll = bannerPlaceManagerAdaptor.subscribe(PauseAutoscroll) { payload ->
            if (payload == placeId) pauseBanners()
        }
        resumeAutoscroll = bannerPlaceManagerAdaptor.subscribe(ResumeAutoscroll) { payload ->
            if (payload == placeId) resumeBanners()
        }
        setInteraction = bannerPlaceManagerAdaptor.subscribe(SetInteraction) { payload ->
            if (payload.placeId == placeId) updateInteraction(payload.isInteractionEnabled)
        }
        loadError = bannerPlaceManagerAdaptor.subscribe(BannerPlaceLoadError) { payload ->
            if (payload.placeId == null || payload.placeId == placeId) {
                flutterPluginBinding.runOnMainThread {
                    resetLoadState()
                    bannerPlaceCallback.onBannerPlaceLoadError(payload.message) {}
                }
            }
        }
        preloadError = bannerPlaceManagerAdaptor.subscribe(BannerPlacePreloadError) { payload ->
            if (payload == placeId) {
                flutterPluginBinding.runOnMainThread {
                    bannerPlaceCallback.onBannerPlacePreloadedError {}
                }
            }
        }
    }

    private fun preloadBannerPlace() {
        InAppStoryManager.getInstance()?.preloadBannerPlace(
            BannerPlaceLoadSettings().placeId(placeId),
            object : BannerPlacePreloadCallback(placeId) {
                override fun bannerPlaceLoaded(size: Int, bannerData: List<BannerData>) {
                    flutterPluginBinding.runOnMainThread {
                        bannerPlaceCallback.onBannerPlacePreloaded() {}
                    }
                }

                override fun loadError() {
                    flutterPluginBinding.runOnMainThread {
                        bannerPlaceCallback.onBannerPlacePreloadedError() {}
                    }
                }

                override fun bannerContentLoaded(bannerId: Int, isFirst: Boolean) {}

                override fun bannerContentLoadError(bannerId: Int, isFirst: Boolean) {}
            }
        )
    }

    private fun updateInteraction(isInteractionEnabled: Boolean) {
        flutterPluginBinding.runOnMainThread {
            frame.isEnabled = isInteractionEnabled
            frame.isClickable = isInteractionEnabled
            nativeBannerView?.isEnabled = isInteractionEnabled
            nativeBannerView?.isClickable = isInteractionEnabled
        }
    }

    override fun setInteraction(isInteractionEnabled: Boolean) {
        updateInteraction(isInteractionEnabled)
    }

    override fun changeBannerPlaceId(newPlaceId: String) {
        placeId = newPlaceId
        recreateBannerView(newPlaceId)
        reloadBanners()
    }

    private fun recreateBannerView(placeId: String) {
        bannerLoadCallbackHandler?.dispose()
        if (waitForLayout) frame.visibility = View.INVISIBLE
        val oldView = nativeBannerView
        disposeBannerView(oldView)
        frame.removeView(oldView)
        nativeBannerView = createBannerView(placeId, createLoadCallback(placeId))
        frame.addView(nativeBannerView)
        updateInteraction(frame.isEnabled)
    }

    private fun resetLoadState() {
        bannerLoadCallbackHandler?.resetState()
        frame.visibility = View.INVISIBLE
    }

    override fun deInitBannerPlace() {
        bannerLoadCallbackHandler?.dispose()
        resetLoadState()
        loadBannerPlace.unsubscribe()
        reloadBannerPlace.unsubscribe()
        preloadBannerPlace.unsubscribe()
        showNextSubscription.unsubscribe()
        showPreviousSubscription.unsubscribe()
        showByIndexSubscription.unsubscribe()
        pauseAutoscroll.unsubscribe()
        resumeAutoscroll.unsubscribe()
        setInteraction.unsubscribe()
        loadError.unsubscribe()
        preloadError.unsubscribe()
        frame.removeAllViews()
        disposeBannerView(nativeBannerView)
        nativeBannerView = null
        BannerViewHostApi.setUp(
            flutterPluginBinding.binaryMessenger,
            null,
            messageChannelSuffix = bannerWidgetId
        )
        bannerDataListener.removeListener(bannersData)
    }
}

internal fun Context.toDp(px: Int): Float =
    px / resources.displayMetrics.density
