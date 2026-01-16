package com.inappstory.inappstory_plugin.activity

class BackPressManager {
    var overlayHandler: BackPressManagerHandler? = null
    var isManagerEnabled = false

    fun shouldInterceptBackPress(): Boolean {
        if (isManagerEnabled) {
            if (overlayHandler?.handleBackPress() == true) {
                return true
            }
            return false
        }
        return false
    }
}

abstract class BackPressManagerHandler {
    abstract fun handleBackPress(): Boolean
}