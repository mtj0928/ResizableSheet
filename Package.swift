// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ResizableSheet",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "ResizableSheet",
            targets: ["ResizableSheet"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ResizableSheet",
            dependencies: []),
    ]
)
