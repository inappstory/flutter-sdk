package com.inappstory.inappstory_plugin.views

import BannerPlaceCallbackFlutterApi
import com.inappstory.sdk.banners.BannerData
import com.inappstory.sdk.banners.BannerPlaceLoadCallback

open class BannerPlaceLoadCallbackHandler(
    val placeId: String,
    private val callbackApi: BannerPlaceCallbackFlutterApi,
    private val toDp: (Int) -> Long,
    private val onVisibilityChanged: (Boolean) -> Unit = {},
    private val runOnMain: (() -> Unit) -> Unit = { it() }
) : BannerPlaceLoadCallback(placeId) {

    var isBannerPlaceLoadedSent = false
    var pendingBannerPlaceLoaded: Pair<Long, Long>? = null
    var hasBannerContentLoaded = false

    fun resetState() {
        isBannerPlaceLoadedSent = false
        pendingBannerPlaceLoaded = null
        hasBannerContentLoaded = false
    }

    override fun bannerPlaceLoaded(
        size: Int, bannerData: List<BannerData>, widgetHeight: Int
    ) {
        runOnMain {
            if (size <= 0 || bannerData.isEmpty()) {
                isBannerPlaceLoadedSent = true
                pendingBannerPlaceLoaded = null
                onVisibilityChanged(false)
                callbackApi.onBannerPlaceLoaded(0L, 0L) {}
            } else {
                val heightDp = toDp(widgetHeight)
                pendingBannerPlaceLoaded = Pair(size.toLong(), heightDp)
                if (hasBannerContentLoaded && !isBannerPlaceLoadedSent) {
                    isBannerPlaceLoadedSent = true
                    onVisibilityChanged(true)
                    callbackApi.onBannerPlaceLoaded(size.toLong(), heightDp) {}
                }
            }
        }
    }

    override fun loadError() {
        runOnMain {
            isBannerPlaceLoadedSent = true
            pendingBannerPlaceLoaded = null
            hasBannerContentLoaded = false
            onVisibilityChanged(false)
            callbackApi.onBannerPlaceLoadError("Failed to load banner place") {}
        }
    }

    override fun bannerLoaded(p0: Int, p1: Boolean) {
        runOnMain {
            hasBannerContentLoaded = true
            if (!isBannerPlaceLoadedSent) {
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
        runOnMain {
            if (!isBannerPlaceLoadedSent) {
                val pending = pendingBannerPlaceLoaded
                if (pending != null) {
                    isBannerPlaceLoadedSent = true
                    onVisibilityChanged(true)
                    callbackApi.onBannerPlaceLoaded(pending.first, pending.second) {}
                } else {
                    isBannerPlaceLoadedSent = true
                    onVisibilityChanged(false)
                    callbackApi.onBannerPlaceLoadError("Failed to load banner content") {}
                }
            }
        }
    }
}
