// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tito",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Tito",
            targets: ["Tito"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/shogo4405/HaishinKit.swift.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "Tito",
            dependencies: [
                .product(name: "HaishinKit", package: "HaishinKit.swift")
            ]
        ),
        .testTarget(
            name: "TitoTests",
            dependencies: ["Tito"]
        ),
    ]
)
