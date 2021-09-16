# ResizableSheet

ResizableSheeet is a half modal view library for SwiftUI.
You can easily implement a half modal view.

## Target 
- Swift5.5
- iOS14+

## Installation
Only SwiftPM

## Sample Code
To use ResizableSheet, follow these steps.

1. Create `ResizableSheetCenter` and embed it to your view in your root view like `RootView`.
```swift
struct RootView: View { 
    let windowScene: UIWindowScene?

    var resizableSheetCenter: ResizableSheetCenter? {
        windowScene.flatMap(ResizableSheetCenter.resolve(for:))
    }
    
    var body: some View { 
        YOUR_VIEW
            .environment(\.resizableSheetCenter, resizableSheetCenter)
    }
}
```

2. Prepare `ResizableSheet` in `onAppear` of your view, and remove the sheet in `onDisapear`. You can show and hide a sheet by updating `ResizableSheetState`.
```swift
struct SomeView: View {
    
    @State var state: ResizableSheetState = .hidden
    @Environment(\.resizableSheetCenter) var resizableSheetCenter

    var body: some View { 
        Button("Show sheet") {
            state = .midium
        }
        .onAppear { 
            resizableSheetCenter?.prepare(for: ResizableSheet(
                id: "id",
                state: $state,
                config: DefaultResizableSheetConfiguration(),
                content: { context in
                    VStack(spacing: 0) {
                        Text("text").padding()
                        Spacer(minLength: 0)
                    }
                }))
        }
        .onDisappear {
            resizableSheetCenter?.remove(id: "id")
        }
    }
}
```

That's all!  
You can show a semi modal view by taping the button "Show sheet".
