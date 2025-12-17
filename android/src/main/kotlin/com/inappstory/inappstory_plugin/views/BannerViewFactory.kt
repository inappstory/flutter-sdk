package com.inappstory.inappstory_plugin.views

import BannerPlaceCallbackFlutterApi
import android.content.Context
import com.inappstory.inappstory_plugin.adaptors.IASBannerPlaceManagerAdaptor
import com.inappstory.sdk.AppearanceManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class BannerViewFactory(
    val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val appearanceManager: AppearanceManager
) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    private var bannerPlaceCallback: BannerPlaceCallbackFlutterApi =
        BannerPlaceCallbackFlutterApi(flutterPluginBinding.binaryMessenger)
    private var bannerPlaceManagerAdaptor: IASBannerPlaceManagerAdaptor =
        IASBannerPlaceManagerAdaptor(flutterPluginBinding)

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
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
}