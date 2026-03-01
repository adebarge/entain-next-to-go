// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "Services", targets: ["Services"])
    ],
    dependencies: [
        .package(path: "../Model")
    ],
    targets: [
        .target(
            name: "Services",
            dependencies: ["Model"],
            path: "Sources/Services"
        ),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["Services", "Model"],
            path: "Tests/ServicesTests"
        )
    ]
)
