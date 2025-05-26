import Flutter
import Foundation
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK

class IASStatisticsManagerAdaptor: InAppStoryStatManagerHostApi {
    init(binaryMessenger: FlutterBinaryMessenger) {
        InAppStoryStatManagerHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }

    func sendStatistics(enabled: Bool) throws {
        InAppStory.shared.isStatisticDisabled = !enabled
    }
}
