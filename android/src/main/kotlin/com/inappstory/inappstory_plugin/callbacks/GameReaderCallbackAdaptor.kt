package com.inappstory.inappstory_plugin.callbacks

import GameReaderCallbackFlutterApi
import com.inappstory.inappstory_plugin.mapContentDataDto
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.stories.outercallbacks.common.gamereader.GameReaderCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.ContentData
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.longOrNull

class GameReaderCallbackAdaptor(private val flutterPluginBinding: FlutterPluginBinding) :
    GameReaderCallback {

    private val flutterApi = GameReaderCallbackFlutterApi(flutterPluginBinding.binaryMessenger)


    override fun startGame(contentData: ContentData?, id: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        flutterPluginBinding.runOnMainThread {
            flutterApi.startGame(contentDataDto) { }
        }
    }

    // deprecated callback
    override fun finishGame(contentData: ContentData?, result: String?, id: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        val jsonObject: JsonObject? = result?.let { Json.parseToJsonElement(it).jsonObject }

        val map: Map<String, Any?>? = jsonObject?.toMap()

        flutterPluginBinding.runOnMainThread {
            flutterApi.finishGame(contentDataDto, map) {}
        }
    }

    override fun closeGame(contentData: ContentData?, id: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        flutterPluginBinding.runOnMainThread {
            flutterApi.closeGame(contentDataDto) {}
        }
    }

    override fun eventGame(
        contentData: ContentData?,
        gameId: String?,
        eventName: String?,
        payload: String?
    ) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        val jsonObject: JsonObject? = payload?.let { Json.parseToJsonElement(it).jsonObject }

        val map: Map<String, Any?>? = jsonObject?.toMap()

        flutterPluginBinding.runOnMainThread {
            flutterApi.eventGame(contentDataDto, gameId, eventName, map) {}
        }
    }

    override fun gameLoadError(contentData: ContentData?, id: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        flutterPluginBinding.runOnMainThread {
            flutterApi.gameError(contentDataDto, null) {}
        }
    }

    override fun gameOpenError(contentData: ContentData?, id: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        flutterPluginBinding.runOnMainThread {
            flutterApi.gameError(contentDataDto, null) {}
        }
    }
}

fun JsonObject.toMap(): Map<String, Any?> {
    return this.mapValues { it.value.toRaw() }
}

fun JsonElement.toRaw(): Any? {
    return when (this) {
        is JsonNull -> null
        is JsonObject -> this.toMap()
        is JsonArray -> this.map { it.toRaw() }
        is JsonPrimitive -> {
            if (isString) {
                content
            } else {
                booleanOrNull
                    ?: longOrNull
                    ?: doubleOrNull
                    ?: content
            }
        }
    }
}