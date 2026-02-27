// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UI",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(name: "UI", targets: ["UI"])
    ],
    dependencies: [
        .package(path: "../Model"),
        .package(path: "../ViewModels")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: [
                "Model",
                "ViewModels"
            ],
            path: "Sources/UI"
        )
    ]
)
