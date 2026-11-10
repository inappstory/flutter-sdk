package com.inappstory.inappstory_plugin

import PlaceholderDecorationDto
import android.content.Context
import android.content.res.Resources
import android.util.DisplayMetrics
import android.view.View
import androidx.recyclerview.widget.RecyclerView
import com.inappstory.inappstory_plugin.adaptors.IASBannerPlaceManagerAdaptor
import com.inappstory.inappstory_plugin.views.BannerDataListener
import com.inappstory.inappstory_plugin.views.BannerListView
import com.inappstory.inappstory_plugin.views.BannerPlaceholderStore
import com.inappstory.inappstory_plugin.views.CustomBannerListAppearance
import com.inappstory.sdk.AppearanceManager
import com.inappstory.sdk.banners.ui.banner.BannerView
import com.inappstory.sdk.banners.ui.list.BannerList
import com.inappstory.sdk.core.banners.ICustomBannerListAppearance
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import kotlin.test.assertSame
import org.mockito.Mockito
import org.mockito.ArgumentCaptor

class BannerListViewTest {
    @Test
    fun givenListDecoration_whenNativeListIsCreated_thenAppliesSidePaddingAndItemRadius() {
        val context = Mockito.mock(Context::class.java)
        val resources = Mockito.mock(Resources::class.java)
        val metrics = DisplayMetrics().apply { density = 2f }
        Mockito.`when`(context.resources).thenReturn(resources)
        Mockito.`when`(resources.displayMetrics).thenReturn(metrics)
        val binding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        Mockito.`when`(binding.binaryMessenger).thenReturn(FakeBinaryMessenger())

        Mockito.mockConstruction(BannerList::class.java) { list, _ ->
            Mockito.`when`(list.context).thenReturn(context)
        }.use { lists ->
            val view = BannerListView(
                context,
                mapOf(
                    "autoLoad" to false,
                    "listEdgePadding" to 16.0,
                    "listCornerRadius" to 32.0,
                ),
                binding,
                AppearanceManager(),
                IASBannerPlaceManagerAdaptor(binding),
                BannerDataListener(),
                BannerPlaceholderStore { _, _ -> error("must not build a placeholder") },
            )
            val list = lists.constructed().single()
            Mockito.verify(list).setPadding(32, 0, 32, 0)
            val listener = ArgumentCaptor.forClass(
                RecyclerView.OnChildAttachStateChangeListener::class.java
            )
            Mockito.verify(list).addOnChildAttachStateChangeListener(listener.capture())
            val item = Mockito.mock(View::class.java)
            val banner = Mockito.mock(BannerView::class.java)
            Mockito.`when`(
                item.findViewById<BannerView>(com.inappstory.sdk.R.id.bannerView)
            ).thenReturn(banner)

            listener.value.onChildViewAttachedToWindow(item)

            Mockito.verify(banner).setBannerRadius(64f)
            view.dispose()
        }
    }

    @Test
    fun givenNoCustomPlaceholder_whenSdkRequestsLoader_thenReturnsNull() {
        val store = BannerPlaceholderStore { _, _ -> error("must not build a view") }
        val appearance: ICustomBannerListAppearance =
            CustomBannerListAppearance(store::createView)

        assertNull(appearance.loadingPlaceholder(Mockito.mock(Context::class.java)))
    }

    @Test
    fun givenEmptyPlaceholderDecoration_whenSdkRequestsLoader_thenReturnsNull() {
        val store = BannerPlaceholderStore { _, _ -> error("must not build a view") }
        store.decoration = PlaceholderDecorationDto(color = null, image = null)
        val appearance: ICustomBannerListAppearance =
            CustomBannerListAppearance(store::createView)

        assertNull(appearance.loadingPlaceholder(Mockito.mock(Context::class.java)))
    }

    @Test
    fun givenCustomPlaceholder_whenSdkRequestsLoader_thenReturnsCustomView() {
        val placeholder = Mockito.mock(View::class.java)
        val store = BannerPlaceholderStore { _, _ -> placeholder }
        store.decoration = PlaceholderDecorationDto(color = 0xFFFF0000L, image = null)
        val appearance: ICustomBannerListAppearance =
            CustomBannerListAppearance(store::createView)

        assertSame(placeholder, appearance.loadingPlaceholder(Mockito.mock(Context::class.java)))
    }

    @Test
    fun givenCustomDecoration_whenSdkRequestsAppearance_thenReturnsCustomValues() {
        val appearance = CustomBannerListAppearance(
            bannersGap = 20,
            cornerRadius = 6,
            loadingPlaceholder = { null },
        )

        assertEquals(20, appearance.bannersGap())
        assertEquals(6, appearance.cornerRadius())
    }

    @Test
    fun givenNoCustomDecoration_whenSdkRequestsAppearance_thenUsesSdkDefaults() {
        val appearance = CustomBannerListAppearance(loadingPlaceholder = { null })

        assertEquals(4, appearance.edgeBannersPadding())
        assertEquals(8, appearance.bannersGap())
        assertEquals(16, appearance.cornerRadius())
    }
}
