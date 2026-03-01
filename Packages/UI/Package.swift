// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "UI",
    platforms: [.iOS(.v26)],
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
