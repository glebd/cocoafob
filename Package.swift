// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "CocoaFob",
    platforms: [
      .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "CocoaFob",
            type: .static,
            targets: ["CocoaFob"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "CocoaFob",
            dependencies: [],
            path: "swift5/CocoaFob",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "CocoaFobTests",
            dependencies: ["CocoaFob"],
            path: "swift5/CocoaFobTests",
            exclude: ["Info.plist"]),
    ]
)
