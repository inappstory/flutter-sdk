package com.inappstory.inappstory_plugin.views

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.banners.ui.banner.BannerView
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
    private var contentLayout: BannerGridContentLayout? = null
    override val waitForContentLoaded: Boolean = false
    override val waitForLayout: Boolean = true

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
        val grid = BannerGrid(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            setAppearanceManager(appearanceManager)
            (creationParams?.get("gridCornerRadius") as? Number)?.let { radius ->
                val radiusPx = radius.toFloat() * context.resources.displayMetrics.density
                // SDK 1.26.0 creates grid banners without applying cornerRadius().
                setOnHierarchyChangeListener(object : ViewGroup.OnHierarchyChangeListener {
                    override fun onChildViewAdded(parent: View, child: View) {
                        val row = child as? ViewGroup ?: return
                        for (index in 0 until row.childCount) {
                            (row.getChildAt(index) as? BannerView)?.setBannerRadius(radiusPx)
                        }
                    }

                    override fun onChildViewRemoved(parent: View, child: View) {}
                })
            }
            loadCallback(loadCallback)
            bannerGrid = this
        }
        return BannerGridContentLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            onContentLayout = loadCallback::onContentLayout
            addView(grid)
            contentLayout = this
            // Binding a place can synchronously replay cached data. The SDK
            // derives row heights from measuredWidth, so bind only after layout.
            whenWidthReady {
                grid.setPlaceId(placeId)
            }
        }
    }

    override fun loadBanners() {
        val grid = bannerGrid ?: return
        contentLayout?.whenWidthReady { grid.loadBanners() }
    }

    override fun reloadBanners() {
        val grid = bannerGrid ?: return
        contentLayout?.whenWidthReady {
            grid.reloadBanners()
        }
    }

    override fun pauseBanners() {
        bannerGrid?.pauseBanners()
    }

    override fun resumeBanners() {
        bannerGrid?.resumeBanners()
    }

    override fun disposeBannerView(view: View?) {
        (view as? BannerGridContentLayout)?.dispose()
        contentLayout = null
        val grid = bannerGrid ?: return
        grid.loadCallback(InactiveBannerPlaceLoadCallback)
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

    override fun loadingPlaceholder(context: Context?): View? =
        context?.let(loadingPlaceholder) ?: super.loadingPlaceholder(context)
}
