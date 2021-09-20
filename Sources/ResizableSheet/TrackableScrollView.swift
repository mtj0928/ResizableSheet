import SwiftUI

public struct ResizableScrollView<Main: View, Additional: View>: View {

    let axes: Axis.Set
    let showIndicators: Bool
    let context: ResizableSheetContext
    let mainViewBuilder: () -> Main
    let additionalViewBuilder: () -> Additional

    @State var size: CGSize?

    public init(
        _ axes: Axis.Set = .vertical,
        showIndicators: Bool = true,
        context: ResizableSheetContext,
        @ViewBuilder main: @escaping () -> Main,
        @ViewBuilder additional: @escaping () -> Additional
    ) {
        self.axes = axes
        self.showIndicators = showIndicators
        self.context = context
        self.mainViewBuilder = main
        self.additionalViewBuilder = additional
    }

    public var body: some View {
        TrackableScrollView(axes, showIndicators: showIndicators) {
            ChildSizeReader(alignment: .top, updateSize: { size in
                self.size = size
            }, content: {
                VStack(spacing: 0) {
                    mainViewBuilder()
                }
            })
            additionalViewBuilder()
        }
        .frame(height: height != nil ? min(height!, context.fullViewSize.height) : nil, alignment: .top)
    }

    var height: CGFloat? {
        guard let size = size else {
            return nil
        }
        return context.state != .large ? min(size.height + max(context.diffY, 0), context.fullViewSize.height) : nil
    }
}

@available(iOS 14.0, *)
public struct TrackableScrollView<Content: View>: UIViewControllerRepresentable {

    let axes: Axis.Set
    let showIndicators: Bool
    let content: () -> Content
    @Environment(\.resizableSheetModel) var resizableSheetModel

    public init(
        _ axes: Axis.Set = .vertical,
        showIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showIndicators = showIndicators
        self.content = content
    }

    public func makeUIViewController(context: Context) -> TrackableScrollViewController<Content> {
        let viewController = TrackableScrollViewController<Content>()
        viewController.hosintgController.rootView = content()
        viewController.gestureHandler.resizableSheetModel = resizableSheetModel
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

        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        scrollView.backgroundColor = .clear

        gestureHandler.setup(for: scrollView, in: view)
    }

    private func setupHostingController() {
        scrollView.addSubview(hosintgController.view)

        guard let view = hosintgController.view else { return }
        view.backgroundColor = .clear

        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
