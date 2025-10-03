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
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let gradientLayer = CAGradientLayer()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .blue

        // Добавляем элементы на view
        addSubview(titleLabel)
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.blue.cgColor,
            UIColor.green.cgColor,
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)  // Слева
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)  // Справа
        gradientLayer.cornerRadius = 12.0  // Закругленные углы, если нужно

        layer.addSublayer(gradientLayer)
        // Устанавливаем констрейнты
//        NSLayoutConstraint.activate([
//            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
//            titleLabel.topAnchor.constraint(
//                equalTo: activityIndicator.bottomAnchor,
//                constant: 8
//            ),
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
//        ])
    }

    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        // Этот метод вызывается при изменении размера view.
        // Здесь можно выполнить кастомную расстановку элементов, если AutoLayout недостаточно.
        //layer.cornerRadius = min(bounds.width, bounds.height) / 10  // Пример кастомизации:cite[5]
        gradientLayer.frame = bounds
    }
}
