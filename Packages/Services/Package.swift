// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS(.v18), .macOS(.v13)],
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
        )
    ]
)
