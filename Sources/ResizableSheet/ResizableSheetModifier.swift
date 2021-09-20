import SwiftUI

public struct ResizableSheetModifier: ViewModifier {

    let id: String
    let builder: ResizableSheetBuilder
    @Binding var state: ResizableSheetState

    @Environment(\.resizableSheetCenter) var resizableSheetCenter

    init(id: String, state: Binding<ResizableSheetState>, builder: ResizableSheetBuilder) {
        self.id = id
        self._state = state
        self.builder = builder
    }

    public func body(content: Content) -> some View {
        content.onAppear {
            resizableSheetCenter?.add(builder)
        }
        .onDisappear {
            resizableSheetCenter?.remove(id: id)
        }
    }
}

extension View {

    public func resizableSheet(
        _ state: Binding<ResizableSheetState>,
        id: String = ResizableSheet.defaultId,
        builder builderMidifier: (ResizableSheetBuilder) -> ResizableSheetBuilder
    ) -> some View {
        let model = ResizableSheetModel(state: state.wrappedValue)
        var builder = ResizableSheetBuilder(
            id: id,
            config: ResizableSheetConfiguration(),
            state: state,
            model: model,
            context: { _ in
                VStack {
                    GrabBar()
                    HStack {
                        Text("Text")
                        Spacer()
                    }
                    .frame(height: 300)
                }.padding([.bottom, .horizontal])
            }
        )
        builder = builderMidifier(builder)
        return self.modifier(ResizableSheetModifier(id: id, state: state, builder: builder))
    }
}
