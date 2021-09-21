import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero

    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

public struct ChildSizeReader<Content: View>: View {
    let alignment: Alignment
    let content: () -> Content
    let updateSize: (CGSize) -> ()

    public init(
        alignment: Alignment = .center,
        updateSize: @escaping (CGSize) -> (),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.updateSize = updateSize
        self.content = content
    }

    public init(
        alignment: Alignment = .center,
        size: Binding<CGSize>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.alignment = alignment
        self.updateSize = { newSize in
            size.wrappedValue = newSize
        }
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: alignment) {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
                )
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            updateSize(preferences)
        }
    }
}
