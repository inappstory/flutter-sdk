import UIKit

/// A window above the entire app for displaying IAM.
/// Delegates hit-testing to `IAMPassthroughView`.
final class IAMOverlayWindow: UIWindow {

    /// The container where the SDK embeds IAM content.
    weak var passthroughView: IAMPassthroughView?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let passthrough = passthroughView else {
            return super.hitTest(point, with: event)
        }
        let localPoint = passthrough.convert(point, from: self)
        return passthrough.hitTest(localPoint, with: event)
    }
}

/// A view that hosts IAM content.
/// - When `isPassthroughEnabled` is true (toast), touches on empty space pass through to the main window below.
/// - When `isPassthroughEnabled` is false (all other IAM types), touches are intercepted and blocked by this window.
final class IAMPassthroughView: UIView {

    private var bottomConstraint: NSLayoutConstraint!

    /// When true, touches outside IAM subviews pass through to the window below (toast behavior).
    /// When false, touches outside IAM subviews are intercepted and blocked (modal behavior for popup, bottomsheet, fullscreen).
    var isPassthroughEnabled: Bool = true

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
        if hit === self {
            // Touch landed on the container itself (empty area / background).
            // For toast: pass through (return nil).
            // For all other IAM types: block touches/gestures (return self).
            return isPassthroughEnabled ? nil : self
        }
        return hit
    }
}
