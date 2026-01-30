package com.inappstory.inappstory_plugin.activity

import android.os.Build
import android.os.Bundle
import androidx.activity.OnBackPressedCallback
import io.flutter.embedding.android.FlutterFragmentActivity

open class InAppStoryActivity : FlutterFragmentActivity() {

    val backPressManager = BackPressManager()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    val intercepted = backPressManager.shouldInterceptBackPress()
                    if (!intercepted) {
                        isEnabled = false
                        onBackPressedDispatcher.onBackPressed()
                        isEnabled = true
                    }
                }
            })
        }
    }

    @Suppress("DEPRECATION")
    override fun onBackPressed() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            val intercepted = backPressManager.shouldInterceptBackPress()
            if (intercepted) {
                return
            }
        }
        super.onBackPressed()
    }
}