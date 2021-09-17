# ResizableSheet

ResizableSheeet is a half modal view library for SwiftUI.
You can easily implement a half modal view.

## Target 
- Swift5.5
- iOS14+

## Installation
Only SwiftPM

## Features

- 3 states are supported.
  - hidden
  - midium
  - large
- The midium size is automatically calculated baesd on the content.
- You can update view for each state.
- ResizableSheet contains `TrackableScrollView`. The view is wrapper view of `UIScrollView` and the offset synchronizes with dragging of sheet.

## Simple Example 
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

<img src="./Doc/Resources/SimpleSheet.gif" width=250pt/>

## View structure

ResizableSheet has some view components.  
You can control each view components based on current status.

```
ResizableSheet
 └─ background (ResizableSheetConfiguration)
     ├─ outside (ResizableSheetConfiguration)
	   └─ sheet background (ResizableSheetConfiguration)
         └─ content (ResizableSheet)
```

<img src="./Doc/Resources/ViewStructure.png"/>



### Content

This view is configured on `init` of `ResizableSheet`.  
You can update the view based on the current status.

```swift
resizableSheetCenter?.prepare(for: ResizableSheet(
    id: "id",
    state: $state,
    config: DefaultResizableSheetConfiguration(),
    content: { context in
        VStack {
            Text(context.state == .hidden ? "hidden" :
                    context.state == .midium ? "midium" : "large"
            )
            Color.gray
                .frame(height:
                        context.state == .midium ? max(0, context.diffY) :
                        context.state == .hidden ? 0 : nil
                )
                .opacity(context.state == .midium ? context.percent : 1.0 - abs(context.percent))
                .allowsHitTesting(false)
            Text("Buttom")
        }
        .padding()
    })
)
```

<img src="./Doc/Resources/ContentExample.gif" width=250pt/>

