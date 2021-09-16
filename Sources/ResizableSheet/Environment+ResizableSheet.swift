import SwiftUI

struct ResizableSheetModelKey: EnvironmentKey {
    static let defaultValue: ResizableSheetModel? = nil
}

extension EnvironmentValues {
    var resizableSheetModel: ResizableSheetModel? {
        get { self[ResizableSheetModelKey.self] }
        set { self[ResizableSheetModelKey.self] = newValue }
    }
}

public struct ResizableSheetCenterKey: EnvironmentKey {
    public static let defaultValue: ResizableSheetCenter? = nil
}

extension EnvironmentValues {
    public var resizableSheetCenter: ResizableSheetCenter? {
        get { self[ResizableSheetCenterKey.self] }
        set { self[ResizableSheetCenterKey.self] = newValue }
    }
}
