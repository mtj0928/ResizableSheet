import SwiftUI

public struct GrabBar: View {

    public init() {}

    public var body: some View {
        HStack {
            Spacer()
            Capsule().frame(width: 60, height: 6)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
    }
}
