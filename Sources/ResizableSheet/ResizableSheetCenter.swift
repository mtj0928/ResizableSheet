import SwiftUI
import UIKit

public class ResizableSheetCenter {

    private static var centers: [String: ResizableSheetCenter] = [:]

    public fileprivate(set) var sheets: [ResizableSheetBuilder] = [] {
        didSet { update() }
    }

    public let window: UIWindow?
    private let layer: UIHostingController<AnyView?>?
    private let previousKeyWindow: UIWindow?

    init() {
        window = nil
        layer = nil
        previousKeyWindow = nil
    }

    private init(for windowScene: UIWindowScene) {
        self.previousKeyWindow = windowScene.windows.first(where: \.isKeyWindow)

        let hostingController = UIHostingController<AnyView?>(rootView: nil)
        hostingController.view.backgroundColor = .clear
        self.layer = hostingController

        self.window = OverlayWindow(ignoreView: hostingController.view)
        window?.rootViewController = hostingController
        window?.windowLevel = .normal
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()

        previousKeyWindow?.makeKey()
    }

    public func update() {
        layer?.rootView = AnyView(
            ZStack {
                ForEach(sheets) { builder in
                    builder.build()
                }
            }
        )
        if sheets.isEmpty {
            previousKeyWindow?.makeKey()
        } else {
            window?.makeKey()
        }
    }

    public func add(_ builder: ResizableSheetBuilder) {
        if sheets.contains(where: { $0.id == builder.id }) {
            remove(id: builder.id)
        }
        sheets.append(builder)
    }

    public func remove(id: String = ResizableSheet.defaultId) {
        sheets = sheets.filter { $0.id != id }
    }

    public static func resolve(for windowSenece: UIWindowScene) -> ResizableSheetCenter {
        if let center = centers[windowSenece.session.persistentIdentifier] {
            return center
        }
        let center = ResizableSheetCenter(for: windowSenece)
        centers[windowSenece.session.persistentIdentifier] = center
        return center
    }
}

extension ResizableSheetBuilder {

    func build() -> ResizableSheet {
        ResizableSheet(
            id: id,
            state: state,
            model: model,
            config: config,
            content: mainViewBuilder
        )
    }
}


public class PreviewResizableSheetCenter: ResizableSheetCenter, ObservableObject {

    public static let shared = PreviewResizableSheetCenter()

    public func previews() -> some View {
        ZStack {
            ForEach(sheets) { builder in
                builder.build()
            }
        }
    }

    public override func update() {
        objectWillChange.send()
    }

    public override func add(_ builder: ResizableSheetBuilder) {
        if sheets.contains(where: { $0.id == builder.id }) {
            remove(id: builder.id)
        }
        sheets.append(builder)
    }

    public override func remove(id: String = ResizableSheet.defaultId) {
        sheets = sheets.filter { $0.id != id }
    }
}
