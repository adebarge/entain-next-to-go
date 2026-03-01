// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ViewModels",
    defaultLocalization: "en",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "ViewModels", targets: ["ViewModels"])
    ],
    dependencies: [
        .package(path: "../Model")
    ],
    targets: [
        .target(
            name: "ViewModels",
            dependencies: ["Model"],
            path: "Sources/ViewModels",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ViewModelsTests",
            dependencies: ["ViewModels", "Model"],
            path: "Tests/ViewModelsTests"
        )
    ]
)
