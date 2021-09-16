import SwiftUI

public class ResizableSheetModel: ObservableObject {

    public private(set) var contentOffSet: CGFloat = .zero
    public var mainSize: CGSize = .zero
    public var midiumSize: CGSize = .zero
    public var fullSize: CGSize = .zero
    public var percent: CGFloat = .zero
    public var lastState: ResizableSheetState = .hidden
    
    public var config: AnyResizableSheetConfiguration = AnyResizableSheetConfiguration(config: DefaultResizableSheetConfiguration())

    public var updateState: (ResizableSheetState) -> () = { _ in }

    private var timer: Timer?

    func setFullSize(_ size: CGSize) -> CGSize {
        if fullSize != size && !size.height.isZero && !size.width.isZero {
            fullSize = size
        }
        return size
    }

    func offset(for state: ResizableSheetState, in size: CGSize) -> CGFloat {
        if lastState != state {
            self.lastState = state
        }
        if fullSize != size {
            fullSize = size
        }

        return currentAnchor - contentOffSet
    }

    var currentAnchor: CGFloat {
        lastState == .hidden ? fullSize.height :
            lastState == .midium && midiumSize.height.isZero ? fullSize.height :
            lastState == .midium ? fullSize.height - midiumSize.height :
            .zero
    }

    public func finish(diff: CGFloat) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.updateOffSet(diff: diff)
            let next = self.config.nextState(context: .init(
                state: self.lastState,
                diffY: self.contentOffSet,
                percent: self.percent,
                mainViewSize: self.mainSize,
                fullViewSize: self.fullSize
            ))
            self.lastState = next
            self.contentOffSet = .zero
            self.percent = 0
            self.updateState(next)
            self.commit()
        }
    }

    public func updateOffSet(diff: CGFloat) {
        var diff = diff
        let size = fullSize

        switch (lastState, diff > 0) {
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
        switch lastState {
        case .large:
            if size.height == mainSize.height {
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
