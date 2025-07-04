// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPixelIt",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftPixelIt",
            targets: ["SwiftPixelIt"]),
    ],
    targets: [
        .target(
            name: "SwiftPixelIt",
            dependencies: []),
        .testTarget(
            name: "SwiftPixelItTests",
            dependencies: ["SwiftPixelIt"]),
    ]
)