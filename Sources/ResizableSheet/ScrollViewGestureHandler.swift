import UIKit

public class ScrollViewGestureHandler: NSObject, UIGestureRecognizerDelegate {

    public weak var resizableSheetModel: ResizableSheetModel?

    private weak var view: UIView?
    private weak var scrollView: UIScrollView?

    var startOffset: CGFloat =  .zero

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
            startOffset = scrollView.contentOffset.y
        case .changed:
            let diff = gesture.translation(in: view)
            if resizableSheetModel?.state != .large
                || scrollView.contentOffset.y < 0
                || state == .changed {
                state = .changed
                resizableSheetModel?.updateOffSet(diff: -diff.y + startOffset)
                resizableSheetModel?.commit()
                scrollView.contentOffset.y = 0
                scrollView.isScrollEnabled = false
            } else {
                scrollView.isScrollEnabled = true
            }
        case .cancelled: finish()
        case .ended:
            let diff = gesture.translation(in: view)
            if state == .changed {
                resizableSheetModel?.finish(diff: -diff.y + startOffset)
                state = .standby
            }
            finish()
        case .failed: finish()
        default: break
        }
    }

    private func finish() {
        scrollView?.isScrollEnabled = true
        startOffset = .zero
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        gestureRecognizer.view == otherGestureRecognizer.view
    }
}
