import UIKit

class IAMContainerView: UIView {

    private var bottomConstraint: NSLayoutConstraint!

    var bottomPadding: CGFloat {
        get { -bottomConstraint.constant }
        set { bottomConstraint.constant = -newValue }
    }

    func attach(to host: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(self)

        bottomConstraint = bottomAnchor.constraint(equalTo: host.bottomAnchor)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: host.topAnchor),
            leadingAnchor.constraint(equalTo: host.leadingAnchor),
            trailingAnchor.constraint(equalTo: host.trailingAnchor),
            bottomConstraint,
        ])
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit == self ? nil : hit
    }
}
