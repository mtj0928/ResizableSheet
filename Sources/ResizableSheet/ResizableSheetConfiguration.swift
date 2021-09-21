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
            case .medium: return context.percent >= 0 ? mediumOpacity + diff * Double(context.percent) : diff * Double(1 + context.percent)
            case .large: return fullOpacity + diff * Double(context.percent)
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
        let percent = context.percent
        switch context.state {
        case .hidden:
            guard percent > stateThreshold else { return .hidden }
            return supportState.contains(.medium) ? .medium :
            supportState.contains(.large) ? .large : .hidden
        case .medium:
            if percent > stateThreshold {
                return supportState.contains(.large) ? .large : .medium
            } else if percent < -stateThreshold {
                return supportState.contains(.hidden) ? .hidden : .medium
            }
        case .large:
            if percent < -stateThreshold {
                return supportState.contains(.medium) ? .medium :
                supportState.contains(.hidden) ? .hidden : .large
            }
        }
        return context.state
    }
}
