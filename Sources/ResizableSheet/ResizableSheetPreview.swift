import SwiftUI

public struct ResizableSheetPreview<Content: View>: View {
    @ObservedObject var center = PreviewResizableSheetCenter.shared

    let content: () -> Content

    public init(_ content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        ZStack {
            content().environment(\.resizableSheetCenter, center)
            PreviewResizableSheetCenter.shared.previews()
        }
    }
}
