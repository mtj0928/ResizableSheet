import SwiftUI

public struct ResizableSheetBuilder: Identifiable {

    // imutable
    public let model: ResizableSheetModel
    public let id: String
    let state: Binding<ResizableSheetState>

    // mutable
    var config: ResizableSheetConfiguration
    var mainViewBuilder: (ResizableSheetContext) -> AnyView

    public init<MainView: View>(
        id: String,
        config: ResizableSheetConfiguration,
        state: Binding<ResizableSheetState>,
        model: ResizableSheetModel,
        @ViewBuilder context viewBuilder: @escaping (ResizableSheetContext) -> MainView
    ) {
        self.id = id
        self.config = config
        self.state = state
        self.model = model
        self.mainViewBuilder = { AnyView(viewBuilder($0)) }
    }
}

extension ResizableSheetBuilder {

    public func content<Contents: View>(_ viewBuilder: @escaping (ResizableSheetContext) -> Contents) -> Self {
        var builder = self
        builder.mainViewBuilder = { AnyView(viewBuilder($0)) }
        return builder
    }

    public func cornerRadius(_ radius: CGFloat) -> Self {
        var builder = self
        builder.config.cornerRadius = radius
        return builder
    }

    public func supportedState(_ states: [ResizableSheetState]) -> Self {
        var builder = self
        builder.config.supportState = states
        return builder
    }

    public func outside<Outside: View>(_ outsideBuilder: @escaping (ResizableSheetContext) -> Outside) -> Self {
        var builder = self
        builder.config.outsideViewBuilder = { AnyView(outsideBuilder($0)) }
        return builder
    }

    public func sheetBackground<SheetBackground: View>(_ sheetBackgroundBuilder: @escaping (ResizableSheetContext) -> SheetBackground) -> Self {
        var builder = self
        builder.config.sheetBackgroundViewBuilder = { AnyView(sheetBackgroundBuilder($0)) }
        return builder
    }

    public func background<Background: View>(_ backgroundBuilder: @escaping (ResizableSheetContext) -> Background) -> Self {
        var builder = self
        builder.config.backgroundViewBuilder = { AnyView(backgroundBuilder($0)) }
        return builder
    }

    public func nextState(_ handler: @escaping (ResizableSheetContext) -> ResizableSheetState) -> Self  {
        var builder = self
        builder.config.nextStateHandler = handler
        return builder
    }

    public func stateThreshold(_ threshold: Double) -> Self {
        var builder = self
        builder.config.stateThreshold = threshold
        return builder
    }

    public func animation(_ animation: Animation) -> Self {
        var builder = self
        builder.config.animation = animation
        return builder
    }
}
