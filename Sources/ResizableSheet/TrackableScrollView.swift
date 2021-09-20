import SwiftUI

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
    let scrollViewDelegate = ScrollViewDelegate()
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

        scrollViewDelegate.gestureHandler = gestureHandler
        scrollView.delegate = scrollViewDelegate

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

class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    weak var gestureHandler: ScrollViewGestureHandler?

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        gestureHandler?.startOffset = scrollView.contentOffset.y
    }
}
