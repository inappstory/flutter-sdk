package com.inappstory.inappstory_plugin

import android.content.Context
import android.content.res.Resources
import android.util.DisplayMetrics
import android.view.ViewGroup
import com.inappstory.inappstory_plugin.adaptors.IASBannerPlaceManagerAdaptor
import com.inappstory.inappstory_plugin.views.BannerDataListener
import com.inappstory.inappstory_plugin.views.BannerGridView
import com.inappstory.inappstory_plugin.views.BannerPlaceholderStore
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.banners.ui.banner.BannerView
import com.inappstory.sdk.banners.ui.grid.BannerGrid
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.ArgumentCaptor
import org.mockito.Mockito

class BannerGridViewTest {
    @Test
    fun givenGridDecoration_whenSdkAddsRows_thenAppliesRadiusToEveryBanner() {
        val context = Mockito.mock(Context::class.java)
        val resources = Mockito.mock(Resources::class.java)
        val metrics = DisplayMetrics().apply { density = 2f }
        Mockito.`when`(context.resources).thenReturn(resources)
        Mockito.`when`(resources.displayMetrics).thenReturn(metrics)
        val binding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        Mockito.`when`(binding.binaryMessenger).thenReturn(FakeBinaryMessenger())
        Mockito.`when`(binding.applicationContext).thenReturn(context)
        val appearance = AppearanceManager()

        Mockito.mockConstruction(BannerGrid::class.java) { grid, _ ->
            Mockito.`when`(grid.context).thenReturn(context)
        }.use { grids ->
            val view = BannerGridView(
                context,
                mapOf(
                    "autoLoad" to false,
                    "gridHorizontalGap" to 12.0,
                    "gridVerticalGap" to 20.0,
                    "gridCornerRadius" to 32.5,
                ),
                binding,
                appearance,
                IASBannerPlaceManagerAdaptor(binding),
                BannerDataListener(),
                BannerPlaceholderStore { _, _ -> error("must not build a placeholder") },
            )
            repeat(2) { generation ->
                if (generation > 0) view.changeBannerPlaceId("another-place")
                val grid = grids.constructed().last()
                val listener = ArgumentCaptor.forClass(ViewGroup.OnHierarchyChangeListener::class.java)
                Mockito.verify(grid).setOnHierarchyChangeListener(listener.capture())

                repeat(2) {
                    val row = Mockito.mock(ViewGroup::class.java)
                    val banners = List(2) { Mockito.mock(BannerView::class.java) }
                    Mockito.`when`(row.childCount).thenReturn(2)
                    banners.forEachIndexed { index, banner ->
                        Mockito.`when`(row.getChildAt(index)).thenReturn(banner)
                    }

                    listener.value.onChildViewAdded(grid, row)

                    banners.forEach { Mockito.verify(it).setBannerRadius(65f) }
                    listener.value.onChildViewRemoved(grid, row)
                }
            }
            val gridAppearance = appearance.csBannerGridInterface()
            assertEquals(12, gridAppearance.horizontalGap())
            assertEquals(20, gridAppearance.verticalGap())
            view.dispose()
        }
    }
}
