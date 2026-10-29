package com.inappstory.inappstory_plugin.views

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.banners.ui.grid.BannerGrid
import com.inappstory.sdk.banners.ui.grid.DefaultBannerGridAppearance
import com.inappstory.inappstory_plugin.adaptors.IASBannerPlaceManagerAdaptor
import io.flutter.embedding.engine.plugins.FlutterPlugin

class BannerGridView(
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
    private var bannerGrid: BannerGrid? = null
    override val waitForContentLoaded: Boolean = false

    init {
        initialize(creationParams)
    }

    override fun configureAppearance(creationParams: Map<String?, Any?>?) {
        appearanceManager.csBannerGridInterface(
            CustomBannerGridAppearance(
                horizontalGap = (creationParams?.get("gridHorizontalGap") as? Number)?.toInt(),
                verticalGap = (creationParams?.get("gridVerticalGap") as? Number)?.toInt(),
                cornerRadius = (creationParams?.get("gridCornerRadius") as? Number)?.toInt(),
                loadingPlaceholder = placeholderStore::createView,
            )
        )
    }

    override fun createBannerView(
        placeId: String,
        loadCallback: BannerPlaceLoadCallbackHandler
    ): View {
        return BannerGrid(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            setAppearanceManager(appearanceManager)
            loadCallback(loadCallback)
            setPlaceId(placeId)
            bannerGrid = this
        }
    }

    override fun loadBanners() {
        bannerGrid?.loadBanners()
    }

    override fun reloadBanners() {
        bannerGrid?.reloadBanners()
    }

    override fun pauseBanners() {
        bannerGrid?.pauseBanners()
    }

    override fun resumeBanners() {
        bannerGrid?.resumeBanners()
    }

    override fun disposeBannerView(view: View?) {
        val grid = view as? BannerGrid ?: return
        try {
            grid.setPlaceId(null)
        } catch (_: Throwable) {
        }
        bannerGrid = null
    }
}

class CustomBannerGridAppearance(
    private val horizontalGap: Int?,
    private val verticalGap: Int?,
    private val cornerRadius: Int?,
    private val loadingPlaceholder: (Context) -> View?,
) : DefaultBannerGridAppearance() {
    override fun horizontalGap(): Int = horizontalGap ?: super.horizontalGap()
    override fun verticalGap(): Int = verticalGap ?: super.verticalGap()
    override fun cornerRadius(): Int = cornerRadius ?: super.cornerRadius()

    override fun loadingPlaceholder(context: Context?): View =
        context?.let(loadingPlaceholder) ?: super.loadingPlaceholder(context)
}
