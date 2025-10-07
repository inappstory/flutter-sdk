package com.inappstory.inappstory_plugin.views

import BannerDecorationDTO
import BannerPlaceCallbackFlutterApi
import BannerPlaceManagerHostApi
import GradientType
import android.content.Context
import android.content.res.AssetFileDescriptor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import androidx.appcompat.widget.AppCompatImageView
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.banners.BannerPlaceLoadCallback
import com.inappstory.sdk.banners.BannerPlaceLoadSettings
import com.inappstory.sdk.banners.BannerPlaceNavigationCallback
import com.inappstory.sdk.banners.BannerPlacePreloadCallback
import com.inappstory.sdk.banners.BannerWidgetCallback
import com.inappstory.sdk.banners.ui.place.BannerPlace
import com.inappstory.sdk.banners.ui.place.DefaultBannerPlaceAppearance
import com.inappstory.sdk.stories.outercallbacks.common.reader.BannerData
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.platform.PlatformView
import java.io.IOException

internal class BannerView(
    context: Context,
    id: Int,
    creationParams: Map<String?, Any?>?,
    val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    appearanceManager: AppearanceManager
) : PlatformView, BannerPlaceManagerHostApi {

    private val bannerPlace: BannerPlace

    private var bannerPlaceCallback: BannerPlaceCallbackFlutterApi

    override fun getView(): View {
        return bannerPlace
    }

    override fun dispose() {
        BannerPlaceManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, null)
    }

    init {
        BannerPlaceManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
        bannerPlaceCallback = BannerPlaceCallbackFlutterApi(flutterPluginBinding.binaryMessenger)

        val loop: Boolean? = creationParams?.get("loop") as? Boolean?
        val bannerOffset: Int? = creationParams?.get("bannerOffset") as? Int?
        val bannersGap: Int? = creationParams?.get("bannersGap") as? Int?
        val cornerRadius: Int? = creationParams?.get("cornerRadius") as? Int?


        var decoration: BannerDecorationDTO? = null
        if (creationParams?.get("bannerDecoration") != null) {
            decoration = decorationToDTO(
                creationParams["bannerDecoration"] as Map<String, Any?>
            )
        }

        val bannerAppearance = CustomBannerPlaceAppearance(
            flutterPluginBinding,
            bannerOffset,
            bannersGap,
            cornerRadius,
            loop,
            decoration,
        )
        appearanceManager.csBannerPlaceInterface(bannerAppearance)
        AppearanceManager().csBannerPlaceInterface(bannerAppearance)

        bannerPlace = BannerPlace(context)
        val placeId: String = creationParams?.get("placeId") as String? ?: "customBannerPlace";
        bannerPlace.setPlaceId(placeId)
        bannerPlace.navigationCallback(object : BannerPlaceNavigationCallback {
            override fun onPageScrolled(
                position: Int,
                total: Int,
                positionOffset: Float,
                positionOffsetPixels: Int
            ) {
            }

            override fun onPageSelected(
                position: Int,
                total: Int
            ) {
                flutterPluginBinding.runOnMainThread {
                    bannerPlaceCallback.onBannerScroll(position.toLong()) {}
                }
            }
        })

        bannerPlace.setAppearanceManager(appearanceManager)

        bannerPlace.loadCallback(object : BannerPlaceLoadCallback() {
            override fun bannerPlaceLoaded(
                size: Int, bannerData: List<BannerData>, widgetHeight: Int
            ) {
                flutterPluginBinding.runOnMainThread {
                    bannerPlaceCallback.onBannerPlaceLoaded(
                        size.toLong(),
                        context.toDp(widgetHeight).toLong()
                    ) {}
                }
            }

            override fun loadError() {
            }

            override fun bannerLoaded(p0: Int, p1: Boolean) {
            }

            override fun bannerLoadError(p0: Int, p1: Boolean) {
            }
        })

        InAppStoryManager.getInstance().setBannerWidgetCallback(object : BannerWidgetCallback {
            override fun bannerWidget(
                bannerData: BannerData?,
                widgetEventName: String?,
                widgetData: Map<String?, String?>?
            ) {
                if (widgetData != null) {
                    flutterPluginBinding.runOnMainThread {
                        widgetData["widget_value"]?.let {
                            bannerPlaceCallback.onActionWith(widgetData["widget_value"]!!) {}
                        }
                    }
                }
            }
        })
    }

    override fun loadBannerPlace(placeId: String, tags: List<String>?) {
        InAppStoryManager.getInstance()?.loadBannerPlace(
            BannerPlaceLoadSettings().placeId(placeId).tags(tags)
        )
    }

    override fun preloadBannerPlace(placeId: String, tags: List<String>?) {
        InAppStoryManager.getInstance()?.preloadBannerPlace(
            BannerPlaceLoadSettings()
                .placeId(placeId)
                .tags(tags),
            object : BannerPlacePreloadCallback(placeId) {
                override fun bannerPlaceLoaded(size: Int, bannerData: List<BannerData>) {
                    bannerPlaceCallback.onBannerPlacePreloaded(size.toLong()) {}
                }

                override fun loadError() {
                }

                override fun bannerContentLoaded(bannerId: Int, isFirst: Boolean) {

                }

                override fun bannerContentLoadError(bannerId: Int, isFirst: Boolean) {
                }
            }
        )
    }

    override fun showNext() {
        bannerPlace.showNext()
    }

    override fun showPrevious() {
        bannerPlace.showPrevious()
    }

    override fun showByIndex(index: Long) {
        bannerPlace.showByIndex(index.toInt())
    }

    override fun pauseAutoscroll() {
        bannerPlace.pauseAutoscroll()
    }

    override fun resumeAutoscroll() {
        bannerPlace.resumeAutoscroll()
    }

    private fun decorationToDTO(map: Map<String, Any?>): BannerDecorationDTO {
        val gradientType: GradientType? = map["gradientType"]?.let { GradientType.ofRaw(it as Int) }
        val color: Long? = map["color"]?.let { it as Long }
        val image: String? = map["image"]?.let { it as String }
        val stops: List<Double>? = map["gradientStops"]?.let { it as List<Double>? }
        val colors: List<Long>? = map["gradientColors"]?.let { it as List<Long>? }
        return BannerDecorationDTO(
            color = color,
            gradientType = gradientType,
            gradientStops = stops,
            image = image,
            gradientColors = colors,
        )
    }

    fun Context.toDp(px: Int): Float {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_PX,
            px.toFloat(),
            this.resources.displayMetrics
        ) / this.resources.displayMetrics.density
    }
}

class CustomBannerPlaceAppearance(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val bannerOffset: Int?,
    private val bannersGap: Int?,
    private val cornerRadius: Int?,
    private val loop: Boolean?,
    private val bannerDecoration: BannerDecorationDTO?
) : DefaultBannerPlaceAppearance() {
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

            if (bannerDecoration.color != null) {
                placeholderView.setBackgroundColor(bannerDecoration.color.toInt())
            } else if (bannerDecoration.gradientType != null) {
                val colors =
                    bannerDecoration.gradientColors?.map { it.toInt() }?.toIntArray() ?: intArrayOf(
                        Color.WHITE, Color.BLACK
                    )

                when (bannerDecoration.gradientType) {
                    GradientType.LINEAR -> {
                        val gradientDrawable = GradientDrawable(
                            GradientDrawable.Orientation.TOP_BOTTOM, // Orientation of the gradient
                            colors
                        )
                        placeholderView.background = gradientDrawable
                    }

                    GradientType.RADIAL -> {
                        val gradientDrawable = GradientDrawable(
                            GradientDrawable.Orientation.TOP_BOTTOM, // Orientation of the gradient
                            colors
                        )
                        gradientDrawable.gradientType = GradientDrawable.RADIAL_GRADIENT
                        placeholderView.background = gradientDrawable

                    }

                    GradientType.SWEEP -> {
                        val gradientDrawable = GradientDrawable(
                            GradientDrawable.Orientation.TOP_BOTTOM, // Orientation of the gradient
                            colors
                        )
                        gradientDrawable.gradientType = GradientDrawable.SWEEP_GRADIENT
                        placeholderView.background = gradientDrawable
                    }
                }
            }

            val layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT
            )
            placeholderView.layoutParams = layoutParams
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
            val assetPath: String =
                flutterPluginBinding.getFlutterAssets().getAssetFilePathBySubpath(path)
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