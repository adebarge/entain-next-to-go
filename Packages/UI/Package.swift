// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "UI",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(name: "UI", targets: ["UI"])
    ],
    dependencies: [
        .package(path: "../Model"),
        .package(path: "../ViewModels"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.5.0"),
        .package(url: "https://github.com/Decybel07/L10n-swift.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: [
                "Model",
                "ViewModels",
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "L10n-swift", package: "L10n-swift")
            ],
            path: "Sources/UI",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
