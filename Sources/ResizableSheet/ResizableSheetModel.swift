import SwiftUI

public class ResizableSheetModel: ObservableObject {

    public internal(set) var contentOffSet: CGFloat = .zero
    public internal(set) var mainSize: CGSize = .zero
    public internal(set) var midiumSize: CGSize = .zero
    public internal(set) var fullSize: CGSize = .zero
    public internal(set) var percent: CGFloat = .zero
    public internal(set) var state: ResizableSheetState
    
    public internal(set) var config: ResizableSheetConfiguration = ResizableSheetConfiguration()

    public internal(set) var updateState: (ResizableSheetState) -> () = { _ in }

    private var timer: Timer?

    public init(state: ResizableSheetState) {
        self.state = state
    }

    func offset(state: ResizableSheetState, in size: CGSize) -> CGFloat {
        if self.state != state {
            self.state = state
            commit()
        }

        if fullSize != size {
            fullSize = size
        }

        return currentAnchor - contentOffSet
    }

    var currentAnchor: CGFloat {
        state == .hidden ? fullSize.height :
            state == .midium && midiumSize.height.isZero ? fullSize.height :
            state == .midium ? fullSize.height - midiumSize.height :
            .zero
    }

    public func finish(diff: CGFloat) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.updateOffSet(diff: diff)
            let next = self.config.nextState(context: .init(
                state: self.state,
                diffY: self.contentOffSet,
                percent: self.percent,
                mainViewSize: self.mainSize,
                fullViewSize: self.fullSize
            ))
            self.state = next
            self.updateState(next)
            self.contentOffSet = .zero
            self.percent = 0
            self.commit()
        }
    }

    public func updateOffSet(diff: CGFloat) {
        var diff = diff
        let size = fullSize

        switch (state, diff > 0) {
        case (.hidden, _): break
        case (.midium, true):
            if !config.supportState.contains(.large) {
                diff = diff / 5
            }
        case (.midium, false):
            if !config.supportState.contains(.hidden) {
                diff = diff / 5
            }
        case (.large, _):
            if !config.supportState.contains(.midium)
                || !config.supportState.contains(.hidden) {
                diff = diff / 5
            }
        }

        // update offset
        if currentAnchor - diff < 0 {
            contentOffSet = currentAnchor
        } else {
            contentOffSet = diff
        }

        // update percentage
        switch state {
        case .large:
            if !midiumSize.height.isZero {
                percent = contentOffSet / (size.height - midiumSize.height)
            } else if size.height == mainSize.height {
                percent = contentOffSet / size.height
            } else {
                percent = contentOffSet / (size.height - mainSize.height)
            }
        case .midium:
            if diff >= 0 {
                if size.height == mainSize.height {
                    percent = contentOffSet / size.height
                } else {
                    percent = contentOffSet / (size.height - mainSize.height)
                }
            } else {
                percent = contentOffSet / midiumSize.height
            }
        case .hidden: break
        }
    }

    public func commit() {
        objectWillChange.send()
    }
}
