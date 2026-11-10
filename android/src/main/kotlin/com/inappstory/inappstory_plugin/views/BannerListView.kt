package com.inappstory.inappstory_plugin.views

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import androidx.recyclerview.widget.RecyclerView
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.banners.ui.banner.BannerView
import com.inappstory.sdk.banners.ui.list.BannerList
import com.inappstory.sdk.banners.ui.list.DefaultBannerListAppearance
import com.inappstory.inappstory_plugin.adaptors.IASBannerPlaceManagerAdaptor
import io.flutter.embedding.engine.plugins.FlutterPlugin

class BannerListView(
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
    private var bannerList: BannerList? = null

    init {
        initialize(creationParams)
    }

    override fun configureAppearance(creationParams: Map<String?, Any?>?) {
        appearanceManager.csBannerListInterface(
            CustomBannerListAppearance(
                bannersGap =
                    (creationParams?.get("listVerticalGap") as? Number)?.toInt(),
                cornerRadius =
                    (creationParams?.get("listCornerRadius") as? Number)?.toInt(),
                loadingPlaceholder = placeholderStore::createView,
            )
        )
    }

    override fun createBannerView(
        placeId: String,
        loadCallback: BannerPlaceLoadCallbackHandler
    ): View {
        return BannerList(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            setAppearanceManager(appearanceManager)
            val density = context.resources.displayMetrics.density
            (creationParams?.get("listEdgePadding") as? Number)?.let { padding ->
                val sidePadding = (padding.toFloat() * density).toInt()
                setPadding(sidePadding, paddingTop, sidePadding, paddingBottom)
            }
            (creationParams?.get("listCornerRadius") as? Number)?.let { radius ->
                val radiusPx = radius.toFloat() * density
                // SDK 1.26.0 binds list items with a hard-coded 16dp radius.
                addOnChildAttachStateChangeListener(
                    object : RecyclerView.OnChildAttachStateChangeListener {
                        override fun onChildViewAttachedToWindow(view: View) {
                            view.findViewById<BannerView>(com.inappstory.sdk.R.id.bannerView)
                                ?.setBannerRadius(radiusPx)
                        }

                        override fun onChildViewDetachedFromWindow(view: View) {}
                    }
                )
            }
            loadCallback(loadCallback)
            setPlaceId(placeId)
            bannerList = this
        }
    }

    override fun loadBanners() {
        bannerList?.loadBanners()
    }

    override fun reloadBanners() {
        bannerList?.reloadBanners()
    }

    override fun pauseBanners() {
        bannerList?.pauseBanners()
    }

    override fun resumeBanners() {
        bannerList?.resumeBanners()
    }

    override fun disposeBannerView(view: View?) {
        val list = view as? BannerList ?: return
        list.loadCallback(InactiveBannerPlaceLoadCallback)
        list.setPlaceId(null)
        bannerList = null
    }
}

internal class CustomBannerListAppearance(
    private val loadingPlaceholder: (Context) -> View?,
    private val bannersGap: Int? = null,
    private val cornerRadius: Int? = null,
) : DefaultBannerListAppearance() {
    override fun orientation(): Int = RecyclerView.VERTICAL

    override fun bannersGap(): Int = bannersGap ?: super.bannersGap()

    override fun cornerRadius(): Int = cornerRadius ?: super.cornerRadius()

    override fun loadingPlaceholder(context: Context?): View? =
        context?.let(loadingPlaceholder) ?: super.loadingPlaceholder(context)
}
