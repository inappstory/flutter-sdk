import Flutter
import Foundation
@_spi(IAS_API) import InAppStorySDK

class InAppStoryManagerAdaptor: InAppStoryManagerHostApi {
    init(binaryMessenger: FlutterBinaryMessenger) {
        InAppStoryManagerHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }

    func setPlaceholders(newPlaceholders: [String: String]) throws {
        InAppStory.shared.placeholders = newPlaceholders
    }

    func setTags(tags: [String]) throws {
        InAppStory.shared.settings?.tags = tags
        InAppStory.shared.setTags(tags)
    }

    func changeUser(
        userId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        InAppStory.shared.settings = Settings(userID: userId)

        completion(.success(()))
    }

    func closeReaders() throws {
        InAppStory.shared.closeReader {}
    }
    
    func clearCache() throws {
        InAppStory.shared.clearCache()
    }
    
    func setTransparentStatusBar() throws {
        // runs only in Android
    }
}
