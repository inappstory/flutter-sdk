package com.inappstory.inappstory_plugin.views

import BannerData


typealias BannersData = (BannerData, String, Map<String, String>) -> Unit

class BannerDataListener {
    private val listeners = mutableListOf<BannersData>()

    fun addListener(listener: BannersData) {
        listeners.add(listener)
    }

    fun notifyAll(bannerData: BannerData, eventName: String, widgetData: Map<String, String>) {
        listeners.forEach { it(bannerData, eventName, widgetData) }
    }

    fun removeListener(listener: BannersData) {
        listeners.remove(listener)
    }
}