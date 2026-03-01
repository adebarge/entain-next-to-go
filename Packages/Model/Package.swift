// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Model",
    platforms: [.iOS(.v26), .macOS(.v15)],
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
