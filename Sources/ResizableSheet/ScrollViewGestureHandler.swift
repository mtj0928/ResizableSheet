import UIKit

public class ScrollViewGestureHandler: NSObject, UIGestureRecognizerDelegate {

    public weak var resizableSheetModel: ResizableSheetModel?

    private weak var view: UIView?
    private weak var scrollView: UIScrollView?

    private var startOffset: CGFloat?

    var state = State.standby

    enum State {
        case standby, changed
    }

    public func setup(for scrollView: UIScrollView, in view: UIView) {
        self.scrollView = scrollView
        self.view = view

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        scrollView.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let scrollView = scrollView else {
            return
        }

        switch gesture.state {
        case .began:
            self.startOffset = scrollView.contentOffset.y
        case .changed:
            let diff = gesture.translation(in: view)
            if resizableSheetModel?.state != .large
                || scrollView.contentOffset.y < 0
                || state == .changed {
                state = .changed
                resizableSheetModel?.updateOffSet(diff: -diff.y)
                resizableSheetModel?.commit()
                scrollView.contentOffset.y = startOffset ?? .zero
                scrollView.isScrollEnabled = false
            } else {
                scrollView.isScrollEnabled = true
            }
        case .cancelled: scrollView.isScrollEnabled = true
        case .ended:
            let diff = gesture.translation(in: view)
            if state == .changed {
                resizableSheetModel?.finish(diff: -diff.y)
                state = .standby
            }
            scrollView.isScrollEnabled = true
        case .failed: scrollView.isScrollEnabled = true
        default: break
        }
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
