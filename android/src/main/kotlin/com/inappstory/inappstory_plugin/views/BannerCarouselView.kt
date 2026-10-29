package com.inappstory.inappstory_plugin.views

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.banners.BannerCarouselNavigationCallback
import com.inappstory.sdk.banners.BannerData
import com.inappstory.sdk.banners.BannerPlaceLoadCallback
import com.inappstory.sdk.banners.ui.carousel.BannerCarousel
import com.inappstory.sdk.banners.ui.carousel.DefaultBannerCarouselAppearance
import com.inappstory.inappstory_plugin.adaptors.IASBannerPlaceManagerAdaptor
import io.flutter.embedding.engine.plugins.FlutterPlugin

class BannerCarouselView(
    context: Context,
    private val creationParams: Map<String?, Any?>?,
    flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    appearanceManager: AppearanceManager,
    bannerPlaceManagerAdaptor: IASBannerPlaceManagerAdaptor,
    bannerDataListener: BannerDataListener,
    private val placeholderStore: BannerPlaceholderStore,
) : BannerViewBase(
    context,
    creationParams,
    flutterPluginBinding,
    appearanceManager,
    bannerPlaceManagerAdaptor,
    bannerDataListener
) {
    private var bannerCarousel: BannerCarousel? = null

    init {
        initialize(creationParams)
    }

    override fun configureAppearance(creationParams: Map<String?, Any?>?) {
        appearanceManager.csBannerCarouselInterface(
            CustomBannerCarouselAppearance(
                bannerOffset = (creationParams?.get("bannerOffset") as? Number)?.toInt(),
                bannersGap = (creationParams?.get("bannersGap") as? Number)?.toInt(),
                cornerRadius = (creationParams?.get("cornerRadius") as? Number)?.toInt(),
                loop = creationParams?.get("loop") as? Boolean,
                loadingPlaceholder = placeholderStore::createView,
            )
        )
    }

    override fun createBannerView(
        placeId: String,
        loadCallback: BannerPlaceLoadCallbackHandler
    ): View {
        return BannerCarousel(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            setAppearanceManager(appearanceManager)
            navigationCallback(object : BannerCarouselNavigationCallback {
                override fun onPageScrolled(
                    position: Int,
                    total: Int,
                    positionOffset: Float,
                    positionOffsetPixels: Int
                ) {}

                override fun onPageSelected(position: Int, total: Int) {
                    flutterPluginBinding.runOnMainThread {
                        bannerPlaceCallback.onBannerScroll(position.toLong()) {}
                    }
                }
            })
            loadCallback(loadCallback)
            setPlaceId(placeId)
            bannerCarousel = this
        }
    }

    override fun loadBanners() {
        bannerCarousel?.loadBanners()
    }

    override fun reloadBanners() {
        bannerCarousel?.reloadBanners()
    }

    override fun pauseBanners() {
        bannerCarousel?.pauseAutoscroll()
    }

    override fun resumeBanners() {
        bannerCarousel?.resumeAutoscroll()
    }

    override fun showNext() {
        bannerCarousel?.showNext()
    }

    override fun showPrevious() {
        bannerCarousel?.showPrevious()
    }

    override fun showByIndex(index: Int) {
        bannerCarousel?.showByIndex(index)
    }

    override fun disposeBannerView(view: View?) {
        val carousel = view as? BannerCarousel ?: return
        try {
            carousel.loadCallback(object : BannerPlaceLoadCallback("") {
                override fun bannerPlaceLoaded(
                    size: Int,
                    bannerData: List<BannerData>,
                    widgetHeight: Int
                ) {}

                override fun loadError() {}
                override fun bannerLoaded(p0: Int, p1: Boolean) {}
                override fun bannerLoadError(p0: Int, p1: Boolean) {}
            })
        } catch (_: Throwable) {
        }
        try {
            carousel.navigationCallback(null)
        } catch (_: Throwable) {
        }
        try {
            carousel.setPlaceId(null)
            carousel.clear()
        } catch (_: Throwable) {
        }
        bannerCarousel = null
    }
}

class CustomBannerCarouselAppearance(
    private val bannerOffset: Int?,
    private val bannersGap: Int?,
    private val cornerRadius: Int?,
    private val loop: Boolean?,
    private val loadingPlaceholder: (Context) -> View?,
) : DefaultBannerCarouselAppearance() {
    override fun nextBannerOffset(): Int = bannerOffset ?: super.nextBannerOffset()
    override fun prevBannerOffset(): Int = bannerOffset ?: super.prevBannerOffset()
    override fun bannersGap(): Int = bannersGap ?: super.bannersGap()
    override fun cornerRadius(): Int = cornerRadius ?: super.cornerRadius()
    override fun loop(): Boolean = loop ?: super.loop()

    override fun loadingPlaceholder(context: Context?): View =
        context?.let(loadingPlaceholder) ?: super.loadingPlaceholder(context)
}
