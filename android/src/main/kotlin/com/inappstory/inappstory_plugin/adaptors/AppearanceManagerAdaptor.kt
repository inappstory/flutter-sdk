package com.inappstory.inappstory_plugin.adaptors

import AppearanceManagerHostApi
import CoverQuality
import GoodsItemAppearanceDto
import GoodsItemDataDto
import GoodsItemSelectedCallbackFlutterApi
import Position
import SkusCallbackFlutterApi
import android.content.Context
import android.content.res.AssetFileDescriptor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.util.SizeF
import android.util.TypedValue
import android.view.MotionEvent
import android.view.View
import androidx.core.graphics.drawable.toDrawable
import androidx.core.graphics.toColorInt
import androidx.recyclerview.widget.RecyclerView
import com.inappstory.inappstory_plugin.helpers.IASCustomIcon
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.CustomCloseIconInterface
import com.inappstory.sdk.CustomDislikeIconInterface
import com.inappstory.sdk.CustomFavoriteIconInterface
import com.inappstory.sdk.CustomLikeIconInterface
import com.inappstory.sdk.CustomRefreshIconInterface
import com.inappstory.sdk.CustomShareIconInterface
import com.inappstory.sdk.CustomSoundIconInterface
import com.inappstory.sdk.ICustomIconState
import com.inappstory.sdk.core.network.content.models.Image.QUALITY_HIGH
import com.inappstory.sdk.core.network.content.models.Image.QUALITY_MEDIUM
import com.inappstory.sdk.stories.ui.reader.StoriesGradientObject
import com.inappstory.sdk.stories.ui.views.goodswidget.GetGoodsDataCallback
import com.inappstory.sdk.stories.ui.views.goodswidget.GoodsItemData
import com.inappstory.sdk.stories.ui.views.goodswidget.GoodsWidgetAppearanceAdapter
import com.inappstory.sdk.stories.ui.views.goodswidget.ICustomGoodsItem
import com.inappstory.sdk.stories.ui.views.goodswidget.ICustomGoodsWidget
import com.inappstory.sdk.stories.ui.views.goodswidget.IGoodsWidgetAppearance
import com.inappstory.sdk.stories.ui.views.goodswidget.SimpleCustomGoodsItem
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.io.IOException

class AppearanceManagerAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val appearanceManager: AppearanceManager,
    private val activityHolder: ActivityHolder,
) : AppearanceManagerHostApi {
    init {
        AppearanceManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    private val skusCallback = SkusCallbackFlutterApi(flutterPluginBinding.binaryMessenger)
    private val goodsItemSelectedCallback =
        GoodsItemSelectedCallbackFlutterApi(flutterPluginBinding.binaryMessenger)


    private var likeIcon: Bitmap? = null
    private var selectedLikeIcon: Bitmap? = null
    private var customLikeIconInterface: CustomLikeIconInterface? = null

    private var dislikeIcon: Bitmap? = null
    private var selectedDislikeIcon: Bitmap? = null
    private var customDislikeIconInterface: CustomDislikeIconInterface? = null

    private var favoriteIcon: Bitmap? = null
    private var selectedFavoriteIcon: Bitmap? = null
    private var customFavoriteIconInterface: CustomFavoriteIconInterface? = null

    private var shareIcon: Bitmap? = null
    private var selectedShareIcon: Bitmap? = null
    private var customShareIconInterface: CustomShareIconInterface? = null

    private var soundIcon: Bitmap? = null
    private var selectedSoundIcon: Bitmap? = null
    private var customSoundIconInterface: CustomSoundIconInterface? = null

    private var closeIcon: Bitmap? = null
    private var customCloseIconInterface: CustomCloseIconInterface? = null

    private var refreshIcon: Bitmap? = null
    private var customRefreshIconInterface: CustomRefreshIconInterface? = null

    private fun setupIcons() {
        appearanceManager.csCustomIcons(
            customFavoriteIconInterface,
            customLikeIconInterface,
            customDislikeIconInterface,
            customShareIconInterface,
            customSoundIconInterface,
            customCloseIconInterface,
            customRefreshIconInterface
        )
    }

    override fun setCoverQuality(coverQuality: CoverQuality) {
        when (coverQuality) {
            CoverQuality.MEDIUM -> appearanceManager.csCoverQuality(QUALITY_MEDIUM)
            CoverQuality.HIGH -> appearanceManager.csCoverQuality(QUALITY_HIGH)
        }
    }

    override fun setHasLike(value: Boolean) {
        appearanceManager.csHasLike(value)
    }

    override fun setHasFavorites(value: Boolean) {
        appearanceManager.csHasFavorite(value)
    }

    override fun setHasShare(value: Boolean) {
        appearanceManager.csHasShare(value)
    }

    override fun setClosePosition(position: Position) {
        appearanceManager.csClosePosition(position.raw + 1)
    }

    override fun setTimerGradientEnable(isEnabled: Boolean) {
        appearanceManager.csTimerGradientEnable(isEnabled)
    }

    override fun getTimerGradientEnable(): Boolean {
        return appearanceManager.csTimerGradientEnable()
    }

    override fun setTimerGradient(colors: List<Long>, locations: List<Double>) {
        val gradient = StoriesGradientObject()
        gradient.csColors(colors.map { it.toInt() })
        if (locations.size == colors.size) {
            gradient.csLocations(locations.map { it.toFloat() })
        }
        appearanceManager.csTimerGradient(gradient)
    }

    override fun setReaderBackgroundColor(color: Long) {
        appearanceManager.csReaderBackgroundColor(color.toInt())
    }

    override fun setReaderCornerRadius(radius: Long) {
        appearanceManager.csReaderRadius(radius.toInt())
    }

    override fun setLikeIcon(iconPath: String, selectedIconPath: String) {
        if (iconPath.isNotEmpty() && selectedIconPath.isNotEmpty()) {
            likeIcon = createBitmapFromPath(iconPath)
            selectedLikeIcon = createBitmapFromPath(selectedIconPath)
            if (likeIcon != null && selectedLikeIcon != null) {
                customLikeIconInterface = object : CustomLikeIconInterface() {
                    override fun createIconView(context: Context, maxSizeInPx: SizeF): View {
                        val customButton = IASCustomIcon(context)
                        customButton.setIconBitmap(likeIcon!!)
                        return customButton
                    }

                    override fun updateState(iconView: View, iconState: ICustomIconState) {
                        if (iconView is IASCustomIcon) {
                            val customButton: IASCustomIcon = iconView
                            if (iconState.active()) {
                                customButton.setIconBitmap(selectedLikeIcon!!)
                            } else {
                                customButton.setIconBitmap(likeIcon!!)
                            }
                            customButton.updateState(
                                iconState.active(), iconState.enabled()
                            )
                        }
                    }

                    override fun touchEvent(iconView: View, event: MotionEvent) {
                        super.touchEvent(iconView, event)
                    }
                }
            }
        }
        setupIcons()
    }

    override fun setDislikeIcon(iconPath: String, selectedIconPath: String) {
        if (iconPath.isNotEmpty() && selectedIconPath.isNotEmpty()) {
            dislikeIcon = createBitmapFromPath(iconPath)
            selectedDislikeIcon = createBitmapFromPath(selectedIconPath)
            if (dislikeIcon != null && selectedDislikeIcon != null) {
                customDislikeIconInterface = object : CustomDislikeIconInterface() {
                    override fun createIconView(context: Context, maxSizeInPx: SizeF): View {
                        val customButton = IASCustomIcon(context)
                        customButton.setIconBitmap(dislikeIcon!!)
                        return customButton
                    }

                    override fun updateState(iconView: View, iconState: ICustomIconState) {
                        if (iconView is IASCustomIcon) {
                            val customButton: IASCustomIcon = iconView
                            if (iconState.active()) {
                                customButton.setIconBitmap(selectedDislikeIcon!!)
                            } else {
                                customButton.setIconBitmap(dislikeIcon!!)
                            }
                            customButton.updateState(iconState.active(), iconState.enabled())
                        }
                    }

                    override fun touchEvent(iconView: View, event: MotionEvent) {
                        super.touchEvent(iconView, event)
                    }
                }
            }
        }
        setupIcons()
    }

    override fun setFavoriteIcon(iconPath: String, selectedIconPath: String) {
        if (iconPath.isNotEmpty() && selectedIconPath.isNotEmpty()) {
            favoriteIcon = createBitmapFromPath(iconPath)
            selectedFavoriteIcon = createBitmapFromPath(selectedIconPath)
            if (favoriteIcon != null && selectedFavoriteIcon != null) {
                customFavoriteIconInterface = object : CustomFavoriteIconInterface() {
                    override fun createIconView(context: Context, maxSizeInPx: SizeF): View {
                        val customButton = IASCustomIcon(context)
                        customButton.setIconBitmap(favoriteIcon!!)
                        return customButton
                    }

                    override fun updateState(iconView: View, iconState: ICustomIconState) {
                        if (iconView is IASCustomIcon) {
                            val customButton: IASCustomIcon = iconView
                            if (iconState.active()) {
                                customButton.setIconBitmap(selectedFavoriteIcon!!)
                            } else {
                                customButton.setIconBitmap(favoriteIcon!!)
                            }
                            customButton.updateState(iconState.active(), iconState.enabled())
                        }
                    }

                    override fun touchEvent(iconView: View, event: MotionEvent) {
                        super.touchEvent(iconView, event)
                    }
                }
            }
        }
        setupIcons()
    }

    override fun setShareIcon(iconPath: String, selectedIconPath: String) {
        if (iconPath.isNotEmpty() && selectedIconPath.isNotEmpty()) {
            shareIcon = createBitmapFromPath(iconPath)
            selectedShareIcon = createBitmapFromPath(selectedIconPath)
            if (shareIcon != null && selectedShareIcon != null) {
                customShareIconInterface = object : CustomShareIconInterface() {
                    override fun createIconView(context: Context, maxSizeInPx: SizeF): View {
                        val customButton = IASCustomIcon(context)
                        customButton.setIconBitmap(shareIcon!!)
                        return customButton
                    }

                    override fun updateState(iconView: View, iconState: ICustomIconState) {
                        if (iconView is IASCustomIcon) {
                            val customButton: IASCustomIcon = iconView
                            if (iconState.active()) {
                                customButton.setIconBitmap(selectedShareIcon!!)
                            } else {
                                customButton.setIconBitmap(shareIcon!!)
                            }
                            customButton.updateState(iconState.active(), iconState.enabled())
                        }
                    }

                    override fun touchEvent(iconView: View, event: MotionEvent) {
                        super.touchEvent(iconView, event)
                    }
                }
            }
        }
        setupIcons()
    }

    override fun setCloseIcon(iconPath: String) {
        if (iconPath.isNotEmpty()) {
            closeIcon = createBitmapFromPath(iconPath)
            if (closeIcon != null) {
                customCloseIconInterface = object : CustomCloseIconInterface() {
                    override fun createIconView(context: Context, maxSizeInPx: SizeF): View {
                        val customButton = IASCustomIcon(context)
                        customButton.setIconBitmap(closeIcon!!)
                        return customButton
                    }

                    override fun updateState(iconView: View, iconState: ICustomIconState) {
                        if (iconView is IASCustomIcon) {
                            val customButton: IASCustomIcon = iconView
                            customButton.updateState(iconState.active(), iconState.enabled())
                        }
                    }

                    override fun touchEvent(iconView: View, event: MotionEvent) {
                        super.touchEvent(iconView, event)
                    }
                }
            }
        }
        setupIcons()
    }

    override fun setSoundIcon(iconPath: String, selectedIconPath: String) {
        if (iconPath.isNotEmpty() && selectedIconPath.isNotEmpty()) {
            soundIcon = createBitmapFromPath(iconPath)
            selectedSoundIcon = createBitmapFromPath(selectedIconPath)
            if (soundIcon != null && selectedSoundIcon != null) {
                customSoundIconInterface = object : CustomSoundIconInterface() {
                    override fun createIconView(context: Context, maxSizeInPx: SizeF): View {
                        val customButton = IASCustomIcon(context)
                        customButton.setIconBitmap(soundIcon!!)
                        return customButton
                    }

                    override fun updateState(iconView: View, iconState: ICustomIconState) {
                        if (iconView is IASCustomIcon) {
                            val customButton: IASCustomIcon = iconView
                            if (iconState.active()) {
                                customButton.setIconBitmap(selectedSoundIcon!!)
                            } else {
                                customButton.setIconBitmap(soundIcon!!)
                            }
                            customButton.updateState(iconState.active(), iconState.enabled())
                        }
                    }

                    override fun touchEvent(iconView: View, event: MotionEvent) {
                        super.touchEvent(iconView, event)
                    }
                }
            }
        }
        setupIcons()
    }

    override fun setRefreshIcon(iconPath: String) {
        if (iconPath.isNotEmpty()) {
            refreshIcon = createBitmapFromPath(iconPath)
            if (refreshIcon != null) {
                customRefreshIconInterface = object : CustomRefreshIconInterface() {
                    override fun createIconView(context: Context, maxSizeInPx: SizeF): View {
                        val customButton = IASCustomIcon(context)
                        customButton.setIconBitmap(refreshIcon!!)
                        return customButton
                    }

                    override fun updateState(iconView: View, iconState: ICustomIconState) {
                        if (iconView is IASCustomIcon) {
                            val customButton: IASCustomIcon = iconView
                            customButton.updateState(iconState.active(), iconState.enabled())
                        }
                    }

                    override fun touchEvent(iconView: View, event: MotionEvent) {
                        super.touchEvent(iconView, event)
                    }
                }
            }
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

    override fun setUpGoods(appearance: GoodsItemAppearanceDto) {
        AppearanceManager.getCommonInstance().csCustomGoodsWidget(object : ICustomGoodsWidget {
            override fun getWidgetView(contex: Context?): View? {
                return null
            }

            override fun getItem(): ICustomGoodsItem? {
                var itemBackgroundColor: Int = Color.TRANSPARENT
                var itemCornerRadius: Int = dpToPx(8F)
                var itemMainTextColor: Int = Color.BLACK
                var itemOldPriceTextColor: Int = "#CCCCCC".toColorInt()
                var itemTitleTextSize: Int = spToPixels(14F)
                var itemDescriptionTextSize: Int = spToPixels(12F)
                var itemPriceTextSize: Int = spToPixels(14F)
                var itemOldPriceTextSize: Int = spToPixels(14F)
                if (appearance.itemBackgroundColor != null) {
                    itemBackgroundColor = appearance.itemBackgroundColor.toInt()
                }
                if (appearance.itemCornerRadius != null) {
                    itemCornerRadius = dpToPx(appearance.itemCornerRadius.toFloat())
                }
                if (appearance.itemMainTextColor != null) {
                    itemMainTextColor = appearance.itemMainTextColor.toInt()
                }
                if (appearance.itemOldPriceTextColor != null) {
                    itemOldPriceTextColor = appearance.itemOldPriceTextColor.toInt()
                }
                if (appearance.itemTitleTextSize != null) {
                    itemTitleTextSize = spToPixels(appearance.itemTitleTextSize.toFloat())
                }
                if (appearance.itemDescriptionTextSize != null) {
                    itemDescriptionTextSize = appearance.itemDescriptionTextSize.toInt()
                }
                if (appearance.itemPriceTextSize != null) {
                    itemPriceTextSize = spToPixels(appearance.itemPriceTextSize.toFloat())
                }
                if (appearance.itemOldPriceTextSize != null) {
                    itemOldPriceTextSize = spToPixels(appearance.itemOldPriceTextSize.toFloat())
                }
                return SimpleCustomGoodsItem().csGoodsCellImageBackgroundColor(itemBackgroundColor)
                    .csGoodsCellImageCornerRadius(itemCornerRadius)
                    .csGoodsCellMainTextColor(itemMainTextColor)
                    .csGoodsCellOldPriceTextColor(itemOldPriceTextColor)
                    .csGoodsCellTitleSize(itemTitleTextSize)
                    .csGoodsCellDescriptionSize(itemDescriptionTextSize)
                    .csGoodsCellPriceSize(itemPriceTextSize)
                    .csGoodsCellOldPriceSize(itemOldPriceTextSize)
            }

            override fun getWidgetAppearance(): IGoodsWidgetAppearance? {
                return getGoodsWidgetAppearance(appearance)
            }

            override fun getDecoration(): RecyclerView.ItemDecoration? {
                return null
            }

            override fun getSkus(
                widgetView: View?, skus: ArrayList<String>, callback: GetGoodsDataCallback
            ) {
                flutterPluginBinding.runOnMainThread {
                    skusCallback.getSkus(skus) { goodsItemDataDtoResult ->
                        if (goodsItemDataDtoResult.isFailure) {
                            callback.onError()
                            return@getSkus
                        }
                        val goods = goodsItemDataDtoResult.getOrNull()
                        if (goods != null) {
                            val goodsItemData = arrayListOf<GoodsItemData>()
                            skus.forEach { sku ->
                                val item = goods.first { it.sku == sku }
                                val data = GoodsItemData(
                                    sku,
                                    item.title,
                                    item.description,
                                    item.image,
                                    item.price,
                                    item.oldPrice,
                                    item
                                )
                                goodsItemData.add(data)
                            }
                            callback.onSuccess(goodsItemData)
                        } else {
                            callback.onError()
                        }
                    }
                }
            }

            override fun onItemClick(
                widgetView: View?,
                goodsItemView: View,
                goodsItemData: GoodsItemData,
                callback: GetGoodsDataCallback
            ) {
                val goodsItemDataDto = GoodsItemDataDto(
                    sku = goodsItemData.sku,
                    title = goodsItemData.title,
                    description = goodsItemData.description,
                    image = goodsItemData.image,
                    price = goodsItemData.price,
                    oldPrice = goodsItemData.oldPrice
                )
                flutterPluginBinding.runOnMainThread {
                    goodsItemSelectedCallback.goodsItemSelected(goodsItemDataDto) {}
                }
            }
        })
    }

    fun getGoodsWidgetAppearance(appearance: GoodsItemAppearanceDto): IGoodsWidgetAppearance {
        return object : GoodsWidgetAppearanceAdapter() {
            override fun getBackgroundColor(): Int {
                if (appearance.widgetBackgroundColor != null) {
                    return appearance.widgetBackgroundColor.toInt()
                }
                return super.getBackgroundColor()
            }

            override fun getBackgroundHeight(): Int {
                if (appearance.widgetBackgroundHeight != null) {
                    return appearance.widgetBackgroundHeight.toInt()
                }
                return super.getBackgroundHeight()
            }

            override fun getCloseButtonImage(): Drawable {
                if (appearance.closeButtonImage != null) {
                    val bitmap = createBitmapFromPath(appearance.closeButtonImage)
                    val bitmapDrawable = bitmap?.toDrawable(
                        flutterPluginBinding.getApplicationContext().getResources()
                    )
                    if (bitmapDrawable != null) {
                        return bitmapDrawable
                    }

                }
                return super.getCloseButtonImage()
            }

            override fun getCloseButtonColor(): Int {
                if (appearance.closeButtonColor != null) {
                    return appearance.closeButtonColor.toInt()
                }
                return super.getCloseButtonColor()
            }
        }
    }

    private fun dpToPx(dp: Float): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            dp,
            activityHolder.activity?.applicationContext?.resources?.displayMetrics
        ).toInt()
    }

    private fun spToPixels(sp: Float): Int {
        return TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_SP,
            sp,
            activityHolder.activity?.applicationContext?.resources?.displayMetrics
        ).toInt()
    }
}
