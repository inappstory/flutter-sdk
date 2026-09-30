package com.inappstory.inappstory_plugin.adaptors

import BannerPlaceManagerHostApi
import android.util.Log
import com.inappstory.sdk.InAppStoryManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.util.UUID

typealias Token = UUID

interface EventKey<P : Any>

class Subscription internal constructor(
    private val emitter: IASBannerPlaceManagerAdaptor,
    val token: UUID
) {
    fun unsubscribe() = emitter.unsubscribe(token)
}

class IASBannerPlaceManagerAdaptor(
    val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
) : BannerPlaceManagerHostApi {

    private val subscribers =
        mutableMapOf<EventKey<*>, MutableMap<Token, (Any) -> Unit>>()

    private val tokenToKey = mutableMapOf<Token, EventKey<*>>()

    init {
        BannerPlaceManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    private val isSdkInitialized
        get() = InAppStoryManager.getInstance()?.isInitialized == true

    fun <P : Any> subscribe(key: EventKey<P>, callback: (P) -> Unit): Subscription {
        val id = UUID.randomUUID()
        val anyCallback: (Any) -> Unit = { payload ->
            try {
                @Suppress("UNCHECKED_CAST")
                callback(payload as P)
            } catch (e: ClassCastException) {
                // payload other type
            } catch (e: Throwable) {
                //
            }
        }
        var map = mutableMapOf<Token, (Any) -> Unit>()
        if (subscribers.containsKey(key)) {
            map = subscribers[key] ?: mutableMapOf()
        } else {
            subscribers[key] = map
        }
        map[id] = anyCallback
        tokenToKey[id] = key
        return Subscription(this, id)
    }

    fun unsubscribe(token: Token) {
        val key = tokenToKey.remove(token) ?: return
        val map = subscribers[key]
        map?.remove(token)
        if (map != null && map.isEmpty()) {
            subscribers.remove(key)
        }
    }

    private fun <P : Any> emit(key: EventKey<P>, payload: P) {
        val map = subscribers[key] ?: return
        val callbacks = ArrayList<(Any) -> Unit>(map.values)
        for (cb in callbacks) {
            try {
                cb(payload as Any)
            } catch (e: Throwable) {
            }
        }
    }

    fun removeAll(key: EventKey<*>) {
        val removed = subscribers.remove(key)
        removed?.keys?.forEach { tokenToKey.remove(it) }
    }

    fun removeAll() {
        subscribers.clear()
        tokenToKey.clear()
    }

    override fun loadBannerPlace(placeId: String) {
        if (!isSdkInitialized) {
            Log.w("InAppStory", "BannerPlaceManagerHostApi.loadBannerPlace called before initWith")
            emitBannerPlaceLoadError(placeId, "InAppStory SDK is not initialized")
            return
        }
        emit(LoadBannerPlace, placeId)
    }

    override fun reloadBannerPlace(placeId: String) {
        if (!isSdkInitialized) {
            Log.w("InAppStory", "reloadBannerPlace called before initWith")
            emitBannerPlaceLoadError(placeId, "InAppStory SDK is not initialized")
            return
        }
        emit(ReloadBannerPlace, placeId)
    }

    override fun preloadBannerPlace(placeId: String) {
        if (!isSdkInitialized) {
            Log.w("InAppStory", "preloadBannerPlace called before initWith")
            emitBannerPlacePreloadError(placeId)
            return
        }
        emit(PreloadBannerPlace, placeId)
    }

    override fun showNext(placeId: String) {
        if (!isSdkInitialized) {
            Log.w("InAppStory", "showNext called before initWith")
            return
        }
        emit(ShowNext, placeId)
    }

    override fun showPrevious(placeId: String) {
        if (!isSdkInitialized) {
            Log.w("InAppStory", "showPrevious called before initWith")
            return
        }
        emit(ShowPrevious, placeId)
    }

    override fun showByIndex(placeId: String, index: Long) {
        if (!isSdkInitialized) {
            Log.w("InAppStory", "showByIndex called before initWith")
            return
        }
        emit(ShowByIndex, ShowByIndexPayload(placeId, index))
    }

    override fun pauseAutoscroll(placeId: String) {
        if (!isSdkInitialized) {
            Log.w("InAppStory", "pauseAutoscroll called before initWith")
            return
        }
        emit(PauseAutoscroll, placeId)
    }

    override fun resumeAutoscroll(placeId: String) {
        if (!isSdkInitialized) {
            Log.w("InAppStory", "resumeAutoscroll called before initWith")
            return
        }
        emit(ResumeAutoscroll, placeId)
    }

    override fun setInteraction(placeId: String, isInteractionEnabled: Boolean) {
        if (!isSdkInitialized) {
            Log.w("InAppStory", "setInteraction called before initWith")
            return
        }
        emit(SetInteraction, SetInteractionPayload(placeId, isInteractionEnabled))
    }

    fun emitBannerPlaceLoadError(placeId: String?, message: String) {
        emit(BannerPlaceLoadError, BannerPlaceLoadErrorPayload(placeId, message))
    }

    fun emitBannerPlacePreloadError(placeId: String) {
        emit(BannerPlacePreloadError, placeId)
    }
}

object LoadBannerPlace : EventKey<String>
object ReloadBannerPlace : EventKey<String>
object PreloadBannerPlace : EventKey<String>
object ShowNext : EventKey<String>
object ShowPrevious : EventKey<String>
data class ShowByIndexPayload(val placeId: String, val index: Long)
object ShowByIndex : EventKey<ShowByIndexPayload>
object PauseAutoscroll : EventKey<String>
object ResumeAutoscroll : EventKey<String>
data class SetInteractionPayload(val placeId: String, val isInteractionEnabled: Boolean)
object SetInteraction : EventKey<SetInteractionPayload>
data class BannerPlaceLoadErrorPayload(val placeId: String?, val message: String)
object BannerPlaceLoadError : EventKey<BannerPlaceLoadErrorPayload>
object BannerPlacePreloadError : EventKey<String>