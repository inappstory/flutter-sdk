import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class IASStatisticsManagerAdaptor: InAppStoryStatManagerHostApi {
    func sendStatistics(
        enabled: Bool,
        completion: @escaping (Result<Void, any Error>) -> Void
    ) {
        InAppStory.shared.isStatisticDisabled = !enabled

        completion(.success(()))
    }

    init(binaryMessenger: FlutterBinaryMessenger) {
        InAppStoryStatManagerHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }
}
