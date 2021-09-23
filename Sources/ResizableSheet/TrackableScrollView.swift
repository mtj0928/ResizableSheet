import SwiftUI

public struct ResizableScrollView<Main: View, Additional: View>: View {

    let showIndicators: Bool
    let context: ResizableSheetContext
    let additionalViewHeightForMedium: CGFloat
    let mainViewBuilder: () -> Main
    let additionalViewBuilder: () -> Additional

    @State var size: CGSize?

    public init(
        showIndicators: Bool = true,
        additionalViewHeightForMedium: CGFloat = .zero,
        context: ResizableSheetContext,
        @ViewBuilder main: @escaping () -> Main,
        @ViewBuilder additional: @escaping () -> Additional
    ) {
        self.showIndicators = showIndicators
        self.additionalViewHeightForMedium = additionalViewHeightForMedium
        self.context = context
        self.mainViewBuilder = main
        self.additionalViewBuilder = additional
    }

    public var body: some View {
        GeometryReader { proxy in
            TrackableScrollView(showIndicators: showIndicators) {
                VStack(spacing: 0) {
                    ChildSizeReader(
                        alignment: .top,
                        updateSize: { size in
                            self.size = size
                        },
                        content: {
                            VStack(spacing: 0) {
                                mainViewBuilder()
                            }
                        }
                    )
                    additionalViewBuilder()
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(minHeight: height)
    }

    var height: CGFloat? {
        guard let size = size else {
            return nil
        }
        return context.state != .large ? min(
            size.height + max(context.diffY, 0) + additionalViewHeightForMedium,
            context.fullViewSize.height
        ) : context.fullViewSize.height + context.diffY
    }
}

@available(iOS 14.0, *)
public struct TrackableScrollView<Content: View>: UIViewControllerRepresentable {

    let showIndicators: Bool
    let content: () -> Content
    @Environment(\.resizableSheetModel) var resizableSheetModel

    public init(
        showIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.showIndicators = showIndicators
        self.content = content
    }

    public func makeUIViewController(context: Context) -> TrackableScrollViewController<Content> {
        let viewController = TrackableScrollViewController<Content>()
        viewController.hosintgController.rootView = content()
        viewController.gestureHandler.resizableSheetModel = resizableSheetModel
        viewController.scrollView.showsVerticalScrollIndicator = showIndicators
        return viewController
    }

    public func updateUIViewController(_ viewController: TrackableScrollViewController<Content>, context: Context) {
        viewController.hosintgController.rootView = content()
    }
}

public class TrackableScrollViewController<Content: View>: UIViewController {

    let hosintgController = UIHostingController<Content?>(rootView: nil)
    let gestureHandler = ScrollViewGestureHandler()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupScrollView()
        setupHostingController()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)

        scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        scrollView.backgroundColor = .clear

        gestureHandler.setup(for: scrollView, in: view)
    }

    private func setupHostingController() {
        addChild(hosintgController)
        scrollView.addSubview(hosintgController.view)
        hosintgController.didMove(toParent: self)

        guard let view = hosintgController.view else { return }
        view.backgroundColor = .clear

        view.translatesAutoresizingMaskIntoConstraints = false

        scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        scrollView.contentInsetAdjustmentBehavior = .never
        view.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, constant: 1).isActive = true
    }
}
