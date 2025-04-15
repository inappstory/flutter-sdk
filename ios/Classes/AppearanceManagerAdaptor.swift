import Flutter
import Foundation
@_spi(IAS_API) import InAppStorySDK

class AppearanceManagerAdaptor: AppearanceManagerHostApi {
    func setReaderBackgroundColor(color: Int64) throws {
        InAppStory.shared.readerBackgroundColor = uiColorFromInt64(
            hexValue: color
        )
    }

    func setReaderCornerRadius(radius: Int64) throws {
        InAppStory.shared.readerCornerRadius = CGFloat(radius)
    }

    init(binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger

        self.panelSettings = PanelSettings()

        AppearanceManagerHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }

    private var binaryMessenger: FlutterBinaryMessenger

    private var panelSettings: PanelSettings

    func setHasLike(value: Bool) throws {
        panelSettings.like = value
        InAppStory.shared.panelSettings = panelSettings
    }

    func setHasFavorites(value: Bool) throws {
        panelSettings.favorites = value
        InAppStory.shared.panelSettings = panelSettings
    }

    func setHasShare(value: Bool) throws {
        panelSettings.share = value
        InAppStory.shared.panelSettings = panelSettings
    }

    func setClosePosition(position: Position) throws {
        InAppStory.shared.closeButtonPosition = ClosePosition.init(
            rawValue: position.rawValue
        )!
    }

    func setTimerGradientEnable(isEnabled: Bool) throws {
        InAppStory.shared.timerGradientEnable = isEnabled
    }

    func getTimerGradientEnable() throws -> Bool {
        return InAppStory.shared.timerGradientEnable
    }

    func setTimerGradient(colors: [Int64], locations: [Double]) throws {
        let colors = colors.map(uiColorFromInt64)

        func mapLocations() -> [Double] {
            if !locations.isEmpty && locations.count == colors.count {
                return locations
            }

            return [0, 1]
        }

        let start = CGPoint(x: 0.5, y: 0.0)
        let end = CGPoint(x: 0.5, y: 1.0)

        InAppStory.shared.timerGradient = InAppStorySDK.TimersGradient(
            colors: colors,
            startPoint: start,
            endPoint: end,
            locations: mapLocations()
        )
    }

    private func uiColorFromInt64(hexValue: Int64) -> UIColor {
        return uiColorFromHex(hexValue: Int(truncatingIfNeeded: hexValue))
    }

    private func uiColorFromHex(hexValue: Int) -> UIColor {
        let red = CGFloat((hexValue & 0x00FF_0000) >> 16) / 0xFF
        let green = CGFloat((hexValue & 0x0000_FF00) >> 8) / 0xFF
        let blue = CGFloat(hexValue & 0x0000_00FF) / 0xFF
        let alpha = CGFloat((hexValue & 0xFF00_0000) >> 24) / 0xFF

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
