import Flutter
@_spi(QAApp) import InAppStorySDK
@_spi(IAS_API) import InAppStorySDK
import UIKit

class CustomPlaceholderView: UIView, PlaceholderProtocol {
    var isAnimate: Bool {
        return false  // animation state value
    }

    func start() {
        // start animation
    }

    func stop() {
        // stop animation
    }

    private var _imageView: UIImageView?

    private weak var registrar: FlutterPluginRegistrar?

    private var color: Int64?
    private var image: String?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    public func setDecoration(
        color: Int64?,
        image: String?,
        registrar: FlutterPluginRegistrar
    ) {
        self.color = color
        self.image = image
        self.registrar = registrar
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        if let color {
            backgroundColor = uiColorFromInt64(hexValue: color)
        }
        if let image, let uiImage = getUIImage(path: image) {
            let imageView = UIImageView(image: uiImage)
            imageView.contentMode = .center
            imageView.image = uiImage.imageFlippedForRightToLeftLayoutDirection()
            imageView.translatesAutoresizingMaskIntoConstraints = false

            addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        }
    }

    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func getUIImage(path: String) -> UIImage? {
        if registrar == nil {
            return nil
        }
        let key = registrar?.lookupKey(forAsset: path)
        let path = Bundle.main.path(forResource: key, ofType: nil)

        if path == nil {
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