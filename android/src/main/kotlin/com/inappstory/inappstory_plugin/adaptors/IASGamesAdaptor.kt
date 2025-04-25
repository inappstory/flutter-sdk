package com.inappstory.inappstory_plugin.adaptors

import IASGamesHostApi
import com.inappstory.inappstory_plugin.callbacks.GameReaderCallbackAdaptor
import com.inappstory.sdk.core.api.IASGames
import io.flutter.embedding.engine.plugins.FlutterPlugin

class IASGamesAdaptor(
    private val flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
    private val iasGames: IASGames,
) : IASGamesHostApi {
    init {
        IASGamesHostApi.setUp(flutterPluginBinding.binaryMessenger, this)

        iasGames.callback(GameReaderCallbackAdaptor(flutterPluginBinding))
    }

    override fun openGame(gameId: String) {
        iasGames.open(flutterPluginBinding.applicationContext, gameId);
    }

    override fun closeGame() = iasGames.close()

    override fun preloadGames() {
        iasGames.preloadGames();
    }


}
