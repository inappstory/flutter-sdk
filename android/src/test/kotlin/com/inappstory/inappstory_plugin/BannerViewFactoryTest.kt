package com.inappstory.inappstory_plugin

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import com.inappstory.inappstory_plugin.views.BannerCarouselView
import com.inappstory.inappstory_plugin.views.BannerGridView
import com.inappstory.inappstory_plugin.views.BannerPlaceholderStore
import com.inappstory.inappstory_plugin.views.BannerViewFactory
import com.inappstory.sdk.AppearanceManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlin.test.Test
import kotlin.test.assertFailsWith
import kotlin.test.assertSame
import org.mockito.Mockito

class BannerViewFactoryTest {
    @Test
    fun whenGridUsesWrappedContext_passesActivityToNativeBanners() {
        val activity = Mockito.mock(Activity::class.java)
        val context = Mockito.mock(ContextWrapper::class.java)
        Mockito.`when`(context.baseContext).thenReturn(activity)
        val outerContext = Mockito.mock(ContextWrapper::class.java)
        Mockito.`when`(outerContext.baseContext).thenReturn(context)
        val factory = createFactory()
        var bannerContext: Any? = null

        Mockito.mockConstruction(BannerGridView::class.java) { _, construction ->
            bannerContext = construction.arguments()[0]
        }.use {
            for (platformContext in listOf(activity, context, outerContext)) {
                factory.create(platformContext, 1, mapOf("layoutType" to "grid"))
                assertSame(activity, bannerContext)
            }
        }
    }

    @Test
    fun whenGridHasNoActivity_reportsInvalidHostContext() {
        val context = Mockito.mock(ContextWrapper::class.java)
        Mockito.`when`(context.baseContext).thenReturn(Mockito.mock(Context::class.java))

        assertFailsWith<IllegalStateException> {
            createFactory().create(context, 1, mapOf("layoutType" to "grid"))
        }
    }

    @Test
    fun whenCarouselUsesWrappedContext_preservesPlatformContext() {
        val context = Mockito.mock(ContextWrapper::class.java)
        var bannerContext: Any? = null

        Mockito.mockConstruction(BannerCarouselView::class.java) { _, construction ->
            bannerContext = construction.arguments()[0]
        }.use {
            createFactory().create(context, 1, mapOf("layoutType" to "carousel"))
        }

        assertSame(context, bannerContext)
    }

    private fun createFactory(): BannerViewFactory {
        val binding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        Mockito.`when`(binding.binaryMessenger).thenReturn(FakeBinaryMessenger())
        return BannerViewFactory(
            binding,
            AppearanceManager(),
            BannerPlaceholderStore(binding)
        )
    }
}
