import SwiftUI

public struct ResizableSheetContext {
    public let state: ResizableSheetState
    public let diffY: CGFloat
    public let progress: CGFloat
    public let mainViewSize: CGSize
    public let fullViewSize: CGSize
}

public struct ResizableSheet: View, Identifiable {

    public static let defaultId = "default"

    public let id: String
    let config: ResizableSheetConfiguration
    let mainViewBuilder: (ResizableSheetContext) -> AnyView

    @Binding var state: ResizableSheetState
    @ObservedObject var model: ResizableSheetModel

    var currentContext: ResizableSheetContext {
        ResizableSheetContext(
            state: state,
            diffY: model.contentOffSet,
            progress: model.progress,
            mainViewSize: model.mainSize,
            fullViewSize: model.fullSize
        )
    }

    public init<MainView: View>(
        id: String = Self.defaultId,
        state: Binding<ResizableSheetState>,
        model: ResizableSheetModel,
        config: ResizableSheetConfiguration,
        @ViewBuilder content mainViewBuilder: @escaping (ResizableSheetContext) -> MainView
    ) {
        self.id = id
        self.mainViewBuilder = { AnyView(mainViewBuilder($0)) }
        self.model = model
        self.config = config
        self._state = state
        self.model.state = state.wrappedValue
        model.config = self.config

        model.updateState = { [self] next in
            self.state = next
        }
    }

    public init<MainView: View>(
        id: String = Self.defaultId,
        state: Binding<ResizableSheetState>,
        model: ResizableSheetModel,
        @ViewBuilder content mainViewBuilder: @escaping (ResizableSheetContext) -> MainView
    ) {
        self.init(
            id: id,
            state: state,
            model: model,
            config: ResizableSheetConfiguration(),
            content: mainViewBuilder
        )
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                config.background(currentContext)
                    .frame(height: proxy.size.height)
                    .animation(config.animation)
                    .transition(.opacity)

                if model.fullSize != .zero {
                    VStack(spacing: 0) {
                        config.outside(currentContext)
                            .frame(height: model.offset(state: state, in: proxy.size))
                            .animation(config.animation)
                        Spacer(minLength: 0)
                    }

                    contentsView(in: proxy)
                        .frame(
                            width: proxy.size.width,
                            height: proxy.size.height
                        )
                        .background(
                            config.sheetBackground(currentContext)
                                .gesture(gesture)
                        )
                        .cornerRadius(config.cornerRadius, corners: [.topLeft, .topRight])
                        .offset(y: model.offset(state: state, in: proxy.size))
                        .animation(config.animation)
                }
            }
            .onAppear {
                model.fullSize = proxy.size
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .environment(\.resizableSheetModel, model)
    }

    var mainHeight: CGFloat? {
        model.contentOffSet.isZero ? nil :
        state == .medium ? max(model.mediumSize.height + model.contentOffSet, model.mediumSize.height) :
        state == .large ? max(model.fullSize.height + model.contentOffSet, model.mediumSize.height) :
        model.mainSize.height
    }

    func contentsView(in proxy: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            mainView
                .frame(height: mainHeight)

            Spacer(minLength: 0)
                .layoutPriority(state == .medium ? 1 : -1)
        }
    }

    @ViewBuilder
    var mainView: some View {
        ChildSizeReader(updateSize: { size in
            guard !size.height.isZero else { return }

            if model.contentOffSet.isZero {
                model.mainSize = size
            }

            if model.contentOffSet.isZero
                && state == .medium
                && model.mediumSize != size
                && model.fullSize.height != size.height // Workarround
            {
                model.mediumSize = size
                model.commit()
            }
        }) {
            VStack(spacing: 0) {
                mainViewBuilder(currentContext)
                Spacer(minLength: 0)
            }
        }
    }

    private var gesture: some Gesture {
        DragGesture(minimumDistance: .zero, coordinateSpace: .global)
            .onChanged({ value in
                let diff = value.startLocation.y - value.location.y
                model.updateOffSet(diff: diff)
                model.commit()
            })
            .onEnded({ value in
                let diff = value.startLocation.y - value.predictedEndLocation.y
                model.finish(diff: diff)
                model.commit()
            })
    }
}

struct ResizableSheet_Preview: PreviewProvider {

    struct Body<Content: View>: View {

        @State var state = ResizableSheetState.hidden

        var model: ResizableSheetModel!
        let content: (ResizableSheetContext, Binding<ResizableSheetState>) -> Content

        init(@ViewBuilder content: @escaping (ResizableSheetContext, Binding<ResizableSheetState>) -> Content) {
            self.content = content
            self.model = ResizableSheetModel(state: state)
        }

        var body: some View {
            NavigationView {
                ZStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 32) {
                            Text("\(state.rawValue)")
                            Button("Hidden", action: {
                                state = .hidden
                            })
                            Button("Medium", action: {
                                state = .medium
                            })
                            Button("Large", action: {
                                state = .large
                            })
                            Spacer()
                        }
                        Spacer()
                    }
                    .resizableSheet($state) { builder in
                        builder.content { context in
                            ResizableScrollView(
                                additionalViewHeightForMedium: 44,
                                context: context,
                                main: {
                                    ForEach(0..<3) { index in
                                        Text("\(index)")
                                            .padding()
                                    }
                                },
                                additional: {
                                    ForEach(5..<19) { index in
                                        Text("\(index)")
                                            .padding()
                                    }
                                }
                            ).overlay(VStack{
                                GrabBar()
                                Spacer()
                            })
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Hoge")
            }
        }
    }

    static var previews: some View {
        ResizableSheetPreview {
            Body { context, state in
                EmptyView()
            }
        }
    }
}
