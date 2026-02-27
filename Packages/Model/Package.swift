// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Model",
    platforms: [.iOS(.v18), .macOS(.v13)],
    products: [
        .library(name: "Model", targets: ["Model"])
    ],
    targets: [
        .target(
            name: "Model",
            path: "Sources/Model"
        )
    ]
)
