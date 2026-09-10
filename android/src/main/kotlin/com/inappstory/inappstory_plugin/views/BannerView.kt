package com.inappstory.inappstory_plugin.views

import BannerDecorationDTO
import BannerPlaceCallbackFlutterApi
import BannerViewHostApi
import android.content.Context
import android.content.res.AssetFileDescriptor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import androidx.appcompat.widget.AppCompatImageView
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
import com.inappstory.sdk.banners.BannerCarouselNavigationCallback
import com.inappstory.sdk.banners.BannerData
import com.inappstory.sdk.banners.BannerPlaceLoadCallback
import com.inappstory.sdk.banners.BannerPlaceLoadSettings
import com.inappstory.sdk.banners.BannerPlacePreloadCallback
import com.inappstory.sdk.banners.ui.carousel.BannerCarousel
import com.inappstory.sdk.banners.ui.carousel.DefaultBannerCarouselAppearance
import com.inappstory.sdk.core.IASCore
import com.inappstory.sdk.core.UseIASCoreCallback
import com.inappstory.sdk.core.banners.BannersWidgetLoadStates
import com.inappstory.sdk.network.models.RequestLocalParameters
import com.inappstory.sdk.stories.api.models.callbacks.OpenSessionCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.platform.PlatformView
import java.io.IOException

class BannerView(
    private val context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?,
    val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val appearanceManager: AppearanceManager,
    bannerPlaceManagerAdaptor: IASBannerPlaceManagerAdaptor,
    private var bannerDataListener: BannerDataListener
) : PlatformView, BannerViewHostApi {

    private var bannerWidgetId: String
    private var placeId: String

    private var bannerPlace: BannerCarousel? = null
    private val frame: FrameLayout

    private var bannerPlaceCallback: BannerPlaceCallbackFlutterApi

    private var loadBannerPlace: Subscription
    private var reloadBannerPlace: Subscription
    private var preloadBannerPlace: Subscription
    private var showNext: Subscription
    private var showPrevious: Subscription
    private var showByIndex: Subscription
    private var pauseAutoscroll: Subscription
    private var resumeAutoscroll: Subscription
    private var setInteraction: Subscription

    private var bannerLoadCallbackHandler: BannerPlaceLoadCallbackHandler? = null

    private fun resetLoadState() {
        bannerLoadCallbackHandler?.resetState()
        frame.visibility = View.INVISIBLE
    }


    private var bannersData: BannersData

    override fun getView(): View {
        return frame
    }

    override fun dispose() {
        deInitBannerPlace()
    }

    init {
        placeId = creationParams?.get("placeId") as String? ?: "customBannerPlace"
        bannerWidgetId = creationParams?.get("bannerWidgetId") as String? ?: "bannerWidgetId"
        bannerPlaceCallback =
            BannerPlaceCallbackFlutterApi(
                flutterPluginBinding.binaryMessenger,
                messageChannelSuffix = bannerWidgetId
            )

        BannerViewHostApi.setUp(
            flutterPluginBinding.binaryMessenger, this, messageChannelSuffix = bannerWidgetId
        )

        bannersData = { bannerData, eventName, widgetData ->
            if (bannerData.bannerPlace == placeId) {
                flutterPluginBinding.runOnMainThread {
                    bannerPlaceCallback.onActionWith(
                        bannerData,
                        eventName,
                        widgetData,
                    ) {}
                }
            }
        }

        bannerDataListener.addListener(listener = this.bannersData)

        val loop: Boolean? = creationParams?.get("loop") as? Boolean?
        val bannerOffset: Int? = creationParams?.get("bannerOffset") as? Int?
        val bannersGap: Int? = creationParams?.get("bannersGap") as? Int?
        val cornerRadius: Int? = creationParams?.get("cornerRadius") as? Int?


        val decoration: BannerDecorationDTO?
        val bannerAppearance: DefaultBannerCarouselAppearance?

        val bannerDecorationMap = creationParams?.get("bannerDecoration") as? Map<*, *>
        if (bannerDecorationMap != null) {
            @Suppress("UNCHECKED_CAST")
            decoration = decorationToDTO(bannerDecorationMap as Map<String, Any?>)
            bannerAppearance = CustomBannerPlaceAppearance(
                flutterPluginBinding,
                flutterPluginBinding.getFlutterAssets(),
                bannerOffset,
                bannersGap,
                cornerRadius,
                loop,
                decoration,
            )
        } else {
            bannerAppearance = CustomBannerPlaceAppearanceWithoutBannerDecoration(
                bannerOffset,
                bannersGap,
                cornerRadius,
                loop,
            )
        }

        appearanceManager.csBannerCarouselInterface(bannerAppearance)

        frame = FrameLayout(context)
        frame.visibility = View.INVISIBLE

        createBannerCarousel(placeId)

        loadBannerPlace = bannerPlaceManagerAdaptor.subscribe(LoadBannerPlace) { payload ->
            if (payload != placeId) {
                return@subscribe
            }
            resetLoadState()
            loadBannersInternal()
        }

        reloadBannerPlace = bannerPlaceManagerAdaptor.subscribe(ReloadBannerPlace) { payload ->
            if (payload != placeId) {
                return@subscribe
            }
            resetLoadState()
            bannerPlace?.reloadBanners()
        }

        preloadBannerPlace = bannerPlaceManagerAdaptor.subscribe(PreloadBannerPlace) { payload ->
            if (payload != placeId) {
                return@subscribe
            }
            InAppStoryManager.getInstance()?.preloadBannerPlace(
                BannerPlaceLoadSettings().placeId(placeId),
                object : BannerPlacePreloadCallback(placeId) {
                    override fun bannerPlaceLoaded(
                        size: Int, bannerData: List<BannerData>
                    ) {
                        flutterPluginBinding.runOnMainThread {
                            bannerPlaceCallback.onBannerPlacePreloaded() {}
                        }
                    }

                    override fun loadError() {
                        flutterPluginBinding.runOnMainThread {
                            bannerPlaceCallback.onBannerPlacePreloadedError() {}
                        }
                    }

                    override fun bannerContentLoaded(bannerId: Int, isFirst: Boolean) {

                    }

                    override fun bannerContentLoadError(bannerId: Int, isFirst: Boolean) {
                    }
                })
        }
        showNext = bannerPlaceManagerAdaptor.subscribe(ShowNext) { payload ->
            if (payload != placeId) {
                return@subscribe
            }
            bannerPlace?.showNext()
        }
        showPrevious = bannerPlaceManagerAdaptor.subscribe(ShowPrevious) { payload ->
            if (payload != placeId) {
                return@subscribe
            }
            bannerPlace?.showPrevious()
        }
        showByIndex = bannerPlaceManagerAdaptor.subscribe(ShowByIndex) { payload ->
            if (payload.placeId != placeId) {
                return@subscribe
            }
            bannerPlace?.showByIndex(payload.index.toInt())
        }
        pauseAutoscroll = bannerPlaceManagerAdaptor.subscribe(PauseAutoscroll) { payload ->
            if (payload != placeId) {
                return@subscribe
            }
            bannerPlace?.pauseAutoscroll()
        }
        resumeAutoscroll = bannerPlaceManagerAdaptor.subscribe(ResumeAutoscroll) { payload ->
            if (payload != placeId) {
                return@subscribe
            }
            bannerPlace?.resumeAutoscroll()
        }
        setInteraction = bannerPlaceManagerAdaptor.subscribe(SetInteraction) { payload ->
            if (payload.placeId != placeId) {
                return@subscribe
            }
            updateInteraction(payload.isInteractionEnabled)
        }
        frame.addView(bannerPlace)
        val autoLoad: Boolean = creationParams?.get("autoLoad") as? Boolean? ?: true
        if (autoLoad) {
            loadBannersInternal()
        }
    }

    private fun updateInteraction(isInteractionEnabled: Boolean) {
        flutterPluginBinding.runOnMainThread {
            frame.isEnabled = isInteractionEnabled
            frame.isClickable = isInteractionEnabled
            bannerPlace?.isEnabled = isInteractionEnabled
            bannerPlace?.isClickable = isInteractionEnabled
        }
    }

    override fun setInteraction(isInteractionEnabled: Boolean) {
        updateInteraction(isInteractionEnabled)
    }

    private fun createBannerCarousel(placeId: String) {
        bannerPlace = BannerCarousel(context)

        bannerPlace?.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT
        )

        bannerPlace?.setAppearanceManager(appearanceManager)

        bannerPlace?.navigationCallback(object : BannerCarouselNavigationCallback {
            override fun onPageScrolled(
                position: Int, total: Int, positionOffset: Float, positionOffsetPixels: Int
            ) {
            }

            override fun onPageSelected(
                position: Int, total: Int
            ) {
                flutterPluginBinding.runOnMainThread {
                    bannerPlaceCallback.onBannerScroll(position.toLong()) {}
                }
            }
        })

        val loadHandler = BannerPlaceLoadCallbackHandler(
            placeId = placeId,
            callbackApi = bannerPlaceCallback,
            toDp = { px -> context.toDp(px).toLong() },
            onVisibilityChanged = { visible ->
                frame.visibility = if (visible) View.VISIBLE else View.GONE
            },
            runOnMain = { action -> flutterPluginBinding.runOnMainThread(action) }
        )
        bannerLoadCallbackHandler = loadHandler

        bannerPlace?.loadCallback(loadHandler)
        bannerPlace?.setPlaceId(placeId)
    }

    private fun loadBannersInternal() {
        InAppStoryManager.useCore(object : UseIASCoreCallback() {
            override fun use(core: IASCore) {
                core.sessionManager().useOrOpenSession(object : OpenSessionCallback {
                    override fun onSuccess(sessionParameters: RequestLocalParameters?) {
                        flutterPluginBinding.runOnMainThread {
                            val placeVM = core.widgetViewModels().bannerPlaceViewModels().getContentPlaceViewModel(placeId)
                            val state = placeVM?.currentBannerPlaceState
                            val loadState = state?.loadState()
                            val items = state?.items
                            if (loadState == BannersWidgetLoadStates.LOADED && !items.isNullOrEmpty()) {
                                bannerPlace?.loadBanners(false)
                            } else {
                                bannerPlace?.reloadBanners()
                            }
                        }
                    }

                    override fun onError() {
                        flutterPluginBinding.runOnMainThread {
                            bannerPlace?.reloadBanners()
                        }
                    }
                })
            }

            override fun error() {
                flutterPluginBinding.runOnMainThread {
                    bannerPlace?.reloadBanners()
                }
            }
        })
    }

    private fun decorationToDTO(map: Map<String, Any?>): BannerDecorationDTO {
        val color: Long? = map["color"]?.let { it as Long }
        val image: String? = map["image"]?.let { it as String }
        return BannerDecorationDTO(
            color = color,
            image = image,
        )
    }

    fun Context.toDp(px: Int): Float {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_PX, px.toFloat(), this.resources.displayMetrics
        ) / this.resources.displayMetrics.density
    }

    private fun safelyDisposeBannerPlace(carousel: BannerCarousel?, placeIdToClear: String) {
        val currentUniqueId = carousel?.uniqueId()
        carousel?.setPlaceId(null)
        carousel?.clear()
        if (!currentUniqueId.isNullOrEmpty()) {
            InAppStoryManager.useCore(object : UseIASCoreCallback() {
                override fun use(core: IASCore) {
                    val holder = core.widgetViewModels().bannerPlaceViewModels()
                    val vm = holder.get(currentUniqueId)
                    vm?.clear()
                    vm?.dataIsCleared()
                    vm?.placeId("disposed")
                    holder.changeKey(currentUniqueId, "disposed_" + java.util.UUID.randomUUID().toString())
                }
            })
        }
    }

    override fun changeBannerPlaceId(newPlaceId: String) {
        val oldBannerPlace = bannerPlace
        safelyDisposeBannerPlace(oldBannerPlace, placeId)
        placeId = newPlaceId
        resetLoadState()
        frame.removeView(oldBannerPlace)
        createBannerCarousel(newPlaceId)
        frame.addView(bannerPlace)
        loadBannersInternal()
    }

    override fun deInitBannerPlace() {
        resetLoadState()
        loadBannerPlace.unsubscribe()
        reloadBannerPlace.unsubscribe()
        preloadBannerPlace.unsubscribe()
        showNext.unsubscribe()
        showPrevious.unsubscribe()
        showByIndex.unsubscribe()
        pauseAutoscroll.unsubscribe()
        resumeAutoscroll.unsubscribe()
        setInteraction.unsubscribe()
        frame.removeAllViews()
        safelyDisposeBannerPlace(bannerPlace, placeId)
        bannerPlace = null
        BannerViewHostApi.setUp(
            flutterPluginBinding.binaryMessenger, null, messageChannelSuffix = bannerWidgetId
        )
        bannerDataListener.removeListener(bannersData)
    }
}

class CustomBannerPlaceAppearanceWithoutBannerDecoration(
    private val bannerOffset: Int?,
    private val bannersGap: Int?,
    private val cornerRadius: Int?,
    private val loop: Boolean?,
) : DefaultBannerCarouselAppearance() {
    override fun nextBannerOffset(): Int {
        return bannerOffset ?: super.nextBannerOffset()
    }

    override fun prevBannerOffset(): Int {
        return bannerOffset ?: super.prevBannerOffset()
    }

    override fun bannersGap(): Int {
        return bannersGap ?: super.bannersGap()
    }

    override fun cornerRadius(): Int {
        return cornerRadius ?: super.cornerRadius()
    }

    override fun loop(): Boolean {
        return loop ?: super.loop()
    }
}

class CustomBannerPlaceAppearance(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val flutterAssets: FlutterPlugin.FlutterAssets,
    private val bannerOffset: Int?,
    private val bannersGap: Int?,
    private val cornerRadius: Int?,
    private val loop: Boolean?,
    private val bannerDecoration: BannerDecorationDTO?
) : DefaultBannerCarouselAppearance() {
    override fun nextBannerOffset(): Int {
        return bannerOffset ?: super.nextBannerOffset()
    }

    override fun prevBannerOffset(): Int {
        return bannerOffset ?: super.prevBannerOffset()
    }

    override fun bannersGap(): Int {
        return bannersGap ?: super.bannersGap()
    }

    override fun cornerRadius(): Int {
        return cornerRadius ?: super.cornerRadius()
    }

    override fun loop(): Boolean {
        return loop ?: super.loop()
    }

    override fun loadingPlaceholder(context: Context?): View {
        if (bannerDecoration != null) {
            val placeholderView = FrameLayout(context!!)
            val layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT
            )
            placeholderView.layoutParams = layoutParams
            if (bannerDecoration.color != null) {
                placeholderView.setBackgroundColor(bannerDecoration.color.toInt())
            }

            if (bannerDecoration.image != null) {
                val bitmap = createBitmapFromPath(bannerDecoration.image)
                val imageView = AppCompatImageView(context)
                imageView.layoutParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT
                )
                val params = imageView.layoutParams as FrameLayout.LayoutParams
                params.gravity = Gravity.CENTER
                imageView.layoutParams = params
                imageView.setImageBitmap(bitmap)

                placeholderView.addView(imageView)
            }
            return placeholderView
        } else {
            return super.loadingPlaceholder(context)
        }
    }

    private fun createBitmapFromPath(path: String): Bitmap? {
        try {
            val bitmap: Bitmap?
            val assetPath: String = flutterAssets.getAssetFilePathBySubpath(path)
            val fd: AssetFileDescriptor =
                flutterPluginBinding.getApplicationContext().getAssets().openFd(assetPath)
            val inputStream = fd.createInputStream()
            bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream.close()
            return bitmap
        } catch (_: IOException) {
            return null
        }
    }
}