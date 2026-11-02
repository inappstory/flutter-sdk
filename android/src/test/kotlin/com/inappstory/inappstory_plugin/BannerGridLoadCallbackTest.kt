package com.inappstory.inappstory_plugin

import BannerPlaceCallbackFlutterApi
import com.inappstory.inappstory_plugin.views.BannerPlaceLoadCallbackHandler
import com.inappstory.sdk.banners.BannerData
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class BannerGridLoadCallbackTest {
    private val messenger = FakeBinaryMessenger()
    private val banners = (1..4).map { BannerData(it, "app-head", null) }
    private val callback = BannerPlaceLoadCallbackHandler(
        placeId = "app-head",
        callbackApi = BannerPlaceCallbackFlutterApi(messenger),
        toDp = { (it + 1L) / 2 },
        waitForContentLoaded = false,
        waitForLayout = true
    )

    @Test
    fun givenFourBanners_whenMeasuredAfterMetadata_thenFullLogicalHeightIsSent() {
        callback.bannerPlaceLoaded(4, banners, -1)
        callback.bannerLoaded(1, true)
        assertTrue(messenger.sentMessages.isEmpty())

        callback.onContentLayout(421)

        assertEquals(listOf(4L, 211L), messenger.sentMessages.single().second)
    }

    @Test
    fun givenLoadedGrid_whenLayoutRepeatsThenResizes_thenOnlyChangedHeightIsSent() {
        callback.bannerPlaceLoaded(4, banners, -1)
        callback.onContentLayout(420)
        repeat(10) { callback.onContentLayout(420) }
        callback.onContentLayout(600)
        repeat(10) { callback.onContentLayout(600) }

        assertEquals(listOf(listOf(4L, 210L), listOf(4L, 300L)),
            messenger.sentMessages.map { it.second })
    }

    @Test
    fun givenGrid_whenLayoutPrecedesMetadata_thenOnlyNextContentLayoutNotifies() {
        callback.onContentLayout(100)
        callback.bannerPlaceLoaded(4, banners, 100)
        assertTrue(messenger.sentMessages.isEmpty())

        callback.onContentLayout(420)

        assertEquals(listOf(4L, 210L), messenger.sentMessages.single().second)
    }

    @Test
    fun givenGrid_whenReloaded_thenSameHeightIsReportedForNewLoadOnlyAfterLayout() {
        callback.bannerPlaceLoaded(4, banners, -1)
        callback.onContentLayout(420)
        callback.prepareForReload()
        callback.onContentLayout(100)
        assertEquals(1, messenger.sentMessages.size)

        callback.bannerPlaceLoaded(4, banners, -1)
        callback.onContentLayout(420)

        assertEquals(listOf(listOf(4L, 210L), listOf(4L, 210L)),
            messenger.sentMessages.map { it.second })
    }

    @Test
    fun givenGrid_whenEmpty_thenZeroIsImmediateAndLaterLayoutsDoNotResurrectIt() {
        callback.bannerPlaceLoaded(0, emptyList(), -2)
        callback.onContentLayout(420)
        callback.bannerLoaded(1, true)

        assertEquals(listOf(0L, 0L), messenger.sentMessages.single().second)
    }

    @Test
    fun givenPendingGrid_whenLoadFails_thenLayoutDoesNotEmitLoaded() {
        callback.bannerPlaceLoaded(4, banners, -1)
        callback.loadError()
        callback.onContentLayout(420)

        assertTrue(messenger.sentMessages.single().first.contains("onBannerPlaceLoadError"))
    }

    @Test
    fun givenGridWithoutMetadata_whenContentFails_thenExistingContentErrorIsReported() {
        callback.bannerLoadError(1, true)
        callback.onContentLayout(420)

        assertTrue(messenger.sentMessages.single().first.contains("onBannerPlaceLoadError"))
        assertEquals(listOf("Failed to load banner content"), messenger.sentMessages.single().second)
    }

    @Test
    fun givenGridWithMetadata_whenContentFails_thenMeasuredHeightStillRevealsNativeRetry() {
        callback.bannerPlaceLoaded(4, banners, -1)
        callback.bannerLoadError(1, true)
        assertTrue(messenger.sentMessages.isEmpty())

        callback.onContentLayout(420)

        assertEquals(listOf(4L, 210L), messenger.sentMessages.single().second)
    }

    @Test
    fun givenGrid_whenDisposed_thenNativeEventsAndLayoutsAreIgnored() {
        callback.bannerPlaceLoaded(4, banners, -1)
        callback.dispose()
        callback.onContentLayout(420)
        callback.bannerPlaceLoaded(4, banners, -1)
        callback.bannerLoaded(1, true)
        callback.loadError()

        assertTrue(messenger.sentMessages.isEmpty())
    }

    @Test
    fun givenQueuedEvents_whenReloadedOrDisposed_thenOldGenerationCannotNotify() {
        val queue = mutableListOf<() -> Unit>()
        val queued = BannerPlaceLoadCallbackHandler(
            placeId = "app-head",
            callbackApi = BannerPlaceCallbackFlutterApi(messenger),
            toDp = { it.toLong() },
            runOnMain = { queue.add(it) },
            waitForContentLoaded = false,
            waitForLayout = true
        )
        queued.bannerPlaceLoaded(4, banners, -1)
        queued.onContentLayout(420)
        queued.prepareForReload()
        queue.toList().forEach { it() }
        assertTrue(messenger.sentMessages.isEmpty())

        queue.clear()
        queued.bannerPlaceLoaded(4, banners, -1)
        queued.onContentLayout(420)
        queued.loadError()
        queued.dispose()
        queue.forEach { it() }

        assertTrue(messenger.sentMessages.isEmpty())
    }

    @Test
    fun givenQueuedCallbacks_whenDisposed_thenPendingWorkIsRemovedAndNoNewWorkIsScheduled() {
        val queue = mutableListOf<() -> Unit>()
        val queued = BannerPlaceLoadCallbackHandler(
            placeId = "app-head",
            callbackApi = BannerPlaceCallbackFlutterApi(messenger),
            toDp = { it.toLong() },
            runOnMain = { queue.add(it) },
            waitForLayout = true,
            cancelPendingCallbacks = { queue.clear() }
        )
        queued.bannerPlaceLoaded(4, banners, -1)
        assertEquals(1, queue.size)

        queued.dispose()
        queued.onContentLayout(420)
        queued.loadError()

        assertTrue(queue.isEmpty())
        assertTrue(messenger.sentMessages.isEmpty())
    }
}
