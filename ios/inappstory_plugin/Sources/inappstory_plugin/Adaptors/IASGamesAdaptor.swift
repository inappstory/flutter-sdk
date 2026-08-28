import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class IASGamesAdaptor: IASGamesHostApi {
    init(
        binaryMessenger: FlutterBinaryMessenger,
        gamesApi: InAppStorySDK.GamesAPI
    ) {
        self.binaryMessenger = binaryMessenger
        self.gamesApi = gamesApi

        IASGamesHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: self)
    }

    private var binaryMessenger: FlutterBinaryMessenger

    private var gamesApi: InAppStorySDK.GamesAPI

    func openGame(gameId: String) throws {

        gamesApi.openGame(with: Game(id: gameId)) { _ in }
    }

    func closeGame() throws {
        gamesApi.closeGame()
    }

    func preloadGames() throws {
        InAppStory.shared.preloadGames()
    }
}
