package com.inappstory.inappstory_plugin

import android.view.ContextThemeWrapper
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.inappstory.sdk.stories.ui.widgets.TextMultiInput
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class InputDialogThemeTest {
    @Test
    fun givenDefaultFlutterTheme_whenCreatingSdkInput_thenFieldCanReceiveTouchFocus() {
        val instrumentation = InstrumentationRegistry.getInstrumentation()
        instrumentation.runOnMainSync {
            val context = ContextThemeWrapper(
                instrumentation.targetContext,
                android.R.style.Theme_Light_NoTitleBar
            )
            context.theme.applyStyle(R.style.InAppStoryAppCompatFallback, false)

            val input = TextMultiInput(context)
            input.init(TextMultiInput.TEXT, 3)

            assertTrue(
                "The SDK comment field must be focusable by touch to open the keyboard",
                input.mainText.isFocusableInTouchMode
            )
        }
    }

    @Test
    fun givenHostEditTextStyle_whenApplyingFallback_thenHostStyleIsPreserved() {
        val context = ContextThemeWrapper(
            InstrumentationRegistry.getInstrumentation().targetContext,
            android.R.style.Theme_Light_NoTitleBar
        )
        context.theme.applyStyle(
            com.inappstory.inappstory_plugin.test.R.style.HostEditTextTheme,
            true
        )
        context.theme.applyStyle(R.style.InAppStoryAppCompatFallback, false)

        val attributes = context.obtainStyledAttributes(
            intArrayOf(androidx.appcompat.R.attr.editTextStyle)
        )
        try {
            assertEquals(
                android.R.style.Widget_Material_EditText,
                attributes.getResourceId(0, 0)
            )
        } finally {
            attributes.recycle()
        }
    }
}
