package com.inappstory.inappstory_plugin.callbacks

import GameReaderCallbackFlutterApi
import com.inappstory.inappstory_plugin.mapContentDataDto
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.stories.outercallbacks.common.gamereader.GameReaderCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.ContentData
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import kotlinx.serialization.json.Json
import kotlinx.serialization.builtins.MapSerializer
import kotlinx.serialization.builtins.serializer

class GameReaderCallbackAdaptor(private val flutterPluginBinding: FlutterPluginBinding) : GameReaderCallback {

    private val flutterApi = GameReaderCallbackFlutterApi(flutterPluginBinding.binaryMessenger)


    override fun startGame(contentData: ContentData?, id: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        flutterPluginBinding.runOnMainThread {
            flutterApi.startGame(contentDataDto) { }
        }
    }

    override fun finishGame(contentData: ContentData?, result: String?, id: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        val mapOfString: Map<String?, Any?>? = result?.let { Json.decodeFromString(it) }
        flutterPluginBinding.runOnMainThread {
            flutterApi.finishGame(contentDataDto, mapOfString) {}
        }
    }

    override fun closeGame(contentData: ContentData?, id: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        flutterPluginBinding.runOnMainThread {
            flutterApi.closeGame(contentDataDto) {}
        }
    }

    override fun eventGame(contentData: ContentData?, gameId: String?, eventName: String?, payload: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        val mapOfString: Map<String?, Any?>? = payload?.let { Json.decodeFromString(it) }

        flutterPluginBinding.runOnMainThread {
            print(payload)
            flutterApi.eventGame(contentDataDto, gameId, eventName, mapOfString) {}
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