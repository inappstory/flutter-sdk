package com.inappstory.inappstory_plugin.adaptors

import BannerPlaceManagerHostApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

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
        ConcurrentHashMap<EventKey<*>, ConcurrentHashMap<Token, (Any) -> Unit>>()

    private val tokenToKey = ConcurrentHashMap<Token, EventKey<*>>()


    init {
        BannerPlaceManagerHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    fun <P : Any> subscribe(key: EventKey<P>, callback: (P) -> Unit): Subscription {
        val id = UUID.randomUUID()
        val anyCallback: (Any) -> Unit = { payload ->
            try {
                @Suppress("UNCHECKED_CAST")
                callback(payload as P)
            } catch (e: ClassCastException) {
                // payload другого типа — игнорируем
            } catch (e: Throwable) {
                // Не даём падать эмиттеру
            }
        }
        val map = subscribers.computeIfAbsent(key) { ConcurrentHashMap() }
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

    fun <P : Any> emit(key: EventKey<P>, payload: P) {
        val map = subscribers[key] ?: return
        // Делать snapshot, чтобы подписчики не мешали друг другу при изменении в процессе уведомления
        val callbacks = ArrayList<(Any) -> Unit>(map.values)
        for (cb in callbacks) {
            try {
                cb(payload as Any)
            } catch (e: Throwable) {
                // Игнорируем исключения от слушателей, чтобы другие получили событие
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
        emit(LoadBannerPlace, placeId)
    }

    override fun preloadBannerPlace(placeId: String) {
        emit(PreloadBannerPlace, placeId)
    }

    override fun showNext(placeId: String) {
        emit(ShowNext, placeId)
    }

    override fun showPrevious(placeId: String) {
        emit(ShowPrevious, placeId)
    }

    override fun showByIndex(placeId: String, index: Long) {
        emit(ShowByIndex, ShowByIndexPayload(placeId, index))
    }

    override fun pauseAutoscroll(placeId: String) {
        emit(PauseAutoscroll, placeId)
    }

    override fun resumeAutoscroll(placeId: String) {
        emit(ResumeAutoscroll, placeId)
    }
}

object LoadBannerPlace : EventKey<String>
object PreloadBannerPlace : EventKey<String>
object ShowNext : EventKey<String>
object ShowPrevious : EventKey<String>
data class ShowByIndexPayload(val placeId: String, val index: Long)
object ShowByIndex : EventKey<ShowByIndexPayload>
object PauseAutoscroll : EventKey<String>
object ResumeAutoscroll : EventKey<String>