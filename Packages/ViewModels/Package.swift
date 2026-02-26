// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ViewModels",
    platforms: [.iOS(.v18), .macOS(.v14)],
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
            path: "Sources/ViewModels"
        ),
        .testTarget(
            name: "ViewModelsTests",
            dependencies: ["ViewModels", "Model"],
            path: "Tests/ViewModelsTests"
        )
    ]
)
