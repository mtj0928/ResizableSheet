import SwiftUI

public struct ResizableSheetContext {
    public let state: ResizableSheetState
    public let diffY: CGFloat
    public let percent: CGFloat
    public let mainViewSize: CGSize
    public let fullViewSize: CGSize
}

public struct ResizableSheet: View, Identifiable {

    public static let defaultId = "default"

    public let id: String

    let config: AnyResizableSheetConfiguration
    let mainViewBuilder: (ResizableSheetContext) -> AnyView

    @StateObject var model = ResizableSheetModel()
    @Binding var state: ResizableSheetState

    var currentContext: ResizableSheetContext {
        ResizableSheetContext(
            state: model.lastState,
            diffY: model.contentOffSet,
            percent: model.percent,
            mainViewSize: model.mainSize,
            fullViewSize: model.fullSize
        )
    }

    public init<MainView: View>(
        id: String = Self.defaultId,
        state: Binding<ResizableSheetState>,
        @ViewBuilder content mainViewBuilder: @escaping (ResizableSheetContext) -> MainView
    ) {
        self.id = id
        self.mainViewBuilder = { AnyView(mainViewBuilder($0)) }
        self._state = state
        self.config = AnyResizableSheetConfiguration(config: DefaultResizableSheetConfiguration())
    }

    public init<
        MainView: View,
        Configuration: ResizableSheetConfiguration
    >(
        id: String = Self.defaultId,
        state: Binding<ResizableSheetState>,
        config: Configuration,
        @ViewBuilder content mainViewBuilder: @escaping (ResizableSheetContext) -> MainView
    ) {
        self.id = id
        self.mainViewBuilder = { AnyView(mainViewBuilder($0)) }
        self._state = state
        self.config = AnyResizableSheetConfiguration(config: config)
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                config.background(.init(
                    state: state,
                    diffY: model.contentOffSet,
                    percent: model.percent,
                    mainViewSize: model.mainSize,
                    fullViewSize: model.fullSize
                ))
                    .frame(height: model.setFullSize(proxy.size).height)
                    .animation(.easeOut)
                    .transition(.opacity)

                if model.fullSize != .zero {
                    VStack(spacing: 0) {
                        config.outside(.init(
                            state: state,
                            diffY: model.contentOffSet,
                            percent: model.percent,
                            mainViewSize: model.mainSize,
                            fullViewSize: model.fullSize
                        ))
                            .frame(height: model.offset(for: state, in: proxy.size))
                            .animation(.easeOut)
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
                        .offset(y: model.offset(for: state, in: proxy.size))
                        .transition(.move(edge: .bottom))
                        .animation(.easeOut)
                }
            }
            .onAppear {
                model.config = config
                model.lastState = state
                model.updateState = { (nextState: ResizableSheetState) in
                    state = nextState
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .environment(\.resizableSheetModel, model)
    }

    var mainHeight: CGFloat? {
        model.contentOffSet.isZero ? nil :
        state == .midium ? max(model.midiumSize.height + model.contentOffSet, model.midiumSize.height) :
        state == .large ? max(model.fullSize.height + model.contentOffSet, model.midiumSize.height) :
        model.mainSize.height
    }

    func contentsView(in proxy: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            mainView
                .frame(height: mainHeight)

            Spacer(minLength: 0)
                .layoutPriority(state == .midium ? 1 : -1)
        }
    }

    @ViewBuilder
    var mainView: some View {
        ChildSizeReader(updateSize: { size in
            guard !size.height.isZero else { return }

            if model.contentOffSet.isZero && model.mainSize != size {
                model.mainSize = size
            }

            if model.contentOffSet.isZero
                && state == .midium
                && model.midiumSize != size
                && model.fullSize.height != size.height // Workarround
            {
                model.midiumSize = size
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

        let content: (ResizableSheetContext, Binding<ResizableSheetState>) -> Content

        init(@ViewBuilder content: @escaping (ResizableSheetContext, Binding<ResizableSheetState>) -> Content) {
            self.content = content
        }

        var body: some View {
            NavigationView {
                ZStack {
                    HStack {
                        Spacer()
                        VStack(spacing: 32) {
                            Button("Hidden", action: {
                                state = .hidden
                            })
                            Button("Midium", action: {
                                state = .midium
                            })
                            Button("Large", action: {
                                state = .large
                            })
                            Spacer()
                        }
                        Spacer()
                    }
                    ResizableSheet(
                        id: "id",
                        state: $state,
                        config: DefaultResizableSheetConfiguration(),
                        content: { (context: ResizableSheetContext) in
                            content(context, $state)
                                .frame(width: context.fullViewSize.width)
                        }
                    )
                }
                .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Hoge")
            }
        }
    }

    static var previews: some View {
        Body { context, state in
            VStack(spacing: 0) {
                Text("利用規約が更新されました")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding()
                    .frame(height: 60)
                TrackableScrollView {
                    ForEach(0..<100) { index in
                        Text("\(index). 利用規約が更新されました")
                    }
                }.frame(
                    height: context.state == .midium ? 100 + max(context.diffY, 0) : context.state == .large ? nil : 100
                )
                if context.state != .hidden {
                    Spacer(minLength: 0)
                }
                Button("Botton") {
                    if state.wrappedValue == .large {
                        state.wrappedValue = .midium
                    } else if state.wrappedValue == .midium {
                        state.wrappedValue = .large
                    }
                }
                .font(.title3)
                .padding()
            }
            .frame(width: context.fullViewSize.width)
        }
    }
}
