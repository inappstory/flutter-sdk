package com.inappstory.inappstory_plugin.callbacks

import GameReaderCallbackFlutterApi
import com.inappstory.inappstory_plugin.mapContentDataDto
import com.inappstory.inappstory_plugin.runOnMainThread
import com.inappstory.sdk.stories.outercallbacks.common.gamereader.GameReaderCallback
import com.inappstory.sdk.stories.outercallbacks.common.reader.ContentData
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding


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
        flutterPluginBinding.runOnMainThread {
            flutterApi.finishGame(contentDataDto, null) {}
        }
    }

    override fun closeGame(contentData: ContentData?, id: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        flutterPluginBinding.runOnMainThread {
            flutterApi.closeGame(null) {}
        }
    }

    override fun eventGame(contentData: ContentData?, gameId: String?, eventName: String?, payload: String?) {
        val contentDataDto = contentData?.let { mapContentDataDto(it) }
        flutterPluginBinding.runOnMainThread {
            flutterApi.eventGame(contentDataDto, gameId, eventName, null) {}
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