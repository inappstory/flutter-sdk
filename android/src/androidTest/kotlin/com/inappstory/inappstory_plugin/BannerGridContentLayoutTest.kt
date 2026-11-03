package com.inappstory.inappstory_plugin

import BannerPlaceCallbackFlutterApi
import android.view.View
import android.widget.LinearLayout
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.inappstory.inappstory_plugin.views.BannerGridContentLayout
import com.inappstory.inappstory_plugin.views.BannerPlaceLoadCallbackHandler
import com.inappstory.inappstory_plugin.views.InactiveBannerPlaceLoadCallback
import com.inappstory.sdk.banners.BannerData
import com.inappstory.sdk.banners.ui.grid.BannerGrid
import io.flutter.plugin.common.BinaryMessenger
import java.nio.ByteBuffer
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import kotlin.math.ceil

@RunWith(AndroidJUnit4::class)
class BannerGridContentLayoutTest {
    @Test
    fun givenUnmeasuredGrid_whenCachedDataIsBound_thenSdkReceivesWidthBeforeBuildingRows() {
        InstrumentationRegistry.getInstrumentation().runOnMainSync {
            val context = InstrumentationRegistry.getInstrumentation().targetContext
            val grid = BannerGrid(context)
            val layout = BannerGridContentLayout(context)
            layout.addView(grid)
            val widths = mutableListOf<Int>()
            layout.whenWidthReady { widths.add(grid.measuredWidth) }
            layout.whenWidthReady { widths.add(grid.measuredWidth) }
            assertTrue(widths.isEmpty())

            layout.measure(
                View.MeasureSpec.makeMeasureSpec(600, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(150, View.MeasureSpec.EXACTLY)
            )
            layout.layout(0, 0, 600, 150)

            assertEquals(listOf(600, 600), widths)
            layout.requestLayout()
            layout.layout(0, 0, 600, 150)
            assertEquals(2, widths.size)
        }
    }

    @Test
    fun givenUnmeasuredGrid_whenDisposedBeforeLayout_thenDeferredBindingAndLoadAreRemoved() {
        InstrumentationRegistry.getInstrumentation().runOnMainSync {
            val context = InstrumentationRegistry.getInstrumentation().targetContext
            val layout = BannerGridContentLayout(context)
            val grid = BannerGrid(context)
            layout.addView(grid)
            var loads = 0
            layout.whenWidthReady { loads++ }
            layout.dispose()
            grid.loadCallback(InactiveBannerPlaceLoadCallback)

            layout.measure(
                View.MeasureSpec.makeMeasureSpec(600, View.MeasureSpec.EXACTLY),
                View.MeasureSpec.makeMeasureSpec(150, View.MeasureSpec.EXACTLY)
            )
            layout.layout(0, 0, 600, 150)

            assertEquals(0, loads)
        }
    }

    @Test
    fun givenConstrainedGrid_whenLaidOut_thenBothRowsAndGapAreMeasuredWithoutCallbackLoop() {
        val instrumentation = InstrumentationRegistry.getInstrumentation()
        instrumentation.runOnMainSync {
            val context = instrumentation.targetContext
            val grid = BannerGrid(context).apply {
                setPadding(0, 10, 0, 14)
                repeat(2) { row ->
                    addView(
                        LinearLayout(context).apply {
                            repeat(2) {
                                addView(View(context), LinearLayout.LayoutParams(0, 120, 1f))
                            }
                        },
                        LinearLayout.LayoutParams(-1, -2).apply {
                            topMargin = if (row == 0) 0 else 18
                        }
                    )
                }
            }
            val layout = BannerGridContentLayout(context)
            layout.addView(grid)
            val heights = mutableListOf<Int>()
            val notifications = mutableListOf<List<*>>()
            val messenger = object : BinaryMessenger {
                override fun send(channel: String, message: ByteBuffer?) {
                    send(channel, message, null)
                }

                override fun send(
                    channel: String,
                    message: ByteBuffer?,
                    reply: BinaryMessenger.BinaryReply?
                ) {
                    message?.rewind()
                    notifications.add(BannerPlaceCallbackFlutterApi.codec.decodeMessage(message) as List<*>)
                    val response = BannerPlaceCallbackFlutterApi.codec.encodeMessage(listOf(null))
                    response?.rewind()
                    reply?.reply(response)
                }

                override fun setMessageHandler(
                    channel: String,
                    handler: BinaryMessenger.BinaryMessageHandler?
                ) {}
            }
            val callback = BannerPlaceLoadCallbackHandler(
                placeId = "app-head",
                callbackApi = BannerPlaceCallbackFlutterApi(messenger),
                toDp = { ceil(it / context.resources.displayMetrics.density.toDouble()).toLong() },
                waitForContentLoaded = false,
                waitForLayout = true
            )
            callback.bannerPlaceLoaded(
                4, (1..4).map { BannerData(it, "app-head", null) }, -1
            )
            assertTrue(notifications.isEmpty())
            layout.onContentLayout = {
                heights.add(it)
                callback.onContentLayout(it)
            }

            fun measureAndLayout(height: Int) {
                layout.measure(
                    View.MeasureSpec.makeMeasureSpec(600, View.MeasureSpec.EXACTLY),
                    View.MeasureSpec.makeMeasureSpec(height, View.MeasureSpec.EXACTLY)
                )
                layout.layout(0, 0, 600, height)
            }

            measureAndLayout(150)

            assertEquals(282, heights.last())
            assertEquals(
                listOf(4L, ceil(282 / context.resources.displayMetrics.density.toDouble()).toLong()),
                notifications.single()
            )
            assertEquals(282, grid.height)
            assertEquals(268, grid.getChildAt(1).bottom)
            assertEquals(4, (0 until grid.childCount).sumOf {
                (grid.getChildAt(it) as LinearLayout).childCount
            })

            measureAndLayout(282)
            assertTrue(grid.getChildAt(1).bottom + grid.paddingBottom <= layout.height)
            repeat(10) {
                layout.requestLayout()
                measureAndLayout(282)
            }
            assertEquals(1, notifications.size)

            // Width and row-height changes must also remeasure the complete grid.
            grid.getChildAt(1).layoutParams.height = 180
            grid.requestLayout()
            measureAndLayout(282)
            assertEquals(342, heights.last())
            assertEquals(2, notifications.size)

            callback.dispose()
            layout.onContentLayout = null
            val layoutNotifications = heights.size
            layout.requestLayout()
            measureAndLayout(342)
            assertEquals(layoutNotifications, heights.size)
            assertEquals(2, notifications.size)
        }
    }
}
