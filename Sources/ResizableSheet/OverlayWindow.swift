import SwiftUI

class OverlayWindow: UIWindow {

    weak var ignoreView: UIView?

    init(ignoreView: UIView?) {
        self.ignoreView = ignoreView

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        return view == ignoreView ? nil : view
    }
}
