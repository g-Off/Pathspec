// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Pathspec",
    products: [
        .library(
            name: "Pathspec",
            targets: ["Pathspec"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Pathspec",
            dependencies: []),
        .testTarget(
            name: "PathspecTests",
            dependencies: ["Pathspec"]),
    ]
)
