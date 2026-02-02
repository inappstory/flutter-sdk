package com.inappstory.inappstory_plugin.views

import BannerPlaceCallbackFlutterApi
import android.content.Context
import com.inappstory.inappstory_plugin.adaptors.IASBannerPlaceManagerAdaptor
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.banners.BannerData
import com.inappstory.sdk.banners.BannerWidgetCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import BannerData as BannerDataDto

class BannerViewFactory(
    val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private var inAppStoryManager: InAppStoryManager,
    private var appearanceManager: AppearanceManager
) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    private var bannerPlaceCallback: BannerPlaceCallbackFlutterApi =
        BannerPlaceCallbackFlutterApi(flutterPluginBinding.binaryMessenger)
    private var bannerPlaceManagerAdaptor: IASBannerPlaceManagerAdaptor =
        IASBannerPlaceManagerAdaptor(flutterPluginBinding)

    private var bannersCallback: BannerWidgetCallback? = null

    fun setInAppStoryManager(manager: InAppStoryManager) {
        this.inAppStoryManager = manager
    }

    fun setAppearanceManager(manager: AppearanceManager) {
        this.appearanceManager = manager
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        if (bannersCallback == null) {
            createBannersCallback()
        }
        val creationParams = args as Map<String?, Any>?
        return BannerView(
            context,
            viewId,
            creationParams,
            flutterPluginBinding,
            appearanceManager,
            bannerPlaceManagerAdaptor,
            bannerPlaceCallback,
        )
    }

    private fun createBannersCallback() {
        bannersCallback = BannerWidgetCallback { bannerData, widgetEventName, widgetData ->
            if (bannerData != null && widgetEventName != null && widgetData != null && widgetData.keys.any { s: String? -> s != null }) {
                flutterPluginBinding.runOnMainThread {
                    bannerPlaceCallback.onActionWith(
                        bannerDataToDto(bannerData),
                        widgetEventName,
                        widgetData.map { (k, v) -> k as String to v }.toMap()
                    ) {}
                }
            }
        }
        inAppStoryManager.setBannerWidgetCallback(bannersCallback)
    }

    private fun bannerDataToDto(data: BannerData): BannerDataDto {
        return BannerDataDto(
            id = data.id().toString(),
            bannerPlace = data.bannerPlace(),
            payload = data.payload()
        )
    }
}