package com.inappstory.inappstory_plugin

import BannerDecorationDTO
import BannerPlaceCallbackFlutterApi
import BannerData as PigeonBannerData
import com.inappstory.inappstory_plugin.adaptors.IASBannerPlaceManagerAdaptor
import com.inappstory.inappstory_plugin.adaptors.LoadBannerPlace
import com.inappstory.inappstory_plugin.adaptors.PauseAutoscroll
import com.inappstory.inappstory_plugin.adaptors.PreloadBannerPlace
import com.inappstory.inappstory_plugin.adaptors.ReloadBannerPlace
import com.inappstory.inappstory_plugin.adaptors.ResumeAutoscroll
import com.inappstory.inappstory_plugin.adaptors.SetInteraction
import com.inappstory.inappstory_plugin.adaptors.SetInteractionPayload
import com.inappstory.inappstory_plugin.adaptors.ShowByIndex
import com.inappstory.inappstory_plugin.adaptors.ShowByIndexPayload
import com.inappstory.inappstory_plugin.adaptors.ShowNext
import com.inappstory.inappstory_plugin.adaptors.ShowPrevious
import com.inappstory.inappstory_plugin.views.BannerPlaceLoadCallbackHandler
import com.inappstory.inappstory_plugin.views.CustomBannerPlaceAppearanceWithoutBannerDecoration
import com.inappstory.sdk.banners.BannerCarouselNavigationCallback
import com.inappstory.sdk.banners.BannerData
import com.inappstory.sdk.banners.BannerPlaceLoadCallback
import com.inappstory.sdk.banners.BannerPlacePreloadCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import java.nio.ByteBuffer
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

class FakeBinaryMessenger : BinaryMessenger {
    val sentMessages = mutableListOf<Pair<String, List<Any?>>>()

    override fun send(channel: String, message: ByteBuffer?) {
        send(channel, message, null)
    }

    override fun send(channel: String, message: ByteBuffer?, callback: BinaryMessenger.BinaryReply?) {
        val args: List<Any?> = if (message != null) {
            message.rewind()
            val decoded = BannerPlaceCallbackFlutterApi.codec.decodeMessage(message)
            if (decoded is List<*>) {
                @Suppress("UNCHECKED_CAST")
                decoded as List<Any?>
            } else {
                emptyList()
            }
        } else {
            emptyList()
        }
        sentMessages.add(Pair(channel, args))

        val replyBuf = BannerPlaceCallbackFlutterApi.codec.encodeMessage(listOf(null))
        replyBuf?.rewind()
        callback?.reply(replyBuf)
    }

    override fun setMessageHandler(channel: String, handler: BinaryMessenger.BinaryMessageHandler?) {}
}

class BannerViewTest {

    @Test
    fun bannerPlaceLoadCallback_loadError_callsOnBannerPlaceLoadError() {
        val messenger = FakeBinaryMessenger()
        val callbackApi = BannerPlaceCallbackFlutterApi(messenger)
        var visibility: Boolean? = null
        val callback = BannerPlaceLoadCallbackHandler(
            placeId = "test_place",
            callbackApi = callbackApi,
            toDp = { it.toLong() },
            onVisibilityChanged = { visibility = it }
        )

        callback.loadError()

        assertEquals(1, messenger.sentMessages.size)
        val (channel, args) = messenger.sentMessages[0]
        assertTrue(channel.contains("onBannerPlaceLoadError"))
        assertEquals("Failed to load banner place", args[0])
        assertEquals(false, visibility)
    }

    @Test
    fun bannerPlaceLoadCallback_emptyList_callsOnBannerPlaceLoadedZeroImmediately() {
        val messenger = FakeBinaryMessenger()
        val callbackApi = BannerPlaceCallbackFlutterApi(messenger)
        var visibility: Boolean? = null
        val callback = BannerPlaceLoadCallbackHandler(
            placeId = "test_place",
            callbackApi = callbackApi,
            toDp = { it.toLong() },
            onVisibilityChanged = { visibility = it }
        )

        callback.bannerPlaceLoaded(0, emptyList(), 120)

        assertEquals(1, messenger.sentMessages.size)
        val (channel, args) = messenger.sentMessages[0]
        assertTrue(channel.contains("onBannerPlaceLoaded"))
        assertEquals(0L, args[0])
        assertEquals(0L, args[1])
        assertEquals(false, visibility)
    }

    @Test
    fun bannerPlaceLoadCallback_nonEmptyList_waitsForBannerLoadedBeforeCallingOnBannerPlaceLoaded() {
        val messenger = FakeBinaryMessenger()
        val callbackApi = BannerPlaceCallbackFlutterApi(messenger)
        var visibility: Boolean? = null
        val callback = BannerPlaceLoadCallbackHandler(
            placeId = "test_place",
            callbackApi = callbackApi,
            toDp = { it.toLong() },
            onVisibilityChanged = { visibility = it }
        )

        val bannerList = listOf(BannerData(1, "test_place"))
        callback.bannerPlaceLoaded(1, bannerList, 120)

        // Metadata loaded, but content NOT loaded yet: onBannerPlaceLoaded should NOT be sent and visibility should NOT be true
        assertEquals(0, messenger.sentMessages.size)
        assertNull(visibility)

        // Once content finishes rendering (slideJSStatus == 1):
        callback.bannerLoaded(1, true)

        assertEquals(1, messenger.sentMessages.size)
        val (channel, args) = messenger.sentMessages[0]
        assertTrue(channel.contains("onBannerPlaceLoaded"))
        assertEquals(1L, args[0])
        assertEquals(120L, args[1])
        assertEquals(true, visibility)

        // Subsequent banner loaded should NOT send duplicate onBannerPlaceLoaded
        callback.bannerLoaded(2, false)
        assertEquals(1, messenger.sentMessages.size)
    }

    @Test
    fun bannerPlaceLoadCallback_bannerLoadError_fallsBackToSendingPendingOnBannerPlaceLoaded() {
        val messenger = FakeBinaryMessenger()
        val callbackApi = BannerPlaceCallbackFlutterApi(messenger)
        var visibility: Boolean? = null
        val callback = BannerPlaceLoadCallbackHandler(
            placeId = "test_place",
            callbackApi = callbackApi,
            toDp = { it.toLong() },
            onVisibilityChanged = { visibility = it }
        )

        val bannerList = listOf(BannerData(1, "test_place"))
        callback.bannerPlaceLoaded(1, bannerList, 150)
        assertEquals(0, messenger.sentMessages.size)
        assertNull(visibility)

        // If banner content fails to load, reveal the carousel with pending size/height so native retry is shown
        callback.bannerLoadError(1, true)
        assertEquals(1, messenger.sentMessages.size)
        val (channel, args) = messenger.sentMessages[0]
        assertTrue(channel.contains("onBannerPlaceLoaded"))
        assertEquals(1L, args[0])
        assertEquals(150L, args[1])
        assertEquals(true, visibility)
    }

    @Test
    fun bannerPlaceLoadCallback_contentLoadedBeforeMetadata_callsOnBannerPlaceLoadedAndSetsVisibilityTrue() {
        val messenger = FakeBinaryMessenger()
        val callbackApi = BannerPlaceCallbackFlutterApi(messenger)
        var visibility: Boolean? = null
        val callback = BannerPlaceLoadCallbackHandler(
            placeId = "test_place",
            callbackApi = callbackApi,
            toDp = { it.toLong() },
            onVisibilityChanged = { visibility = it }
        )

        callback.bannerLoaded(1, true)
        assertEquals(0, messenger.sentMessages.size)
        assertNull(visibility)

        val bannerList = listOf(BannerData(1, "test_place"))
        callback.bannerPlaceLoaded(1, bannerList, 140)

        assertEquals(1, messenger.sentMessages.size)
        val (channel, args) = messenger.sentMessages[0]
        assertTrue(channel.contains("onBannerPlaceLoaded"))
        assertEquals(1L, args[0])
        assertEquals(140L, args[1])
        assertEquals(true, visibility)
    }



    @Test
    fun bannerPlaceLoadCallback_resetState_clearsFlags() {
        val messenger = FakeBinaryMessenger()
        val callbackApi = BannerPlaceCallbackFlutterApi(messenger)
        val callback = BannerPlaceLoadCallbackHandler(
            placeId = "test_place",
            callbackApi = callbackApi,
            toDp = { it.toLong() }
        )

        callback.bannerLoaded(1, true)
        assertTrue(callback.hasBannerContentLoaded)

        callback.resetState()
        assertFalse(callback.hasBannerContentLoaded)
        assertFalse(callback.isBannerPlaceLoadedSent)
        assertNull(callback.pendingBannerPlaceLoaded)
    }

    @Test
    fun bannerCarouselNavigationCallback_onPageSelected_callsOnBannerScroll() {
        val messenger = FakeBinaryMessenger()
        val callbackApi = BannerPlaceCallbackFlutterApi(messenger)

        val navCallback = object : BannerCarouselNavigationCallback {
            override fun onPageScrolled(
                position: Int, total: Int, positionOffset: Float, positionOffsetPixels: Int
            ) {}

            override fun onPageSelected(position: Int, total: Int) {
                callbackApi.onBannerScroll(position.toLong()) {}
            }
        }

        navCallback.onPageSelected(3, 10)

        assertEquals(1, messenger.sentMessages.size)
        val (channel, args) = messenger.sentMessages[0]
        assertTrue(channel.contains("onBannerScroll"))
        assertEquals(3L, args[0])
    }

    @Test
    fun bannerPlacePreloadCallback_callsOnBannerPlacePreloadedAndError() {
        val messenger = FakeBinaryMessenger()
        val callbackApi = BannerPlaceCallbackFlutterApi(messenger)

        val preloadCallback = object : BannerPlacePreloadCallback("test_place") {
            override fun bannerPlaceLoaded(size: Int, bannerData: List<BannerData>) {
                callbackApi.onBannerPlacePreloaded() {}
            }

            override fun loadError() {
                callbackApi.onBannerPlacePreloadedError() {}
            }

            override fun bannerContentLoaded(bannerId: Int, isFirst: Boolean) {}
            override fun bannerContentLoadError(bannerId: Int, isFirst: Boolean) {}
        }

        preloadCallback.bannerPlaceLoaded(2, emptyList())
        assertEquals(1, messenger.sentMessages.size)
        assertTrue(messenger.sentMessages[0].first.contains("onBannerPlacePreloaded"))

        preloadCallback.loadError()
        assertEquals(2, messenger.sentMessages.size)
        assertTrue(messenger.sentMessages[1].first.contains("onBannerPlacePreloadedError"))
    }

    @Test
    fun bannerDataListener_filtersByPlaceId() {
        val messenger = FakeBinaryMessenger()
        val callbackApi = BannerPlaceCallbackFlutterApi(messenger)
        val placeId = "matching_place"

        val bannersDataHandler: (PigeonBannerData, String, Map<String, Any?>?) -> Unit = { bannerData, eventName, widgetData ->
            if (bannerData.bannerPlace == placeId) {
                callbackApi.onActionWith(bannerData, eventName, widgetData) {}
            }
        }

        val matchingBanner = PigeonBannerData(id = "1", bannerPlace = "matching_place", payload = null)
        val mismatchedBanner = PigeonBannerData(id = "2", bannerPlace = "other_place", payload = null)

        // Action with mismatched placeId should not invoke callback
        bannersDataHandler(mismatchedBanner, "CLICK", null)
        assertEquals(0, messenger.sentMessages.size)

        // Action with matching placeId should invoke callback
        bannersDataHandler(matchingBanner, "CLICK", mapOf("foo" to "bar"))
        assertEquals(1, messenger.sentMessages.size)
        val (channel, args) = messenger.sentMessages[0]
        assertTrue(channel.contains("onActionWith"))
        val banner = args[0] as PigeonBannerData
        assertEquals("1", banner.id)
        assertEquals("matching_place", banner.bannerPlace)
        assertEquals("CLICK", args[1])
    }

    @Test
    fun customBannerPlaceAppearanceWithoutBannerDecoration_customValues() {
        val appearance = CustomBannerPlaceAppearanceWithoutBannerDecoration(
            bannerOffset = 16,
            bannersGap = 8,
            cornerRadius = 12,
            loop = true,
        )

        assertEquals(16, appearance.nextBannerOffset())
        assertEquals(16, appearance.prevBannerOffset())
        assertEquals(8, appearance.bannersGap())
        assertEquals(12, appearance.cornerRadius())
        assertTrue(appearance.loop())
    }
}
