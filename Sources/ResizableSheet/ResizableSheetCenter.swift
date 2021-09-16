import SwiftUI
import UIKit

public class ResizableSheetCenter {

    private static var centers: [String: ResizableSheetCenter] = [:]

    public var sheets: [ResizableSheet] = [] {
        didSet { update() }
    }

    private let window: OverlayWindow
    private let layer: UIHostingController<AnyView?>
    private let previousKeyWindow: UIWindow?

    private init(for windowScene: UIWindowScene) {
        self.previousKeyWindow = windowScene.windows.first(where: \.isKeyWindow)

        let hostingController = UIHostingController<AnyView?>(rootView: nil)
        hostingController.view.backgroundColor = .clear
        self.layer = hostingController

        self.window = OverlayWindow(ignoreView: hostingController.view)
        window.rootViewController = hostingController
        window.windowLevel = .normal
        window.windowScene = windowScene
        window.makeKeyAndVisible()

        previousKeyWindow?.makeKey()
    }

    public func update() {
        layer.rootView = AnyView(
            ZStack {
                ForEach(sheets) { sheet in
                    sheet
                }
            }
        )
        if sheets.isEmpty {
            previousKeyWindow?.makeKey()
        } else {
            window.makeKey()
        }
    }

    public func prepare(for sheet: ResizableSheet) {
        if sheets.contains(where: { $0.id == sheet.id }) {
            remove(id: sheet.id)
        }
        sheets.append(sheet)
    }

    public func remove(id: String) {
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
