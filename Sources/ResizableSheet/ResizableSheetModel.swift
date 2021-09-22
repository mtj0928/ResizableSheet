import SwiftUI

public class ResizableSheetModel: ObservableObject {

    public internal(set) var contentOffSet: CGFloat = .zero
    public internal(set) var mainSize: CGSize = .zero
    public internal(set) var mediumSize: CGSize = .zero
    public internal(set) var fullSize: CGSize = .zero
    public internal(set) var progress: CGFloat = .zero
    public internal(set) var state: ResizableSheetState
    
    public internal(set) var config: ResizableSheetConfiguration = ResizableSheetConfiguration()

    public internal(set) var updateState: (ResizableSheetState) -> () = { _ in }

    private static let dispatchQue = DispatchQueue(label: "ResizableSheet")

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
            state == .medium && mediumSize.height.isZero ? fullSize.height :
            state == .medium ? fullSize.height - mediumSize.height :
            .zero
    }

    public func finish(diff: CGFloat) {
        Self.dispatchQue.async { [weak self] in
            Thread.sleep(forTimeInterval: 0.01)
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateOffSet(diff: diff)
                let next = self.config.nextState(context: .init(
                    state: self.state,
                    diffY: self.contentOffSet,
                    progress: self.progress,
                    mainViewSize: self.mainSize,
                    fullViewSize: self.fullSize
                ))
                self.state = next
                self.updateState(next)
                self.contentOffSet = .zero
                self.progress = 0
                self.commit()
            }
        }
    }

    public func updateOffSet(diff: CGFloat) {
        var diff = diff
        let size = fullSize

        switch (state, diff > 0) {
        case (.hidden, _): break
        case (.medium, true):
            if !config.supportState.contains(.large) {
                diff = diff / 5
            }
        case (.medium, false):
            if !config.supportState.contains(.hidden) {
                diff = diff / 5
            }
        case (.large, _):
            if !config.supportState.contains(.medium)
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

        // update progress
        switch state {
        case .large:
            if !mediumSize.height.isZero {
                progress = contentOffSet / (size.height - mediumSize.height)
            } else if size.height == mainSize.height {
                progress = contentOffSet / size.height
            } else {
                progress = contentOffSet / (size.height - mainSize.height)
            }
        case .medium:
            if diff >= 0 {
                if size.height == mainSize.height {
                    progress = contentOffSet / size.height
                } else {
                    progress = contentOffSet / (size.height - mainSize.height)
                }
            } else {
                progress = contentOffSet / mediumSize.height
            }
        case .hidden: break
        }
    }

    public func commit() {
        objectWillChange.send()
    }
}
