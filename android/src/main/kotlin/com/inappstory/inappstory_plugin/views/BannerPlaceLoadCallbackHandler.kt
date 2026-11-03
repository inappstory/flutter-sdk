package com.inappstory.inappstory_plugin.views

import BannerPlaceCallbackFlutterApi
import com.inappstory.sdk.banners.BannerData
import com.inappstory.sdk.banners.BannerPlaceLoadCallback

internal object InactiveBannerPlaceLoadCallback : BannerPlaceLoadCallback("") {
    override fun bannerPlaceLoaded(size: Int, bannerData: List<BannerData>, widgetHeight: Int) {}
    override fun loadError() {}
    override fun bannerLoaded(p0: Int, p1: Boolean) {}
    override fun bannerLoadError(p0: Int, p1: Boolean) {}
}

open class BannerPlaceLoadCallbackHandler(
    val placeId: String,
    private val callbackApi: BannerPlaceCallbackFlutterApi,
    private val toDp: (Int) -> Long,
    private val onVisibilityChanged: (Boolean) -> Unit = {},
    private val runOnMain: (() -> Unit) -> Unit = { it() },
    private val waitForContentLoaded: Boolean = true,
    private val waitForLayout: Boolean = false,
    private val cancelPendingCallbacks: () -> Unit = {}
) : BannerPlaceLoadCallback(placeId) {

    var isBannerPlaceLoadedSent = false
    var pendingBannerPlaceLoaded: Pair<Long, Long>? = null
    var hasBannerContentLoaded = false
    @Volatile private var disposed = false
    @Volatile private var generation = 0
    private var lastLayoutNotification: Pair<Long, Long>? = null

    fun resetState() {
        generation++
        cancelPendingCallbacks()
        isBannerPlaceLoadedSent = false
        pendingBannerPlaceLoaded = null
        hasBannerContentLoaded = false
        lastLayoutNotification = null
    }

    fun prepareForReload() {
        generation++
        cancelPendingCallbacks()
        isBannerPlaceLoadedSent = false
        pendingBannerPlaceLoaded = null
        lastLayoutNotification = null
    }

    fun dispose() {
        disposed = true
        resetState()
    }

    private fun dispatch(action: () -> Unit) {
        if (disposed) return
        val currentGeneration = generation
        runOnMain {
            if (!disposed && generation == currentGeneration) action()
        }
    }

    fun onContentLayout(heightPx: Int) {
        dispatch {
            val pending = pendingBannerPlaceLoaded
            if (waitForLayout && pending != null && heightPx > 0) {
                val notification = Pair(pending.first, toDp(heightPx))
                if (notification != lastLayoutNotification) {
                    lastLayoutNotification = notification
                    isBannerPlaceLoadedSent = true
                    onVisibilityChanged(true)
                    callbackApi.onBannerPlaceLoaded(notification.first, notification.second) {}
                }
            }
        }
    }

    override fun bannerPlaceLoaded(
        size: Int, bannerData: List<BannerData>, widgetHeight: Int
    ) {
        dispatch {
            if (size <= 0 || bannerData.isEmpty()) {
                isBannerPlaceLoadedSent = true
                pendingBannerPlaceLoaded = null
                lastLayoutNotification = null
                onVisibilityChanged(false)
                callbackApi.onBannerPlaceLoaded(0L, 0L) {}
            } else {
                val heightDp = if (!waitForLayout && widgetHeight > 0) toDp(widgetHeight) else 0L
                pendingBannerPlaceLoaded = Pair(size.toLong(), heightDp)
                if (!waitForLayout && (!waitForContentLoaded || hasBannerContentLoaded) &&
                    !isBannerPlaceLoadedSent
                ) {
                    isBannerPlaceLoadedSent = true
                    onVisibilityChanged(true)
                    callbackApi.onBannerPlaceLoaded(size.toLong(), heightDp) {}
                }

            }
        }
    }

    override fun loadError() {
        dispatch {
            isBannerPlaceLoadedSent = true
            pendingBannerPlaceLoaded = null
            hasBannerContentLoaded = false
            lastLayoutNotification = null
            onVisibilityChanged(false)
            callbackApi.onBannerPlaceLoadError("Failed to load banner place") {}
        }
    }

    override fun bannerLoaded(p0: Int, p1: Boolean) {
        dispatch {
            hasBannerContentLoaded = true
            if (!waitForLayout && !isBannerPlaceLoadedSent) {
                val pending = pendingBannerPlaceLoaded
                if (pending != null) {
                    isBannerPlaceLoadedSent = true
                    onVisibilityChanged(true)
                    callbackApi.onBannerPlaceLoaded(pending.first, pending.second) {}
                }
            }
        }
    }

    override fun bannerLoadError(p0: Int, p1: Boolean) {
        dispatch {
            if (!isBannerPlaceLoadedSent) {
                val pending = pendingBannerPlaceLoaded
                if (pending != null) {
                    if (!waitForLayout) {
                        isBannerPlaceLoadedSent = true
                        onVisibilityChanged(true)
                        callbackApi.onBannerPlaceLoaded(pending.first, pending.second) {}
                    }
                } else {
                    isBannerPlaceLoadedSent = true
                    onVisibilityChanged(false)
                    callbackApi.onBannerPlaceLoadError("Failed to load banner content") {}
                }
            }
        }
    }
}
