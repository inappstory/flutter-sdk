package com.inappstorysdk

//import com.facebook.react.bridge.NativeModule
//import com.facebook.react.bridge.ReactApplicationContext
//import com.facebook.react.bridge.ReactContext
//import com.facebook.react.bridge.ReactContextBaseJavaModule
//import com.facebook.react.bridge.ReactMethod


//import com.facebook.react.bridge.Arguments
//import com.facebook.react.bridge.Promise
//import com.facebook.react.bridge.ReadableArray
//import com.facebook.react.bridge.ReadableMap
//import com.facebook.react.bridge.ReadableNativeMap
//import com.facebook.react.bridge.WritableMap
//import com.facebook.react.bridge.WritableNativeMap
import android.content.Context
import android.content.ContextWrapper
import android.os.Handler
import android.util.Log
import android.view.View
import androidx.recyclerview.widget.RecyclerView
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.InAppStoryManager
import com.inappstory.sdk.externalapi.InAppStoryAPI
import com.inappstory.sdk.externalapi.StoryAPIData
import com.inappstory.sdk.externalapi.StoryFavoriteItemAPIData
import com.inappstory.sdk.externalapi.subscribers.InAppStoryAPIListSubscriber
import com.inappstory.sdk.game.reader.GameStoryData
import com.inappstory.sdk.stories.api.models.CachedSessionData
import com.inappstory.sdk.stories.outercallbacks.common.errors.ErrorCallback
import com.inappstory.sdk.stories.outercallbacks.common.gamereader.GameReaderCallback
import com.inappstory.sdk.stories.outercallbacks.common.onboarding.OnboardingLoadCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.CallToActionCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.ClickAction
import com.inappstory.sdk.stories.outercallbacks.common.reader.ClickOnShareStoryCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.CloseReader
import com.inappstory.sdk.stories.outercallbacks.common.reader.CloseStoryCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.FavoriteStoryCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.LikeDislikeStoryCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.ShowSlideCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.ShowStoryAction
import com.inappstory.sdk.stories.outercallbacks.common.reader.ShowStoryCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.SlideData
import com.inappstory.sdk.stories.outercallbacks.common.reader.StoryData
import com.inappstory.sdk.stories.outercallbacks.common.reader.StoryWidgetCallback
import com.inappstory.sdk.stories.outercallbacks.common.single.SingleLoadCallback
import com.inappstory.sdk.stories.ui.views.goodswidget.GetGoodsDataCallback
import com.inappstory.sdk.stories.ui.views.goodswidget.GoodsItemData
import com.inappstory.sdk.stories.ui.views.goodswidget.ICustomGoodsItem
import com.inappstory.sdk.stories.ui.views.goodswidget.ICustomGoodsWidget
import com.inappstory.sdk.stories.ui.views.goodswidget.IGoodsWidgetAppearance
import com.inappstory.sdk.ugc.UGCInAppStoryManager
import java.lang.reflect.Field
import java.util.Locale

/*
idgetEventName,
                     Map<String, String> widgetData,
                     int storyId,
                     String storyTitle,
                     String feed,
                     int slidesCount,
                     int slideIndex,
                     String tags) */
fun sendEvent(
        reactContext: ReactApplicationContext,
        eventName: String,
        params: Map<String, Any>?
) {
//    reactContext
//        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
//        .emit(eventName, params)
}

class InAppStory {
    companion object {
        fun initSDK(context: Context) {
            InAppStoryManager.initSDK(context)
        }
    }
}


class InappstorySdkModule(var reactContext: ReactApplicationContext) :
        ReactContextBaseJavaModule(reactContext) {
    override fun getName() = "RNInAppStorySDKModule"
    var ias: InAppStoryManager? = null
    var appearanceManager: AppearanceManager? = null;
    var api: InAppStoryAPI? = null;
    var favoritesApi: InAppStoryAPI? = null;
    var TAG: String = "IAS_SDK_API";

    var stories: ArrayList<String>? = null;
    var goodsCache: ArrayList<GoodsItemData> = ArrayList<GoodsItemData>()
    private var listenerCount = 0

    @ReactMethod
    fun getStories(feed: String) {
        Log.d("InappstorySdkModule", "getStories");
        this.api?.storyList?.load(
                feed,
                "feed",
                true,
                false,
                this.ias?.getTags()
        )
        //this.api.getStories()
    }

    @ReactMethod
    fun getFavoriteStories(feed: String) {
        Log.d("InappstorySdkModule", "getFavoriteStories");
        this.favoritesApi?.storyList?.load(
                feed,
                "favorites",
                true,
                true,
                this.ias?.getTags()
        )
    }

    @ReactMethod
    fun addListener(eventName: String) {
        if (listenerCount == 0) {
            // Set up any upstream listeners or background tasks as necessary
        }

        listenerCount += 1
    }

    @ReactMethod
    fun selectFavoriteStoryCellWith(storyID: String) {
        this.favoritesApi?.storyList?.openStoryReader(
                reactContext.currentActivity,
                "favorites",
                storyID.toInt(),
                this.appearanceManager
        );
    }

    @ReactMethod
    fun removeListeners(count: Int) {
        listenerCount -= count
        if (listenerCount == 0) {
            // Remove upstream listeners, stop unnecessary background tasks
        }
    }

    @ReactMethod
    fun initWith(apiKey: String, userID: String, sandbox: Boolean, sendStatistics: Boolean) {
        Log.d("InappstorySdkModule", "initWith")
        //this.ias = this.createInAppStoryManager(apiKey, userID)
//        this.appearanceManager = AppearanceManager()
        this.api = InAppStoryAPI()
        this.favoritesApi = InAppStoryAPI()
        this.createManager(
                apiKey,
                userID,
                sandbox,
                sendStatistics,
                this.favoritesApi as InAppStoryAPI
        )
        this.createManager(apiKey, userID, sandbox, sendStatistics, this.api as InAppStoryAPI)
//        this.subscribeLists(this.api as InAppStoryAPI, "feed")
//        this.subscribeLists(this.favoritesApi as InAppStoryAPI, "favorites")
//        setupListeners()
    }

    @ReactMethod
    fun setUserID(userId: String) {
        Log.d("InappstorySdkModule", "setUserID")
        this.ias?.setUserId(userId)
    }

    @ReactMethod
    fun closeReader() {
        //this.ias?.closeStoryReader()
        InAppStoryManager.closeStoryReader()
    }

    @ReactMethod
    fun setLang(lang: String) {
        Log.d("InappstorySdkModule", "setLang")
        this.ias?.setLang(Locale.forLanguageTag("en-US"))
    }

    fun setupListeners() {

        val that: InappstorySdkModule = this;
        //Goods widget
        AppearanceManager.getCommonInstance().csCustomGoodsWidget(object : ICustomGoodsWidget {
            override fun getWidgetView(context: Context): View? {
                print("csCustomGoodsWidget getWidgetView");
                return null;
            }

            override fun getItem(): ICustomGoodsItem? {
                print("csCustomGoodsWidget getItem");
                return null;
            }

            override fun getWidgetAppearance(): IGoodsWidgetAppearance? {
                print("csCustomGoodsWidget getWidgetAppearance");
                return null;
            }

            override fun getDecoration(): RecyclerView.ItemDecoration? {
                print("csCustomGoodsWidget getDecoration");
                return null;
            }

            public override fun getSkus(
                    widgetView: View,
                    skus: ArrayList<String>,
                    callback: GetGoodsDataCallback
            ) {
                print("csCustomGoodsWidget getSkus = $skus")
                var payload =
                        mutableMapOf(
                                "skus" to skus,
                        ) as Map<String, Any>
                sendEvent(reactContext, "getGoodsObject", payload)
                val handler = Handler()
                val runnableCode: Runnable = Runnable {
                    if (that.goodsCache.size > 0) {
                        callback.onSuccess(that.goodsCache)
                        that.goodsCache.clear();
                    } else {
                        handler.postDelayed(this as Runnable, 250)
                    }
                }
                handler.post(runnableCode)


            }

            override fun onItemClick(
                    widgetView: View,
                    goodsItemView: View,
                    goodsItemData: GoodsItemData,
                    callback: GetGoodsDataCallback
            ) {
                var payload =
                        mutableMapOf(
                                "sku" to goodsItemData.sku,
                        ) as Map<String, Any>
                sendEvent(reactContext, "goodItemSelected", payload)
                callback.onClose()
                InAppStoryManager.closeStoryReader()
                return;
            }
        });

        this.ias?.setShowStoryCallback(
                object : ShowStoryCallback {
                    override fun showStory(
                            story: StoryData?,
                            showStoryAction: ShowStoryAction?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "action" to when (showStoryAction) {
                                            ShowStoryAction.OPEN -> "open"
                                            ShowStoryAction.TAP -> "tap"
                                            ShowStoryAction.SWIPE -> "swipe"
                                            ShowStoryAction.AUTO -> "auto"
                                            ShowStoryAction.CUSTOM -> "custom"
                                            null -> "unknown"
                                        },
                                        "feed" to story?.feed,
                                        "id" to story?.id
                                ) as Map<String, Any>
                        sendEvent(reactContext, "showStory", payload)
                    }
                }
        )
        this.ias?.setShowSlideCallback(
                object : ShowSlideCallback {
                    override fun showSlide(
                            slide: SlideData?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "id" to slide?.story?.id,
                                        "index" to slide?.index

                                ) as Map<String, Any>
                        sendEvent(reactContext, "showSlide", payload)
                    }
                }
        )
        this.ias?.setCloseStoryCallback(
                object : CloseStoryCallback {
                    override fun closeStory(
                            slide: SlideData?,
                            action: CloseReader?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "action" to when (action) {
                                            CloseReader.AUTO -> "auto"
                                            CloseReader.CLICK -> "click"
                                            CloseReader.SWIPE -> "swipe"
                                            CloseReader.CUSTOM -> "custom"
                                            null -> "unknown"
                                        },
                                        "feed" to slide?.story?.feed,
                                        "id" to slide?.story?.id

                                ) as Map<String, Any>
                        sendEvent(reactContext, "closeStory", payload)
                    }
                }
        )

        this.ias?.setCallToActionCallback(
                object : CallToActionCallback {
                    override fun callToAction(
                            context: Context?, //Here context of story reader or context of storiesList if it calls from it's deeplinks
                            slide: SlideData?,
                            url: String?,
                            action: ClickAction
                    ) {
                        var payload =
                                mutableMapOf(
                                        "action" to when (action) {
                                            ClickAction.BUTTON -> "button"
                                            ClickAction.SWIPE -> "swipe"
                                            ClickAction.GAME -> "game"
                                            ClickAction.DEEPLINK -> "deeplink"
                                        },
                                        "feed" to slide?.story?.feed,
                                        "index" to slide?.index,
                                        "id" to slide?.story?.id,
                                        "url" to url

                                ) as Map<String, Any>

                        Log.d(
                                "InappstorySdkModule",
                                "callToAction slide = $slide url = $url action= $action"
                        );
                        // currently not work two sendEvent simultaneously
                        //if (action == ClickAction.BUTTON) {
                        // just event
                        //sendEvent(reactContext, "clickOnButton", payload)
                        //}
                        // CTA(link) handler
                        sendEvent(reactContext, "handleCTA", payload)

                    }
                }
        )
        this.ias?.setFavoriteStoryCallback(
                object : FavoriteStoryCallback {
                    override fun favoriteStory(
                            slide: SlideData?,
                            value: Boolean
                    ) {
                        var payload =
                                mutableMapOf(
                                        "feed" to slide?.story?.feed,
                                        "index" to slide?.index,
                                        "storyID" to slide?.story?.id,
                                        "favorite" to value

                                ) as Map<String, Any>
                        sendEvent(reactContext, "favoriteStory", payload)
                    }
                }
        )
        this.ias?.setLikeDislikeStoryCallback(
                object : LikeDislikeStoryCallback {
                    override fun likeStory(
                            slide: SlideData?,
                            value: Boolean
                    ) {
                        var payload =
                                mutableMapOf(
                                        "feed" to slide?.story?.feed,
                                        "index" to slide?.index,
                                        "id" to slide?.story?.id,
                                        "value" to value

                                ) as Map<String, Any>
                        sendEvent(reactContext, "likeStory", payload)
                    }

                    override fun dislikeStory(
                            slide: SlideData?,
                            value: Boolean
                    ) {
                        var payload =
                                mutableMapOf(
                                        "feed" to slide?.story?.feed,
                                        "index" to slide?.index,
                                        "id" to slide?.story?.id,
                                        "value" to value

                                ) as Map<String, Any>
                        sendEvent(reactContext, "dislikeStory", payload)
                    }
                }
        )
        this.ias?.setClickOnShareStoryCallback(
                object : ClickOnShareStoryCallback {
                    override fun shareClick(
                            slide: SlideData?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "feed" to slide?.story?.feed,
                                        "index" to slide?.index,
                                        "id" to slide?.story?.id

                                ) as Map<String, Any>
                        sendEvent(reactContext, "clickOnShareStory", payload)
                        Log.d("InappstorySdkModule", "clickOnShareStory slide = $slide");
                    }
                }
        )
        this.ias?.setOnboardingLoadCallback(
                object : OnboardingLoadCallback {
                    override fun onboardingLoad(count: Int, feed: String?) {
                        var payload =
                                mutableMapOf(
                                        "count" to count,
                                        "feed" to feed,

                                        ) as Map<String, Any>
                        sendEvent(reactContext, "onboardingLoad", payload)
                        Log.d("InappstorySdkModule", "onboardingLoad count = $count, feed = $feed");
                    }
                }
        )
        this.ias?.setSingleLoadCallback(
                object : SingleLoadCallback {
                    override fun singleLoad(story: StoryData?) {
                        var payload =
                                mutableMapOf(
                                        "id" to story?.id,
                                        "feed" to story?.feed,

                                        ) as Map<String, Any>
                        sendEvent(reactContext, "singleLoad", payload)
                        Log.d("InappstorySdkModule", "singleLoad story = $story");
                    }
                }
        )
        this.ias?.setStoryWidgetCallback(
                object : StoryWidgetCallback {
                    override fun widgetEvent(
                            slideData: SlideData?,
                            widgetEventName: String?,
                            widgetData: Map<String, String?>?,
                            //feed: String?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "feed" to slideData?.story?.feed,
                                        "id" to slideData?.story?.id,
                                        "name" to widgetEventName,
                                        "data" to widgetData
                                ) as Map<String, Any>
                        sendEvent(reactContext, "storyWidgetEvent", payload)
                        Log.d(
                                "InappstorySdkModule",
                                "storyWidget story = $slideData, widgetEventName = $widgetEventName, widgetData = $widgetData"
                        );
                    }
                }
        )
        this.ias?.setGameReaderCallback(
                object : GameReaderCallback {
                    override fun startGame(
                            gameStoryData: GameStoryData?,
                            id: String?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "storyID" to gameStoryData?.slideData?.story?.id,
                                        "index" to gameStoryData?.slideData?.index,
                                        "id" to id
                                ) as Map<String, Any>
                        sendEvent(reactContext, "startGame", payload)
                    }

                    override fun finishGame(
                            gameStoryData: GameStoryData?,
                            result: String?,
                            id: String?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "storyID" to gameStoryData?.slideData?.story?.id,
                                        "index" to gameStoryData?.slideData?.index,
                                        "result" to result,
                                        "id" to id
                                ) as Map<String, Any>
                        sendEvent(reactContext, "finishGame", payload)
                    }

                    override fun closeGame(
                            gameStoryData: GameStoryData?,
                            id: String?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "storyID" to gameStoryData?.slideData?.story?.id,
                                        "index" to gameStoryData?.slideData?.index,
                                        "id" to id
                                ) as Map<String, Any>
                        sendEvent(reactContext, "closeGame", payload)
                    }

                    override fun gameLoadError(
                            gameStoryData: GameStoryData?,
                            id: String?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "storyID" to gameStoryData?.slideData?.story?.id,
                                        "index" to gameStoryData?.slideData?.index,
                                        "id" to id
                                ) as Map<String, Any>
                        sendEvent(reactContext, "gameFailure", payload)
                        Log.d(
                                "InappstorySdkModule",
                                "gameLoadError gameStoryData = $gameStoryData, id = $id"
                        );
                    }

                    override fun gameOpenError(
                            gameStoryData: GameStoryData?,
                            id: String?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "storyID" to gameStoryData?.slideData?.story?.id,
                                        "index" to gameStoryData?.slideData?.index,
                                        "id" to id
                                ) as Map<String, Any>
                        sendEvent(reactContext, "gameFailure", payload)
                        Log.d(
                                "InappstorySdkModule",
                                "gameOpenError gameStoryData = $gameStoryData, id = $id"
                        );
                    }

                    override fun eventGame(
                            gameStoryData: GameStoryData?,
                            id: String?,
                            id2: String?,
                            id3: String?
                    ) {
                        var payload =
                                mutableMapOf(
                                        "storyID" to gameStoryData?.slideData?.story?.id,
                                        "index" to gameStoryData?.slideData?.index,
                                        "id" to id,
                                        "id2" to id2,
                                        "id3" to id3
                                ) as Map<String, Any>
                        sendEvent(reactContext, "eventGame", payload)
                        Log.d(
                                "InappstorySdkModule",
                                "eventGame gameStoryData = $gameStoryData, id = $id , id2 = $id2 , id3 = $id3"
                        );
                    }
                }
        )
        this.ias?.setErrorCallback(
                object : ErrorCallback {
                    override fun loadListError(feed: String?) {
                        var payload =
                                mutableMapOf(
                                        "feed" to feed
                                ) as Map<String, Any>
                        sendEvent(reactContext, "loadListError", payload)
                        Log.d("InappstorySdkModule", "loadListError feed = $feed");
                    }

                    override fun loadOnboardingError(feed: String?) {
                        var payload =
                                mutableMapOf(
                                        "feed" to feed
                                ) as Map<String, Any>
                        sendEvent(reactContext, "loadOnboardingError", payload)
                        Log.d("InappstorySdkModule", "loadOnboardingError feed = $feed");
                    }

                    override fun loadSingleError() {
                        val payload = mutableMapOf<String, Any>()
                        sendEvent(reactContext, "loadSingleError", payload)
                        Log.d("InappstorySdkModule", "loadSingleError");
                    }

                    override fun cacheError() {
                        val payload = mutableMapOf<String, Any>()
                        sendEvent(reactContext, "cacheError", payload)
                        Log.d("InappstorySdkModule", "cacheError");
                    }

                    override fun readerError() {
                        val payload = mutableMapOf<String, Any>()
                        sendEvent(reactContext, "readerError", payload)
                        Log.d("InappstorySdkModule", "readerError");
                    }

                    override fun emptyLinkError() {
                        val payload = mutableMapOf<String, Any>()
                        sendEvent(reactContext, "emptyLinkError", payload)
                        Log.d("InappstorySdkModule", "emptyLinkError");
                    }

                    override fun sessionError() {
                        val payload = mutableMapOf<String, Any>()
                        sendEvent(reactContext, "sessionError", payload)
                        Log.d("InappstorySdkModule", "sessionError");
                    }

                    override fun noConnection() {
                        val payload = mutableMapOf<String, Any>()
                        sendEvent(reactContext, "noConnection", payload)
                        Log.d("InappstorySdkModule", "noConnection");
                    }

                }
        )
    }

    @ReactMethod
    fun addProductToCache(
            sku: String,
            title: String,
            subtitle: String,
            imageURL: String,
            price: String,
            oldPrice: String
    ) {
        val data = GoodsItemData(
                sku,
                title,
                subtitle,
                imageURL,
                price,
                oldPrice,
                sku
        )
        this.goodsCache.add(data)
    }

//    @ReactMethod
//    fun showGame(gameID: String, promise: Promise) {
//        Log.d("InappstorySdkModule", "showGame")
//        try {
//            this.ias?.openGame(gameID, getCurrentActivity() as Context)
//            promise.resolve(gameID)
//        } catch (e: Throwable) {
//            promise.reject("showGame error", e)
//        }
//    }

//    @ReactMethod
//    fun showSingle(storyID: String, promise: Promise) {
//        Log.d("InappstorySdkModule", "showSingle")
//        try {
//            this.ias?.showStory(storyID, getCurrentActivity(), this.appearanceManager)
//            promise.resolve(true)
//        } catch (e: Throwable) {
//            promise.reject("showGame error", e)
//        }
//    }

    @ReactMethod
    fun setTags(tags: List<String>) {
        Log.d("InappstorySdkModule", "setTags")
        val arrayList = ArrayList<String>()
        arrayList.addAll(tags)
        this.ias?.setTags(arrayList)
    }

    @ReactMethod
    fun setPlaceholders(placeholders: Map<String, String>) {
        Log.d("InappstorySdkModule", "setPlaceholders $placeholders")
        this.ias?.setPlaceholders(placeholders)
    }

//    @ReactMethod
//    fun setImagesPlaceholders(imagePlaceholders: ReadableArray) {
//        Log.d("InappstorySdkModule", "setImagesPlaceholders")
//        var nativeMap: ReadableNativeMap = imagePlaceholders as ReadableNativeMap;
//        var imageMap: Map<String, ImagePlaceholderValue> = nativeMap.toHashMap()
//            .mapValues { ImagePlaceholderValue.createByUrl(it.value as String) }
//        this.ias?.setImagePlaceholders(imageMap)
//    }

    @ReactMethod
    fun changeSound(value: Boolean) {
        Log.d("InappstorySdkModule", "changeSound")
        this.ias?.soundOn(value)
    }

//    @ReactMethod
//    fun getSound(promise: Promise) {
//        Log.d("InappstorySdkModule", "getSound")
//        promise.resolve(this.ias?.soundOn())
//    }

    @ReactMethod
    fun setHasLike(value: Boolean) {
        Log.d("InappstorySdkModule", "setHasLike")
        this.appearanceManager?.csHasLike(value);
    }

    @ReactMethod
    fun setHasFavorites(value: Boolean) {
        Log.d("InappstorySdkModule", "setHasFavorites")
        this.appearanceManager?.csHasFavorite(value);
    }

    @ReactMethod
    fun setHasShare(value: Boolean) {
        Log.d("InappstorySdkModule", "setHasShare")
        this.appearanceManager?.csHasShare(value);
    }

    @ReactMethod
    fun setPresentationStyle(style: String) {
        Log.d("InappstorySdkModule", "setPresentationStyle")
        if (style == "zoom") {
            this.appearanceManager?.csStoryReaderPresentationStyle(0)
        }
        if (style == "fade") {
            this.appearanceManager?.csStoryReaderPresentationStyle(1)
        }
        if (style == "popup") {
            this.appearanceManager?.csStoryReaderPresentationStyle(2)
        }
        if (style == "disable") {
            this.appearanceManager?.csStoryReaderPresentationStyle(-1)
        }
    }

    @ReactMethod
    fun setScrollStyle(scrollStyle: String) {
        Log.d("InappstorySdkModule", "setScrollStyle")
        if (scrollStyle == "depth") {
            this.appearanceManager?.csStoryReaderAnimation(1)
        }
        if (scrollStyle == "cube") {
            this.appearanceManager?.csStoryReaderAnimation(2)
        }
        if (scrollStyle == "cover") {
            this.appearanceManager?.csStoryReaderAnimation(3)
        }
        if (scrollStyle == "flat") {
            this.appearanceManager?.csStoryReaderAnimation(4)
        }
    }

    @ReactMethod
    fun setSwipeToClose(value: Boolean) {
        Log.d("InappstorySdkModule", "setSwipeToClose")
        this.appearanceManager?.csCloseOnSwipe(value)
    }

    @ReactMethod
    fun setOverScrollToClose(value: Boolean) {
        Log.d("InappstorySdkModule", "setOverScrollToClose")
        this.appearanceManager?.csCloseOnOverscroll(value)
    }

    @ReactMethod
    fun setCloseButtonPosition(value: String) {
        Log.d("InappstorySdkModule", "setCloseButtonPosition")
        if (value == "left") {
            this.appearanceManager?.csClosePosition(1)
        }
        if (value == "right") {
            this.appearanceManager?.csClosePosition(2)
        }
        if (value == "bottomLeft") {
            this.appearanceManager?.csClosePosition(3)
        }
        if (value == "bottomRight") {
            this.appearanceManager?.csClosePosition(4)
        }

    }

    @ReactMethod
    fun setReaderCornerRadius(radius: Int) {
        Log.d("InappstorySdkModule", "setReaderCornerRadius")
        this.appearanceManager?.csReaderRadius(radius);
    }

    @ReactMethod
    fun setReaderBackgroundColor(color: String) {
        Log.d("InappstorySdkModule", "setReaderBackgroundColor")
        //TODO
    }

    @ReactMethod
    fun setTimerGradientEnable(value: Boolean) {
        Log.d("InappstorySdkModule", "setTimerGradientEnable")
        this.appearanceManager?.csTimerGradientEnable(value)
    }


    /*
      @ReactMethod
      fun removeFromFavorite(storyID: String) {
          Log.d("InappstorySdkModule", "removeFromFavorite")
          //TODO
      }

      @ReactMethod
      fun removeAllFavorites() {
          Log.d("InappstorySdkModule", "removeAllFavorites")
          //TODO
      }

      @ReactMethod
      fun addTags() {
          Log.d("InappstorySdkModule", "addTags")
          //this.ias?.addTags(tags)
      }

      @ReactMethod
      fun removeTags() {
          Log.d("InappstorySdkModule", "removeTags")
          ///this.ias?.removeTags(tags)
      }



      @ReactMethod
      fun getFavoritesCount() {
          Log.d("InappstorySdkModule", "getFavoritesCount")
          //TODO
      }

      @ReactMethod
      fun getFrameworkInfo() {
          Log.d("InappstorySdkModule", "getFrameworkInfo")
          //TODO
      }

      @ReactMethod
      fun getBuildNumber() {
          Log.d("InappstorySdkModule", "getBuildNumber")
          //TODO
      }

      @ReactMethod
      fun getVersion() {
          Log.d("InappstorySdkModule", "getVersion")
          //TODO
      }


      @ReactMethod
      fun setTimerGradient() {
          Log.d("InappstorySdkModule", "setTimerGradient")
          //TODO
      }

      @ReactMethod
      fun setPlaceholderElementColor() {
          Log.d("InappstorySdkModule", "setPlaceholderElementColor")
          //TODO
      }

      @ReactMethod
      fun setPlaceholderBackgroundColor() {
          Log.d("InappstorySdkModule", "setPlaceholderBackgroundColor")
          //TODO
      }



      @ReactMethod
      fun setCoverQuality() {
          Log.d("InappstorySdkModule", "setCoverQuality")
          //TODO
      }

      @ReactMethod
      fun setShowCellTitle() {
          Log.d("InappstorySdkModule", "setShowCellTitle")
          //TODO
      }

      @ReactMethod
      fun setCellGradientEnabled() {
          Log.d("InappstorySdkModule", "setCellGradientEnabled")
          //TODO
      }

      @ReactMethod
      fun setCellGradientRadius() {
          Log.d("InappstorySdkModule", "setCellGradientRadius")
          //TODO
      }

      @ReactMethod
      fun setCellBorderColor() {
          Log.d("InappstorySdkModule", "setCellBorderColor")
          //TODO
      }

      @ReactMethod
      fun setGoodsCellImageBackgroundColor() {
          Log.d("InappstorySdkModule", "setGoodsCellImageBackgroundColor")
          //TODO
      }

      @ReactMethod
      fun setGoodsCellImageCornerRadius() {
          Log.d("InappstorySdkModule", "setGoodsCellImageCornerRadius")
          //TODO
      }

      @ReactMethod
      fun setGoodsCellMainTextColor() {
          Log.d("InappstorySdkModule", "setGoodsCellMainTextColor")
          //TODO
      }

      @ReactMethod
      fun setGoodsCellOldPriceTextColor() {
          Log.d("InappstorySdkModule", "setGoodsCellOldPriceTextColor")
          //TODO
      }

      @ReactMethod
      fun clearCache() {
          Log.d("InappstorySdkModule", "clearCache")
          this.ias?.clearCache()
      }

      @ReactMethod
      fun setLogging(value: Boolean) {
          Log.d("InappstorySdkModule", "setLogging")

        //this.ias.enableLogging = value
      }

      @ReactMethod
      fun useDeviceID() {
          Log.d("InappstorySdkModule", "useDeviceID")
          //TODO
      }
    */
//    @ReactMethod
//    fun showOnboardings(feed: String, limit: Int, tags: ReadableArray, promise: Promise) {
//        var tags: List<String>? = null; //FIXME
//        Log.d("InappstorySdkModule", "showOnboardings")
//        if (limit != null) {
//            this.ias?.showOnboardingStories(
//                limit,
//                feed,
//                tags,
//                reactContext.currentActivity,
//                this.appearanceManager
//            )
//        } else {
//            this.ias?.showOnboardingStories(
//                feed,
//                tags,
//                reactContext.currentActivity,
//                this.appearanceManager
//            )
//        }
//        promise.resolve(feed)
//    }

//    @ReactMethod
//    fun setVisibleWith(storyIDs: ReadableArray) {
//        Log.d("InappstorySdkModule", "setVisibleWith")
//        val stringIds: ArrayList<String> = storyIDs.toArrayList() as ArrayList<String>
//        var ids: List<Int> = stringIds.map { it.toInt() }
//        Log.d("InappstorySdkModule", "ids: $ids")
//        this.api?.storyList?.updateVisiblePreviews(ids, "feed")
//    }

    @ReactMethod
    fun selectStoryCellWith(storyID: String) {
        Log.d("InappstorySdkModule", "selectStoryCellWith")
        this.api?.storyList?.openStoryReader(
                reactContext.currentActivity,
                "feed",
                storyID.toInt(),
                this.appearanceManager
        );
    }

    fun getImageID(imgName: String): Int {
        return 42
//        var id: Int = reactContext.getResources().getIdentifier(imgName, "drawable", reactContext.currentActivity?.getPackageName());
//        return id;
    }

    @ReactMethod
    fun setLikeImage(image: String, selectedImage: String) {
        this.appearanceManager?.csLikeIcon(this.getImageID(image));
    }

    @ReactMethod
    fun setDislikeImage(image: String, selectedImage: String) {
        this.appearanceManager?.csDislikeIcon(this.getImageID(image));
    }

    @ReactMethod
    fun setFavoriteImage(image: String, selectedImage: String) {
        this.appearanceManager?.csFavoriteIcon(this.getImageID(image));
    }

    @ReactMethod
    fun setShareImage(image: String, selectedImage: String) {
        this.appearanceManager?.csShareIcon(this.getImageID(image));
    }

    @ReactMethod
    fun setSoundImage(image: String, selectedImage: String) {
        this.appearanceManager?.csSoundIcon(this.getImageID(image));
    }

    @ReactMethod
    fun setCloseReaderImage(image: String) {
        this.appearanceManager?.csCloseIcon(this.getImageID(image));
    }

    @ReactMethod
    fun setCloseGoodsImage(image: String) {
        this.appearanceManager?.csCloseIcon(this.getImageID(image));
    }

    @ReactMethod
    fun setRefreshImage(image: String) {
        this.appearanceManager?.csRefreshIcon(this.getImageID(image));
    }

    @ReactMethod
    fun showEditor() {
        Log.d("IAS", "openEditor")
        this.appearanceManager?.csHasUGC(true)
        UGCInAppStoryManager.init(reactContext.currentActivity as Context)
        UGCInAppStoryManager.openEditor(reactContext.currentActivity as Context)
        //promise.resolve(true)
    }

    private fun createManager(
            apiKey: String,
            userID: String,
            sandbox: Boolean,
            sendStatistic: Boolean,
            inAppStoryAPI: InAppStoryAPI
    ) {
        this.ias = inAppStoryAPI.inAppStoryManager.create(
                apiKey,
                userID,
                null,
                null,
                null,
                null,
                null,
                null,
                true,
                null,
                sandbox,
        )
        this.ias?.let {
            val f1: Field = it.javaClass.getDeclaredField("sendStatistic")
            f1.isAccessible = true
            f1.set(it, sendStatistic)
        }
    }

    fun subscribeLists(inAppStoryAPI: InAppStoryAPI, feed: String) {
        inAppStoryAPI.addSubscriber(object : InAppStoryAPIListSubscriber(feed) {
            override fun updateFavoriteItemData(favorites: List<StoryFavoriteItemAPIData>) {
                Log.e(TAG, "$feed updateFavoriteItemData: $favorites")
            }

            override fun updateStoryData(story: StoryAPIData) {
                var sessionData: CachedSessionData = CachedSessionData.getInstance(reactContext);
                var aspectRatio: Float = 1.0f;
                if (sessionData != null) {
                    aspectRatio = sessionData.previewAspectRatio;
                    Log.e(TAG, "aspectratio return $aspectRatio ")
                }
                Log.e(TAG, "$feed updateStoryData: $story")
                var payload =
                        mutableMapOf(
                                "storyID" to story.id,
                                //"storyData" to item.storyData,
                                "title" to story.title,
                                "coverImagePath" to story.imageFilePath,
                                "coverVideoPath" to story.videoFilePath,
                                "backgroundColor" to story.backgroundColor,
                                "titleColor" to story.titleColor,
                                "opened" to story.opened,
                                "hasAudio" to false, //FIXME
                                "list" to feed,
                                "feed" to story.storyData.feed,
                                "aspectRatio" to aspectRatio
                        ) as Map<String, Any>
                Log.e(TAG, "Item = $story")
                sendEvent(reactContext, "storyUpdate", payload)
            }

            override fun updateStoriesData(stories: List<StoryAPIData>) {
                Log.e(TAG, "$feed updateStoriesData: $stories")
                var sessionData: CachedSessionData = CachedSessionData.getInstance(reactContext);
                var aspectRatio: Float = 1.0f;
                if (sessionData != null) {
                    aspectRatio = sessionData.previewAspectRatio;
                    Log.e(TAG, "aspectratio return $aspectRatio ")
                }
//                val storiesList = ArrayList<WritableNativeMap>()
                val iterator = stories.listIterator()
//                for (item in iterator) {
//                    var storyData = Arguments.makeNativeMap(
//                        mutableMapOf(
//                            "storyID" to item.id,
//                            //"storyData" to item.storyData,
//                            "title" to item.title,
//                            "coverImagePath" to item.imageFilePath,
//                            "coverVideoPath" to item.videoFilePath,
//                            "backgroundColor" to item.backgroundColor,
//                            "titleColor" to item.titleColor,
//                            "opened" to item.opened,
//                            "hasAudio" to false, //FIXME
//                            "list" to feed,
//                            "feed" to item.storyData.feed,
//                            "aspectRatio" to aspectRatio
//                        ) as Map<String, Any>
//                    )
//                    Log.e(TAG, "Item = $item")
//
//                    storiesList.add(storyData)
//                }

                /* val action =

                 val actionArray = Arguments.makeNativeArray(listOf(action))

                 val arguments = Arguments.createMap().apply {
                     putString("path", "general/authentication")
                     putArray("actions",actionArray)
                 }
                 val array = Array(stories.size) { index ->
                     stories[index]
                 }*/
                val payload = mutableMapOf<String, Any>()
//                payload.putArray("stories", Arguments.makeNativeArray(storiesList));
//                payload.putString("feed", "default")
//                payload.putString("list", feed)
                //map.putString("key1", "Value1");
                sendEvent(reactContext, "storyListUpdate", payload)
                //stories.clear()
                //stories.addAll(stories)
                /*Handler(Looper.getMainLooper()).post {
                    inAppStoryAPI.storyList.updateVisiblePreviews(ids, uniqueId1)
                    inAppStoryAPI.storyList.showFavoriteItem(uniqueId1)
                }*/
            }

            override fun storyIsOpened(storyId: Int) {
                Log.e(TAG, "$feed storyIsOpened: $storyId")
            }

            override fun readerIsClosed() {
                Log.e(TAG, "$feed readerIsClosed")
            }

            override fun readerIsOpened() {
                Log.e(TAG, "$feed readerIsOpened")
            }
        })
    }

    fun createInAppStoryManager(
            apiKey: String,
            userId: String
    ): InAppStoryManager {
        Log.d("InAppStoryManager", "createInAppStoryManager");
        return InAppStoryManager.Builder()
                .apiKey(apiKey)
                .userId(userId)
                .create()
    }
}
/*

appearanceManager.csIsDraggable(true);
  :*/

class ReactApplicationContext(val currentActivity: Context) : ContextWrapper(currentActivity)

open class ReactContextBaseJavaModule(private val reactContext: ReactApplicationContext) {
    open fun getName(): String {
        return "getName"
    }

    fun getCurrentActivity(): Context {
        return reactContext.currentActivity
    }
}

annotation class ReactMethod