package com.inappstory.inappstory_plugin.adaptors

import CheckoutCallbackFlutterApi
import CheckoutManagerCallbackFlutterApi
import InAppStoryManagerHostApi
import com.inappstory.inappstory_plugin.helpers.CustomOpenStoriesReader
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.core.data.models.InAppStoryUserSettings
import com.inappstory.sdk.externalapi.InAppStoryAPI
import com.inappstory.sdk.goods.outercallbacks.ProductCart
import com.inappstory.sdk.goods.outercallbacks.ProductCartInteractionCallback
import com.inappstory.sdk.goods.outercallbacks.ProductCartOffer
import com.inappstory.sdk.goods.outercallbacks.ProductCartUpdatedProcessCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import java.util.Locale
import ProductCart as ProductCartFlutter
import ProductCartOffer as ProductCartOfferFlutter

class IASManagerAdaptor(
    private val flutterPluginBinding: FlutterPluginBinding,
    private val inAppStoryAPI: InAppStoryAPI,
    private val inAppStoryManager: InAppStoryManager,
) : InAppStoryManagerHostApi {
    private val checkoutManagerCallbackFlutterApi: CheckoutManagerCallbackFlutterApi
    private val checkoutCallbackFlutterApi: CheckoutCallbackFlutterApi

    init {
        InAppStoryManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
        checkoutManagerCallbackFlutterApi =
            CheckoutManagerCallbackFlutterApi(flutterPluginBinding.binaryMessenger)
        checkoutCallbackFlutterApi =
            CheckoutCallbackFlutterApi(flutterPluginBinding.binaryMessenger)
        initProductsCallback()
    }

    override fun setPlaceholders(newPlaceholders: Map<String, String>) {
        inAppStoryManager.placeholders = newPlaceholders
    }

    override fun setTags(tags: List<String>) {
        val arrayList = ArrayList<String>()
        arrayList.addAll(tags)
        inAppStoryManager.tags = arrayList
    }

    override fun changeUser(userId: String, userSign: String?, callback: (Result<Unit>) -> Unit) {
        inAppStoryManager.setUserId(userId, userSign)
        callback(Result.success(Unit))
    }

    override fun userLogout() {
        inAppStoryManager.userLogout()
    }

    override fun closeReaders(callback: (Result<Unit>) -> Unit) {
        InAppStoryManager.closeStoryReader(
            true
        ) {
            callback.invoke(Result.success(Unit))
        }
    }

    override fun clearCache() {
        inAppStoryAPI.clearCache()
    }

    override fun setTransparentStatusBar() {
        inAppStoryManager.setOpenStoriesReader(CustomOpenStoriesReader())
    }

    override fun changeSound(value: Boolean) {
        inAppStoryManager.soundOn(value)
    }

    override fun setUserSettings(
        anonymous: Boolean?,
        userId: String?,
        userSign: String?,
        newLanguageCode: String?,
        newLanguageRegion: String?,
        newTags: List<String>?,
        newPlaceholders: Map<String, String>?
    ) {
        var newLocale: Locale? = null;
        if (!newLanguageCode.isNullOrEmpty() && !newLanguageRegion.isNullOrEmpty()) {
            newLocale = Locale(newLanguageCode, newLanguageRegion)
        }
        var settings = InAppStoryUserSettings()
        if (anonymous != null) {
            settings = settings.anonymous(anonymous)
        }
        inAppStoryManager.userSettings(
            settings.userId(userId, userSign).lang(newLocale).tags(newTags)
                .placeholders(newPlaceholders)
        )
    }

    override fun setLang(languageCode: String, languageRegion: String) {
        val locale = Locale(languageCode, languageRegion)
        inAppStoryManager.setLang(locale)
    }

    override fun setOptionKeys(options: Map<String, String>) {
        inAppStoryManager.setOptions(options)
    }

    private fun initProductsCallback() {
        InAppStoryManager.getInstance()
            .setProductCartInteractionCallback(object : ProductCartInteractionCallback {
                override fun cartUpdate(
                    offer: ProductCartOffer?,
                    callback: ProductCartUpdatedProcessCallback?
                ) {
                    offer?.let {
                        flutterPluginBinding.runOnMainThread {
                            checkoutManagerCallbackFlutterApi.onProductCartUpdate(
                                ProductCartOfferFlutter(
                                    offerId = offer.offerId,
                                    groupId = offer.groupId,
                                    name = offer.name,
                                    description = offer.description,
                                    url = offer.url,
                                    coverUrl = offer.coverUrl,
                                    imageUrls = offer.imageUrls,
                                    currency = offer.currency,
                                    price = offer.price,
                                    oldPrice = offer.oldPrice,
                                    adult = offer.adult,
                                    availability = offer.availability.toLong(),
                                    size = offer.size,
                                    color = offer.color,
                                    quantity = offer.quantity.toLong()
                                )
                            ) { result: Result<ProductCartFlutter> ->
                                if (result.isSuccess) {
                                    val resultFlutter: ProductCartFlutter? = result.getOrNull()
                                    if (resultFlutter != null) {
                                        val productCart = ProductCart()
                                        productCart.price = resultFlutter.price
                                        productCart.oldPrice = resultFlutter.oldPrice
                                        productCart.offers =
                                            resultFlutter.offers.map { productCartOffer: ProductCartOfferFlutter ->
                                                return@map productCartOfferFromDTO(productCartOffer)
                                            }
                                        productCart.priceCurrency = resultFlutter.priceCurrency
                                        callback?.onSuccess(productCart)
                                    } else {
                                        callback?.onError("Product cart is empty or null")
                                    }
                                } else {
                                    callback?.onError("Product cart is empty or null")
                                }
                            }
                        }
                    }
                }

                override fun cartClicked() {
                    flutterPluginBinding.runOnMainThread {
                        checkoutCallbackFlutterApi.onProductCartClicked { }
                    }
                }

                override fun cartGetState(callback: ProductCartUpdatedProcessCallback?) {
                    flutterPluginBinding.runOnMainThread {
                        checkoutManagerCallbackFlutterApi.getProductCartState { productCartResult: Result<ProductCartFlutter> ->
                            if (productCartResult.isSuccess) {
                                val productCartFlutter: ProductCartFlutter? =
                                    productCartResult.getOrNull()
                                if (productCartFlutter != null) {
                                    callback?.onSuccess(productCartFromDTO(productCartFlutter))
                                } else {
                                    callback?.onError("Product cart is empty or null")

                                }
                            } else {
                                callback?.onError("Product cart is empty or null")
                            }
                        }
                    }
                }
            })
    }

    fun productCartOfferFromDTO(offerFlutter: ProductCartOfferFlutter): ProductCartOffer {
        val result = ProductCartOffer()
        result.offerId = offerFlutter.offerId
        result.groupId = offerFlutter.groupId
        result.name = offerFlutter.name
        result.description = offerFlutter.description
        result.url = offerFlutter.url
        result.coverUrl = offerFlutter.coverUrl
        result.imageUrls = offerFlutter.imageUrls
        result.currency = offerFlutter.currency
        result.price = offerFlutter.price
        result.oldPrice = offerFlutter.oldPrice
        result.adult = offerFlutter.adult
        result.availability = offerFlutter.availability.toInt()
        result.size = offerFlutter.size
        result.color = offerFlutter.color
        result.quantity = offerFlutter.quantity.toInt()
        return result
    }

    fun productCartFromDTO(cartFlutter: ProductCartFlutter): ProductCart {
        val productCart = ProductCart()
        productCart.price = cartFlutter.price
        productCart.oldPrice = cartFlutter.oldPrice
        productCart.offers =
            cartFlutter.offers.map { productCartOffer: ProductCartOfferFlutter ->
                return@map productCartOfferFromDTO(productCartOffer)
            }
        productCart.priceCurrency = cartFlutter.priceCurrency

        return productCart
    }

}