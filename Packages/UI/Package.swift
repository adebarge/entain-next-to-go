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
        .package(path: "../ViewModels"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.5.0")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: [
                "Model",
                "ViewModels",
                .product(name: "Lottie", package: "lottie-ios")
            ],
            path: "Sources/UI",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
