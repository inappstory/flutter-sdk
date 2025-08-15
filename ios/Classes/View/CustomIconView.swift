import UIKit
import InAppStorySDK

class CustomIconView: UIView {
    var isHighlighted: Bool = false

    var isSelected: Bool = false
    var isEnabled: Bool = true

    fileprivate var unselectedImage: UIImage!
    fileprivate var selectedImage: UIImage?
    fileprivate var imageView: UIImageView!

    init(unselectedImage: UIImage, selectedImage: UIImage?) {
        self.unselectedImage = unselectedImage
        self.selectedImage = selectedImage

        super.init(frame: .zero)

        createUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomIconView {
    fileprivate func createUI() {
        let image: UIImage

        if let selectedImage {
            image = isSelected ? selectedImage : unselectedImage
        } else {
            image = unselectedImage
        }

        imageView = UIImageView()
        imageView.contentMode = .center
        imageView.image = image.imageFlippedForRightToLeftLayoutDirection()
        imageView.alpha = isEnabled ? 1 : 0.5
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive =
            true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            .isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            .isActive = true
    }
}

extension CustomIconView: IconViewProtocol {
    func update(state: IconViewState) {
        if let selectedImage {
            imageView.image = state.selected ? selectedImage : unselectedImage
        } else {
            imageView.image = unselectedImage
        }

        imageView.alpha = state.enabled ? 1 : 0.5
    }
}
