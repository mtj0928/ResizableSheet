import SwiftUI

public protocol ResizableSheetConfiguration {

    associatedtype Outside: View
    associatedtype SheetBackground: View
    associatedtype Background: View

    var cornerRadius: CGFloat { get }
    var supportState: [ResizableSheetState] { get }

    func outside(_ context: ResizableSheetContext) -> Outside
    func sheetBackground(_ context: ResizableSheetContext) -> SheetBackground
    func background(_ context: ResizableSheetContext) -> Background
    func nextState(context: ResizableSheetContext) -> ResizableSheetState
}

public struct AnyResizableSheetConfiguration: ResizableSheetConfiguration {

    public let cornerRadius: CGFloat
    public let supportState: [ResizableSheetState]

    let outsideViewBuilder: (ResizableSheetContext) -> AnyView
    let sheetBackgroundViewBuilder: (ResizableSheetContext) -> AnyView
    let backgroundViewBuilder: (ResizableSheetContext) -> AnyView
    let nextStateHandler: (ResizableSheetContext) -> ResizableSheetState

    init<Configuration: ResizableSheetConfiguration>(config: Configuration) {
        self.cornerRadius = config.cornerRadius
        self.supportState = config.supportState

        self.outsideViewBuilder = { AnyView(config.outside($0)) }
        self.sheetBackgroundViewBuilder = { AnyView(config.sheetBackground($0)) }
        self.backgroundViewBuilder = { AnyView(config.background($0)) }
        self.nextStateHandler = { config.nextState(context: $0) }
    }

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
        nextStateHandler(context)
    }
}

public struct DefaultResizableSheetConfiguration: ResizableSheetConfiguration {

    public struct BackgroundView: View {
        var context: ResizableSheetContext
        @Environment(\.resizableSheetModel) var resizableSheetModel

        let color: Color
        let midiumOpacity = 0.4
        let fullOpacity = 0.9
        var diff: CGFloat {
            fullOpacity - midiumOpacity
        }

        var opacity: CGFloat {
            switch context.state {
            case .hidden: return 0.0
            case .midium: return context.percent >= 0 ? midiumOpacity + diff * Double(context.percent) : diff * Double(1 + context.percent)
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

    public let cornerRadius: CGFloat
    public let supportState: [ResizableSheetState]

    public init(
        cornerRadius: CGFloat = 40,
        supportState: [ResizableSheetState] = [.hidden, .midium, .large]
    ) {
        self.cornerRadius = cornerRadius
        self.supportState = supportState
    }

    public func outside(_ context: ResizableSheetContext) -> some View {
        EmptyView()
    }

    public func sheetBackground(_ context: ResizableSheetContext) -> some View {
        Color(.systemBackground)
    }

    public func background(_ context: ResizableSheetContext) -> some View {
        BackgroundView(context: context, color: .black)
    }

    public func nextState(context: ResizableSheetContext) -> ResizableSheetState {
        let percent = context.percent
        switch context.state {
        case .hidden:
            guard percent > 0.5 else { return .hidden }
            return supportState.contains(.midium) ? .midium :
            supportState.contains(.large) ? .large : .hidden
        case .midium:
            if percent > 0.5 {
                return supportState.contains(.large) ? .large : .midium
            } else if percent < -0.5 {
                return supportState.contains(.hidden) ? .hidden : .midium
            }
        case .large:
            if percent < -0.5 {
                return supportState.contains(.midium) ? .midium :
                supportState.contains(.hidden) ? .hidden : .large
            }
        }
        return context.state
    }
}
