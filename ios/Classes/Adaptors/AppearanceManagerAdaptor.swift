import Flutter
import Foundation
@_spi(IAS_API) import InAppStorySDK

class AppearanceManagerAdaptor: AppearanceManagerHostApi {
    private var binaryMessenger: FlutterBinaryMessenger

    private var pluginRegistrar: FlutterPluginRegistrar

    private var panelSettings: PanelSettings

    init(
        binaryMessenger: FlutterBinaryMessenger,
        pluginRegistrar: FlutterPluginRegistrar
    ) {
        self.binaryMessenger = binaryMessenger

        self.pluginRegistrar = pluginRegistrar

        self.panelSettings = PanelSettings()

        AppearanceManagerHostApiSetup.setUp(
            binaryMessenger: binaryMessenger,
            api: self
        )
    }

    func setReaderBackgroundColor(color: Int64) throws {
        InAppStory.shared.readerBackgroundColor = uiColorFromInt64(
            hexValue: color
        )
    }

    func setReaderCornerRadius(radius: Int64) throws {
        InAppStory.shared.readerCornerRadius = CGFloat(radius)
    }

    func setCoverQuality(coverQuality: CoverQuality) throws {
        DispatchQueue.main.async {
            switch coverQuality {
            case CoverQuality.medium:
                InAppStory.shared.coverQuality = .medium
            case CoverQuality.high:
                InAppStory.shared.coverQuality = .high
            default:
                InAppStory.shared.coverQuality = .medium
            }
        }
    }

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
        let newPosition: ClosePosition = {
            switch position {
            case .topLeft:
                return .leading
            case .topRight:
                return .trailing
            case .bottomLeft:
                return .leadingBottom
            case .bottomRight:
                return .trailingBottom
            default:
                return .leading
            }
        }()

        InAppStory.shared.closeButtonPosition = newPosition
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

    func setLikeIcon(iconPath: String, selectedIconPath: String) throws {
        let likeImage = getUIImage(path: iconPath)

        let likeSelectedImage = getUIImage(path: selectedIconPath)

        if likeImage != nil && likeSelectedImage != nil {
            InAppStory.shared.likeIconView = {
                CustomIconView(
                    unselectedImage: likeImage!,
                    selectedImage: likeSelectedImage!
                )
            }
        }
    }

    func setSoundIcon(iconPath: String, selectedIconPath: String) throws {
        let soundImage = getUIImage(path: iconPath)

        let soundSelectedImage = getUIImage(path: selectedIconPath)

        if soundImage != nil && soundSelectedImage != nil {
            InAppStory.shared.soundIconView = {
                CustomIconView(
                    unselectedImage: soundImage!,
                    selectedImage: soundSelectedImage!
                )
            }
        }
    }

    func setDislikeIcon(iconPath: String, selectedIconPath: String) throws {
        let dislikeImage = getUIImage(path: iconPath)

        let dislikeSelectedImage = getUIImage(path: selectedIconPath)

        if dislikeImage != nil && dislikeSelectedImage != nil {
            InAppStory.shared.dislikeIconView = {
                CustomIconView(
                    unselectedImage: dislikeImage!,
                    selectedImage: dislikeSelectedImage!
                )
            }
        }
    }

    func setFavoriteIcon(iconPath: String, selectedIconPath: String) throws {
        let favoriteImage = getUIImage(path: iconPath)

        let favoriteSelectedImag = getUIImage(path: selectedIconPath)

        if favoriteImage != nil && favoriteSelectedImag != nil {
            InAppStory.shared.favoriteIconView = {
                CustomIconView(
                    unselectedImage: favoriteImage!,
                    selectedImage: favoriteSelectedImag!
                )
            }
        }
    }

    func setShareIcon(iconPath: String, selectedIconPath: String) throws {
        let shareImage = getUIImage(path: iconPath)

        let shareSelectedImage = getUIImage(path: selectedIconPath)

        if shareImage != nil && shareSelectedImage != nil {
            InAppStory.shared.shareIconView = {
                CustomIconView(
                    unselectedImage: shareImage!,
                    selectedImage: shareSelectedImage!
                )
            }
        }
    }

    func setCloseIcon(iconPath: String) throws {
        let image = getUIImage(path: iconPath)
        if image != nil {
            InAppStory.shared.closeReaderImage = image!
        }
    }

    func setRefreshIcon(iconPath: String) throws {
        let refreshImage = getUIImage(path: iconPath)
        if refreshImage != nil {
            InAppStory.shared.refreshIconView = {
                CustomIconView(
                    unselectedImage: refreshImage!,
                    selectedImage: refreshImage!
                )
            }
        }
    }

    func setUpGoods(appearance: GoodsItemAppearanceDto) throws {
        if appearance.itemMainTextColor != nil {
            InAppStory.shared.goodsCellMainTextColor = uiColorFromInt64(
                hexValue: appearance.itemMainTextColor!
            )
        }
        if appearance.itemOldPriceTextColor != nil {
            InAppStory.shared.goodsCellOldPriceTextColor = uiColorFromInt64(
                hexValue: appearance.itemOldPriceTextColor!
            )
        }
        if appearance.itemBackgroundColor != nil {
            InAppStory.shared.goodsSubstrateColor = uiColorFromInt64(
                hexValue: appearance.itemBackgroundColor!
            )
        }
        if appearance.itemTitleTextSize != nil {
            InAppStory.shared.goodCellTitleFont = UIFont.systemFont(
                ofSize: CGFloat(appearance.itemTitleTextSize!),
                weight: .medium
            )
        }
        if appearance.itemDescriptionTextSize != nil {
            InAppStory.shared.goodCellSubtitleFont = UIFont.systemFont(
                ofSize: CGFloat(appearance.itemDescriptionTextSize!)
            )
        }
        if appearance.itemPriceTextSize != nil {
            InAppStory.shared.goodCellPriceFont = UIFont.systemFont(
                ofSize: CGFloat(appearance.itemPriceTextSize!),
                weight: .medium
            )
        }
        if appearance.itemOldPriceTextSize != nil {
            InAppStory.shared.goodCellOldPriceFont = UIFont.systemFont(
                ofSize: CGFloat(appearance.itemOldPriceTextSize!),
                weight: .medium
            )
        }
    }

    private func getUIImage(path: String) -> UIImage? {
        let key = self.pluginRegistrar.lookupKey(forAsset: path)
        let path = Bundle.main.path(forResource: key, ofType: nil)

        if path == nil {
            print("File path not exists: \(path)")
            return nil
        }

        let image = UIImage(contentsOfFile: path!)
        if image == nil {
            return nil
        }

        return image
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
