import SwiftUI

public struct ResizableSheetConfiguration {

    public struct BackgroundView: View {
        var context: ResizableSheetContext
        @Environment(\.resizableSheetModel) var resizableSheetModel

        let color: Color
        let mediumOpacity = 0.4
        let fullOpacity = 0.9
        var diff: CGFloat {
            fullOpacity - mediumOpacity
        }

        var opacity: CGFloat {
            switch context.state {
            case .hidden: return 0.0
            case .medium: return context.progress >= 0 ? mediumOpacity + diff * Double(context.progress) : diff * Double(1 + context.progress)
            case .large: return fullOpacity + diff * Double(context.progress)
            }
        }

        public init(context: ResizableSheetContext, color: Color = Color.black) {
            self.context = context
            self.color = color
        }

        public var body: some View {
            color.opacity(opacity)
                .ignoresSafeArea()
                .onTapGesture {
                    resizableSheetModel!.updateState(.hidden)
                }
        }
    }

    public var cornerRadius: CGFloat = 40.0
    public var supportState: [ResizableSheetState] = [.hidden, .medium, .large]
    public var stateThreshold = 0.3

    var outsideViewBuilder: (ResizableSheetContext) -> AnyView = { _ in AnyView(EmptyView()) }

    var sheetBackgroundViewBuilder: (ResizableSheetContext) -> AnyView = { _ in AnyView(Color(.secondarySystemBackground)) }

    var backgroundViewBuilder: (ResizableSheetContext) -> AnyView = { AnyView(BackgroundView(context: $0, color: .black)) }

    var nextStateHandler: ((ResizableSheetContext) -> ResizableSheetState)?

    var animation: Animation = .easeOut

    public init() {}

    public func outside(_ context: ResizableSheetContext) -> some View {
        outsideViewBuilder(context)
    }

    public func sheetBackground(_ context: ResizableSheetContext) -> some View {
        sheetBackgroundViewBuilder(context)
    }

    public func background(_ context: ResizableSheetContext) -> some View {
        backgroundViewBuilder(context)
    }

    public func nextState(context: ResizableSheetContext) -> ResizableSheetState {
        nextStateHandler?(context) ?? _nextState(context: context)
    }

    private func _nextState(context: ResizableSheetContext) -> ResizableSheetState {
        let progress = context.progress
        switch context.state {
        case .hidden:
            guard progress > stateThreshold else { return .hidden }
            return supportState.contains(.medium) ? .medium :
            supportState.contains(.large) ? .large : .hidden
        case .medium:
            if progress > stateThreshold {
                return supportState.contains(.large) ? .large : .medium
            } else if progress < -stateThreshold {
                return supportState.contains(.hidden) ? .hidden : .medium
            }
        case .large:
            if supportState.contains(.medium)
                && context.mediumViewSize.height != context.fullViewSize.height {
                let progress = context.diffY / (context.fullViewSize.height - context.mediumViewSize.height)
                if progress < -stateThreshold {
                    return .medium
                }
            } else if supportState.contains(.hidden) {
                let progress = context.diffY / context.mainViewSize.height
                if progress < -stateThreshold {
                    return .hidden
                }
            }
        }
        return context.state
    }
}
